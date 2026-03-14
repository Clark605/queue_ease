# Firestore Rules Contract: Queue System (Sprint 5)

## Objective

Define required security behavior for queue-related reads/writes while preserving privacy and org boundaries.

## Required Access Constraints

1. Queue and appointment access must be scoped to organization membership/ownership rules.
2. Admin queue actions are restricted to the single admin of that organization.
3. Customer queue status reads are restricted to the authenticated customer's own active appointment data plus current-serving indicator.
4. Customer reads must not expose other customer identities.

## Required Write Constraints

1. Queue generation accepts only same-day appointments with `status == booked`.
2. Queue actions must only allow valid status transitions:
   - `serving -> completed`
   - `serving -> noShow`
   - `serving -> inQueue` (skip to end)
   - `skipped/inQueue -> inQueue` (explicit rejoin append semantics managed in transaction)
3. Rules must reject malformed queue documents:
   - duplicate IDs in `orderedAppointmentIds`
   - invalid `currentServingIndex`

## Query/Index Expectations

- Appointment query pattern: by organization path + date window + status for generation.
- Queue query pattern: by date document in organization subcollection.
- Add/verify required Firestore indexes before release.

## Logging and Error Mapping

- Data-layer failures map to `AppException` subtypes.
- No PII (customer name/phone) appears in production log payloads.
