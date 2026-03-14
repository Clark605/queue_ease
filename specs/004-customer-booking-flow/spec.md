# Feature Specification: Customer Booking Flow

**Feature Branch**: `004-customer-booking-flow`  
**Created**: March 11, 2026  
**Status**: Draft  
**Sprint**: Sprint 4 (Weeks 5–6)  
**Input**: User description: "start customer booking flow sprint 4 specification: without testing, strict clean architecture"

## Scope

This sprint delivers the complete end-to-end customer booking journey: a customer scans an organization's QR code (or follows a shared link), lands on the organization's booking page, selects a service and available time slot, fills in their details, and confirms the appointment. No automated tests are included in this sprint's scope — testing is deferred to Sprint 8.

**Assumption**: The customer is already authenticated (email/password or Google Sign-In) before entering the booking flow. Unauthenticated users are redirected to the login/signup screen and returned to the booking flow afterwards.

---

## Clarifications

### Session 2026-03-11

- Q: Should slot calculation expose other customers' appointment PII (name, phone) to the querying customer? → A: No. The Firestore query returns full appointment documents to the client, but the domain layer extracts **only opaque occupied time ranges** (scheduledAt + durationMinutes). No customer PII from other appointments propagates to any use case output, Cubit state, or widget.
- Q: Should the customer home screen display upcoming appointments in Sprint 4? → A: No — customer home is a simple dashboard; appointment list deferred to Sprint 5. `AppointmentRepository` does NOT need `getUpcomingAppointments` in this sprint.
- Q: When Firestore write fails during booking submission (network error / timeout), what happens? → A: Show an inline error with a retry button; keep form data intact. The `BookingFormCubit` emits an error state; the form remains mounted so the customer can retry without re-entering details.
- Q: Should booking events be logged with structured analytics or Talker only? → A: Talker error/warning logs only. No analytics events this sprint. Errors are logged via the existing `AppException` + Talker pattern at repository and use-case boundaries.
- Q: Should `AppointmentModel` expose both `toEntity()` (read path) and `fromEntity(AppointmentEntity)` (write path)? → A: Yes. Both are required. `toEntity()` converts a Firestore document to a domain entity; `fromEntity()` converts a domain entity to a model for Firestore writes. The datasource MUST NOT unpack entity fields directly.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Customer Lands on Organization Booking Page via QR / Link (Priority: P1)

A customer scans an organization's QR code printed at the front desk, or taps a shared link sent by the admin. The app deep-links to the organization's landing page, displaying its name, description, address, open/closed status, and a prompt to begin booking. If the link contains an unrecognized slug, a clear "organization not found" message is shown.

**Why this priority**: This is the entry point of the entire booking flow. Without it, no customer can reach any other step. It also validates that the QR/share work from Sprint 3 connects properly to the customer-facing experience.

**Independent Test**: A customer taps a link in the format `/org/<slug>`, reaches the organization landing page, sees the correct org name and open/closed status, and can tap "Book Now". If the slug does not exist, a "Not Found" error screen is shown instead.

**Acceptance Scenarios**:

