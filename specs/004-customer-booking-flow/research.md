# Research: Customer Booking Flow

**Date**: March 11, 2026  
**Feature**: `004-customer-booking-flow`

---

## R-001: Firestore Security Rules — Appointment Field Mismatch (BLOCKER)

**Decision**: Update Firestore `appointments` create rule to include `customerName` and `customerPhone` in the allowed fields list.

**Rationale**: The existing `AppointmentModel.toMap()` serializes `customerName` (String, required) and `customerPhone` (String?, optional), but the current `hasOnlyAllowedFields()` call in `firestore.rules` line ~247 only allows `['orgId','customerId','serviceId','scheduledAt','status','customerNotes','adminNotes','createdAt','updatedAt']`. Any customer booking write will be rejected by security rules until this is fixed. The `queuePosition` field (nullable int) should also be added since it exists in the model — even though it won't be set at booking time, the update rule needs it too.

**Alternatives considered**:
- Strip fields from the model at write time → Rejected: breaks round-trip data integrity (Constitution I)
- Use Cloud Functions to bypass rules → Rejected: premature for Sprint 4 (Sprint 6 scope)

---

## R-002: Firestore Security Rules — Customer Appointment List Permission (BLOCKER)

**Decision**: Add a `list` rule for authenticated customers to query appointments within an organization, scoped to a specific date range and service.

**Rationale**: Currently, `allow list` on appointments is restricted to `ownsOrganization(orgId)` (admin-only). Customers need to query existing appointments for a given date and service to calculate available time slots (FR-008). Without this, the slot calculation use case cannot fetch booked appointments.

**Recommended rule**: Allow authenticated users to list appointments within an org. The appointment data (name, time, status) is not sensitive — it's equivalent to what a customer sees on a waiting room board.

**Alternatives considered**:
- Create a separate `booked_slots` read-only collection → Rejected: adds data duplication and sync complexity
- Use Cloud Functions to return available slots → Rejected: Cloud Functions are Sprint 6 scope. Doing this client-side is simpler and sufficient for MVP.
- Read only appointment times (field-level security) → Not possible in Firestore rules

---

## R-003: Organization Slug Lookup — New Repository Method

**Decision**: Add `getOrganizationBySlug(String slug)` to the shared `OrganizationRepository` and its Firestore implementation.

**Rationale**: The customer booking flow resolves a URL `/c/org/:slug` to an organization. Currently, `OrganizationRepository` only supports `watchOrganization(orgId)` and `getOrganizationByAdminUid(adminUid)`. A new Firestore query (`where('bookingLinkSlug', isEqualTo: slug).limit(1)`) is required. This belongs in the shared repository since it's a read-only operation used by the customer role.

**Alternatives considered**:
- Create a separate `CustomerOrganizationRepository` → Rejected: the shared layer already handles read operations; adding a method follows the existing pattern
- Store slug→orgId mapping in a top-level `slugs` collection → Rejected: adds data duplication; the existing field supports a direct query

---

## R-004: Deep Linking with GoRouter — Route Pattern

**Decision**: Add a customer route `/c/org/:slug` to GoRouter that accepts the booking link slug as a path parameter. Additional booking flow routes follow as nested paths: `/c/org/:slug/services`, `/c/org/:slug/slots`, `/c/org/:slug/book`, `/c/org/:slug/confirmation`.

**Rationale**: GoRouter supports path parameters natively via `:param` syntax. The existing router uses `/a/...` for admin and `/c/...` for customer. Booking flow routes are nested under the org slug so the org context is preserved across the funnel. The redirect logic already handles unauthenticated users — a customer hitting `/c/org/:slug` while unauthenticated will be redirected to `/login` and returned after auth.

**Alternatives considered**:
- Use query parameters (`/c/book?slug=acme`) → Rejected: path parameters are more RESTful and better for deep links
- Use a separate `ShellRoute` for the booking flow → Rejected: simple `GoRoute` nesting is sufficient for a linear funnel

---

## R-005: Time Slot Calculation — Pure Domain Algorithm

**Decision**: Implement a `CalculateAvailableSlotsUseCase` in the domain layer that takes working hours, service duration, existing appointments, and current time as inputs and returns a list of available `DateTime` slots.

**Rationale**: Per FR-010, all slot calculation logic must reside exclusively in the domain layer. The algorithm:
1. Parse `openTime`/`closeTime` from `WorkingHoursEntity` into time boundaries for the given date
2. Generate candidate slots at `durationMinutes` intervals from open to close
3. Remove slots overlapping the break period (`breakStart`–`breakEnd`)
4. Remove slots overlapping existing appointments (any status except `noShow`)
5. Remove past slots (slot start < current time) for today's date
6. Return the remaining list

This is a pure function with no framework dependencies — inputs are domain entities, output is `List<DateTime>`.

**Alternatives considered**:
- Calculate slots server-side via Cloud Functions → Rejected: adds latency and complexity; Sprint 6 scope
- Store pre-computed slots in Firestore → Rejected: stale data problem; real-time computation is more reliable

---

## R-006: Appointment Conflict Detection — Write-Time Check

**Decision**: Implement a two-phase conflict check: (1) client-side query before showing the confirm button, and (2) a Firestore transaction at write time that re-checks before committing.

**Rationale**: FR-015 requires a final conflict check before persisting. Client-side-only checks are vulnerable to race conditions (two customers booking the same slot simultaneously). A Firestore transaction reads the appointments for the given date+service, checks for overlap, and only writes if no conflict exists. This provides atomicity without Cloud Functions.

**Transaction pattern**:
```
runTransaction((txn) {
  1. Read appointments for orgId + date range (scheduledAt between day-start and day-end) + serviceId
  2. Check if any existing appointment's scheduledAt conflicts with the requested slot
  3. If conflict → throw ValidationException
  4. If clean → txn.set(newAppointmentRef, appointmentData)
})
```

**Alternatives considered**:
- Firestore rules-only conflict prevention → Not possible: rules can't query sibling documents
- Optimistic write + rollback → Rejected: briefly creates duplicate before detecting; worse UX

---

## R-007: Firestore Compound Index Required

**Decision**: Add a compound index on the `appointments` subcollection for `serviceId` (ASC) + `scheduledAt` (ASC) to support efficient slot conflict queries.

**Rationale**: The slot calculation use case queries appointments by `orgId` (implicit via subcollection path), `serviceId`, and `scheduledAt` date range. Without a compound index, Firestore will reject the query at runtime. The constitution (Principle VI) requires compound indexes for filtered queries.

**Index definition** (in `firestore.indexes.json`):
- Collection: `organizations/{orgId}/appointments`
- Fields: `serviceId` ASC, `scheduledAt` ASC

---

## R-008: AppointmentRepository — New Domain Contract

**Decision**: Create an `AppointmentRepository` abstract class in the shared booking domain layer with methods for creating appointments and querying by date/service.

**Rationale**: FR-016 mandates the repository interface in the domain layer. The implementation lives in the data layer. Methods needed:
- `Future<Result<AppointmentEntity>> createAppointment(AppointmentEntity appointment)` — creates with conflict-checking transaction
- `Future<Result<List<AppointmentEntity>>> getAppointmentsForDateAndService(String orgId, String serviceId, DateTime date)` — for slot calculation
- `Stream<List<AppointmentEntity>> watchAppointmentsForDate(String orgId, DateTime date)` — for real-time slot updates (optional, nice-to-have)

This follows the existing pattern: `OrganizationRepository` (domain) → `OrganizationRepositoryImpl` (data).