1. **Given** a valid organization booking link, **When** the customer opens it, **Then** the organization landing page loads showing the org name, description (if set), address (if set), and current open/closed status.
2. **Given** the organization is currently open (today's day and current time fall within configured working hours), **When** the page loads, **Then** an "Open" indicator is visible and a "Book Appointment" button is enabled.
3. **Given** the organization is currently closed (outside working hours or on a closed day), **When** the page loads, **Then** a "Closed" indicator is displayed and the "Book Appointment" button is replaced with a message indicating the next open time.
4. **Given** a link with an unrecognized booking slug, **When** the customer opens it, **Then** a "This organization could not be found" error screen is shown with a way to exit.
5. **Given** an unauthenticated customer opening the booking link, **When** the page resolves, **Then** they are prompted to sign in and are returned to the same booking link after authentication.

---

### User Story 2 — Customer Selects a Service (Priority: P2)

After landing on the organization page and tapping "Book Appointment", the customer sees the list of active services offered by the organization. Each service shows its name, duration, description, and price (if set). The customer selects one service to proceed to time slot selection.

**Why this priority**: Service selection is the second step in the booking funnel. It must exist before slot calculation can proceed, since available slots are service-duration-dependent.

**Independent Test**: On the services screen, a customer can see at least one active service with its name and duration, tap it, and proceed to the time slot picker.

**Acceptance Scenarios**:

1. **Given** the customer has tapped "Book Appointment", **When** the services screen loads, **Then** only active services for the organization are displayed.
2. **Given** a service with a price and description, **When** it appears in the list, **Then** duration, price, and description are all visible.
3. **Given** the customer taps a service, **When** the action completes, **Then** they navigate to the time slot picker with that service pre-selected.
4. **Given** the organization has no active services, **When** the services screen loads, **Then** an empty-state message is displayed explaining that no services are currently available.

---

### User Story 3 — Customer Picks an Available Time Slot (Priority: P3)

The customer sees a date selector (covering today and the next 6 days). For each date, the system calculates available appointment slots based on:

- The organization's working hours for that day (open/close times and optional break)
- The selected service's duration
- Existing confirmed appointments (no overlaps)

Available slots are displayed in a scrollable list. Already-booked slots are excluded. The customer selects one slot to proceed.

**Why this priority**: Time slot selection is the core scheduling logic of the app. Without conflict-aware slot calculation, double bookings would occur, which is the primary reliability concern of the entire system.

**Independent Test**: With a service of 30-minute duration, an org open 09:00–17:00 with a break 12:00–13:00 and one existing booking at 10:00–10:30, the slot list does NOT include 10:00 and does NOT include any slot between 12:00 and 13:00. All other 30-minute slots are present.

**Acceptance Scenarios**:

1. **Given** the customer is on the slot picker, **When** the screen loads, **Then** the available dates shown are today through 6 days ahead, with closed days visually disabled.
2. **Given** the customer selects a date that falls on a closed day (per working hours), **When** they tap it, **Then** that date is shown as unavailable and no slots are displayed.
3. **Given** a working day open 09:00–17:00 and a 30-minute service, **When** slots are calculated, **Then** they start on the hour/half-hour from 09:00 up to 16:30 (the last slot that fits before close).
4. **Given** a break period of 12:00–13:00, **When** slots are calculated, **Then** no slot overlapping that break (e.g., 11:45, 12:00, 12:30) is included.
5. **Given** an existing appointment at 10:00–10:30 on a selected date, **When** slots are calculated, **Then** the 10:00 slot is absent from the available list.
6. **Given** no available slots remain for a selected date, **When** the list renders, **Then** a message "No slots available for this day" is displayed.
7. **Given** the customer taps an available slot, **When** the tap registers, **Then** the slot is highlighted and a "Continue" button becomes active.

---

### User Story 4 — Customer Confirms Booking Details and Submits (Priority: P4)

The customer is shown a booking summary (organization name, service name, date and time, duration) along with an editable form field for their display name and an optional phone number field. Their name is pre-filled from their authenticated profile if available. They tap "Confirm Booking" to save the appointment.

**Why this priority**: This step collects the customer's identity and creates the persistent appointment record. Without it, no appointment exists in Firestore and the queue system has no data to operate on.

**Independent Test**: A customer on the confirmation form can verify the correct service and time slot in the summary, edit their name, tap "Confirm Booking", and see the booking confirmation screen.

**Acceptance Scenarios**:

1. **Given** the customer reaches the booking form, **When** the screen loads, **Then** the summary shows the correct organization, service name, selected date/time, and service duration.
2. **Given** the customer is authenticated and has a display name, **When** the form loads, **Then** the name field is pre-filled with their profile name.
3. **Given** the customer clears the name field and taps confirm, **When** validation runs, **Then** an error message "Name is required" is shown and the form is not submitted.
4. **Given** valid name (and optional phone), **When** the customer taps "Confirm Booking", **Then** the appointment is saved with status `booked`, linked to the correct org, service, customer UID, and selected time.
5. **Given** another booking is made for the same slot between the customer viewing slots and tapping confirm (race condition), **When** the save attempt is made, **Then** a conflict error is displayed and the customer is asked to choose a different slot.
6. **Given** a successful save, **When** the operation completes, **Then** the customer is navigated to the booking confirmation screen.

---

### User Story 5 — Customer Views Booking Confirmation (Priority: P5)

After a successful booking, the customer lands on a confirmation screen showing: organization name, service name, scheduled date and time, and the organization's address (if set). The screen provides a button to return to their home dashboard.

**Why this priority**: A confirmation screen closes the booking loop and gives customers confidence that their appointment was registered. It also serves as a reference before the queue status feature is built.

**Independent Test**: After confirming a booking, the customer sees the confirmation screen with the correct service name and date/time, and can tap "Back to Home" to return to the customer home page.

**Acceptance Scenarios**:

1. **Given** the booking was saved successfully, **When** the confirmation screen loads, **Then** it displays organization name, service name, scheduled date and time.
2. **Given** the organization has an address set, **When** the confirmation screen loads, **Then** the address is shown.
3. **Given** the customer taps "Back to Home", **When** the tap registers, **Then** they are navigated to the customer home dashboard, and the booking flow stack is cleared.

---

### Edge Cases

- **No working hours configured**: If an admin has not yet saved any working hours, the organization page shows "Closed" and no slots can be booked until hours are configured.
- **All services inactive**: The services screen shows an empty state; booking cannot proceed.
- **Organization document not found for slug**: The app shows an error screen instead of crashing.
- **Unauthenticated deep link**: The app redirects to login and returns to the original deep link after successful authentication.
- **Time zone**: All times are stored and displayed in the device's local time zone. Cross-time-zone booking is out of scope for this sprint.
- **Same-day booking cutoff**: If the current time is past the last available slot for today, today shows no available slots (not a closed day — just fully booked or elapsed).
- **Concurrent booking race**: If two customers attempt the same slot simultaneously, the one whose write arrives second receives a conflict error and must pick a different slot.
- **Network failure during submission**: If the Firestore write fails with a `DatabaseException` (connectivity loss, timeout), the `BookingFormCubit` emits an error state. The booking form remains mounted with all field data preserved and an inline error message with a "Retry" action is shown. The customer is NOT navigated away. Offline-first queuing is out of scope for this sprint.
- **Customer data isolation in slot queries**: The appointment query for slot calculation returns full Firestore documents. The `CalculateAvailableSlotsUseCase` MUST extract only `(scheduledAt, durationMinutes)` tuples for overlap detection; appointment owner identity and contact details MUST NOT appear in slot-calculation outputs or error messages.
- **Link slug casing**: Slug matching is case-insensitive (e.g., `Acme-Clinic` matches `acme-clinic`).

---

## Requirements *(mandatory)*

### Functional Requirements

#### Discovery & Entry
- **FR-001**: The app MUST resolve a booking link containing an organization slug to the correct organization's landing page.
- **FR-002**: The landing page MUST display the organization's current open/closed status derived from its working hours and the current day/time.
- **FR-003**: The system MUST redirect unauthenticated customers to sign in before allowing them to proceed into the booking flow, and MUST return them to the same organization page after authentication.

#### Service Selection
- **FR-004**: The service list MUST display only services marked as `isActive = true` for the resolved organization.
- **FR-005**: Each service entry MUST show at minimum: name, duration in minutes, and price (if set).

#### Time Slot Calculation (Domain Logic)
- **FR-006**: The system MUST calculate available time slots for a given date using the organization's working hours (`openTime`, `closeTime`) and the selected service's `durationMinutes`.
- **FR-007**: The system MUST exclude any slot that overlaps with an organization's break period (`breakStart`–`breakEnd`) for that day.
- **FR-008**: The system MUST exclude any slot that overlaps with an existing confirmed appointment for the same service (same org, same date, any status other than `noShow`). The slot calculation MUST use only the occupied time range (scheduledAt + durationMinutes) from existing appointments — customer name, phone, and all other PII MUST NOT be accessed or propagated during slot logic.
- **FR-009**: The system MUST NOT show time slots on days where the organization's `isOpen` is `false` for that day of the week.
- **FR-010**: All time slot calculation logic MUST reside exclusively in the domain layer — no slot logic in widgets, cubits, data sources, or repositories.

#### Booking Submission
- **FR-011**: The booking form MUST require a customer display name before submission.
- **FR-012**: Phone number MUST be optional.
- **FR-013**: The system MUST associate the appointment with the authenticated customer's UID as `customerId`.
- **FR-014**: A submitted appointment MUST be saved with `status = booked`, the correct `orgId`, `serviceId`, `scheduledAt`, `customerName`, and `createdAt`.
- **FR-015**: Before persisting, the system MUST perform a final conflict check; if a conflict is detected, the booking MUST fail with a user-facing error rather than creating a duplicate.

#### Clean Architecture Constraints
- **FR-016**: The `AppointmentRepository` abstract interface MUST be defined in the domain layer and implemented in the data layer.
- **FR-017**: The customer presentation layer MUST interact with domain use cases only — never directly with repositories or data sources.
- **FR-018**: Use cases MUST be the sole orchestrators of business rules (slot calculation, conflict detection, booking creation).
- **FR-019**: The existing `OrganizationRepository` and `ServiceRepository` MUST be reused via their domain abstractions; no new data sources for organizations or services are introduced.
- **FR-020**: All data-layer models introduced in this feature MUST implement a `toEntity()` method that converts the model to its corresponding domain entity. The `AppointmentModel` MUST additionally implement a `fromEntity(AppointmentEntity)` named constructor for the write path. The datasource MUST use `AppointmentModel.fromEntity(entity).toMap()` when writing to Firestore — never unpacking entity fields directly. The domain layer MUST NEVER import data model classes directly.

### Key Entities

- **Organization** (existing): Identifies the service provider. Key fields used: `id`, `name`, `bookingLinkSlug`, `isOpen`, `address`, `description`. Read-only in this feature.
- **Service** (existing): Defines what can be booked. Key fields: `id`, `orgId`, `name`, `durationMinutes`, `price`, `isActive`. Read-only in this feature.
- **WorkingHours** (existing): Per-day schedule. Key fields: `orgId`, `dayOfWeek`, `isOpen`, `openTime`, `closeTime`, `breakStart`, `breakEnd`. Read-only; provides slot boundaries.
- **Appointment** (new write path): The booking record created by the customer. Fields: `id`, `orgId`, `serviceId`, `customerId`, `customerName`, `customerPhone`, `scheduledAt`, `status`, `createdAt`.

### Observability

- All `AppException` subtypes caught in use cases and repository implementations MUST be logged via **Talker** at the appropriate level: `talker.error()` for `DatabaseException` and `UnknownException`; `talker.warning()` for `ValidationException` (e.g., booking conflict).
- No Firebase Analytics or structured event tracking is in scope for this sprint.
- Sensitive fields (customerName, customerPhone, customerId) MUST NOT appear in log messages.

---

## Assumptions

- Customers are authenticated before entering the booking flow (per the existing auth system). Guest booking is out of scope.
- Time slots are aligned to the service's `durationMinutes` boundary starting from `openTime` (e.g., a 30-min service starting at 09:00 produces slots at 09:00, 09:30, 10:00, …).
- There is no per-service booking limit per day — only the physical time slots constrain availability.
- Appointments can only be booked on the current day or within the next 6 days (7-day rolling window).
- Past time slots for today (e.g., a 10:00 slot when the current time is 10:45) are excluded from available slots.
- Queue position assignment is out of scope — that belongs to Sprint 5.
- The customer home screen does NOT display a list of upcoming appointments in this sprint — that is deferred to Sprint 5 alongside queue status.
- Push notifications for booking confirmation are out of scope — that belongs to Sprint 7.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A customer can complete the full journey — from tapping a booking link to seeing a booking confirmation — in under 3 minutes on a standard mobile connection.
- **SC-002**: The system correctly excludes booked time slots from the available list 100% of the time, preventing double bookings.
- **SC-003**: The organization landing page loads and displays accurate open/closed status within 2 seconds of the deep link being opened.
- **SC-004**: The full booking flow is demoable end-to-end: QR scan → org page → service selection → time slot picker → booking form → confirmation.
- **SC-005**: 100% of business rules (slot calculation, conflict detection) are implemented exclusively in the domain layer with zero logic leakage into the presentation or data layers.
- **SC-006**: The `AppointmentRepository` contract is defined in the domain layer, fulfilled by a Firestore implementation in the data layer, and consumed exclusively via use cases in the presentation layer — satisfying strict Clean Architecture compliance.
