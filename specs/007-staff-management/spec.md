# Feature Specification: Staff Member Management (Hybrid Queue Visibility)

**Feature Branch**: `007-staff-management`  
**Created**: March 17, 2026  
**Last Updated**: April 24, 2026  
**Status**: Draft  
**Priority**: Critical for MVP  
**Input**: Existing feature specification in `specs/007-staff-management/spec.md`

## Executive Summary

This feature introduces staff member management so organizations can operate with multiple staff while keeping one shared queue. Admins can create and manage staff profiles, assign each service to one staff member, and filter the queue by staff to manage daily work more clearly. Customers keep a simple booking flow and do not need to manually choose a staff member.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin manages staff members (Priority: P1)

An admin can create, edit, activate/deactivate, and remove staff member profiles in the admin area.

**Why this priority**: Staff management is the foundation for service assignment and queue visibility. Without it, the rest of the feature cannot function.

**Independent Test**: Admin creates a staff member, edits profile details, toggles active status, and removes a staff member who has no active service assignments.

**Acceptance Scenarios**:

1. **Given** an admin opens Staff Management, **When** staff members exist, **Then** the admin sees a list of staff with role and status.
2. **Given** no staff members exist, **When** an admin opens Staff Management, **Then** the admin sees an empty state with a clear action to add a staff member.
3. **Given** an admin submits valid staff profile information, **When** they save, **Then** the new staff member appears in the list as active by default.
4. **Given** a staff member has active service assignments, **When** an admin attempts to remove them, **Then** the system blocks removal and explains what must be reassigned first.

---

### User Story 2 - Admin assigns services to staff (Priority: P1)

An admin assigns each service to exactly one staff member and can reassign services when needed.

**Why this priority**: Service ownership must be explicit so queue entries are actionable and operationally clear.

**Independent Test**: Admin assigns a service to Staff A, later reassigns the same service to Staff B, and verifies new bookings follow the new assignment.

**Acceptance Scenarios**:

1. **Given** an admin creates or edits a service, **When** they choose a staff member and save, **Then** that service is assigned to exactly one staff member.
2. **Given** a service has no valid staff assignment, **When** admin attempts to publish or activate it for booking, **Then** the system blocks the action and provides a corrective message.
3. **Given** a service is reassigned, **When** the change is saved, **Then** future bookings use the new assigned staff member.

---

### User Story 3 - Customer booking remains simple (Priority: P2)

A customer books by selecting a service and time without choosing staff explicitly; assignment happens automatically from the selected service.

**Why this priority**: Booking simplicity reduces drop-off and keeps the existing customer journey intact.

**Independent Test**: Customer books a service that has a valid staff assignment and receives a confirmed booking without extra steps.

**Acceptance Scenarios**:

1. **Given** a customer views bookable services, **When** services are displayed, **Then** only services with valid active staff assignments are shown.
2. **Given** a customer books a service, **When** the booking is confirmed, **Then** the appointment is linked to the service's assigned staff member.
3. **Given** a service becomes unavailable due to inactive or missing staff assignment, **When** customer revisits booking, **Then** that service is no longer bookable.

---

### User Story 4 - Admin filters queue by staff (Priority: P2)

An admin sees staff assignment on each queue entry and can filter the queue view to focus on one staff member while preserving a single shared queue.

**Why this priority**: Staff visibility in queue operations enables faster coordination and fewer assignment mistakes.

**Independent Test**: Admin opens queue view, filters to one staff member, performs queue actions, and clears the filter to return to all entries.

**Acceptance Scenarios**:

1. **Given** queue entries exist, **When** admin views the queue, **Then** each entry shows the assigned staff member.
2. **Given** multiple staff members have entries, **When** admin applies a staff filter, **Then** only matching entries are shown.
3. **Given** a staff filter is active, **When** admin performs queue actions, **Then** actions apply correctly and queue sequence rules remain intact.
4. **Given** admin clears the filter, **When** the view refreshes, **Then** all queue entries are visible again.

---

### Edge Cases

- A service is linked to a staff member who is later deactivated.
- A staff member is removed while an admin currently has that staff filter selected.
- A service is reassigned after customers already booked earlier appointments.
- Two admins update the same service assignment at nearly the same time.
- A queue contains a high mix of appointments across many staff members.
- Contact information for a staff member is incomplete.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow admins to create a staff profile with required name and optional role and contact details.
- **FR-002**: The system MUST allow admins to edit staff profile information and active/inactive status.
- **FR-003**: The system MUST prevent removal of a staff member while they are assigned to active services.
- **FR-004**: The system MUST allow admins to assign each service to exactly one staff member.
- **FR-005**: The system MUST require a valid active staff assignment before a service can be offered for booking.
- **FR-006**: The system MUST apply service reassignment only to future bookings and MUST NOT alter historical appointments.
- **FR-007**: The system MUST keep customer booking flow focused on service and time selection without mandatory staff selection.
- **FR-008**: The system MUST record which staff member is responsible for each booking at the time of confirmation.
- **FR-009**: The queue view MUST display assigned staff for every queue entry.
- **FR-010**: The queue view MUST provide an admin filter for viewing entries by staff member.
- **FR-011**: Queue actions MUST remain consistent whether or not a staff filter is applied.
- **FR-012**: The system MUST provide clear validation and recovery messages for invalid assignments and blocked actions.

### Non-Functional Requirements

- **NFR-001**: Staff-related admin actions MUST feel responsive for typical daily usage volumes.
- **NFR-002**: Queue filtering MUST update quickly enough to support live front-desk operations.
- **NFR-003**: The feature MUST maintain reliability under concurrent admin updates.
- **NFR-004**: The feature MUST preserve existing booking usability and avoid introducing extra customer steps.

### Key Entities *(include if feature involves data)*

- **Staff Member**: Represents a person who delivers services; includes identity, optional role/contact details, and availability status.
- **Service**: Represents a bookable offering that must be owned by exactly one active staff member to remain bookable.
- **Appointment**: Represents a customer booking linked to the staff member assigned to the selected service at booking time.
- **Queue Entry View**: Represents the operational queue item shown to admins, including customer and assigned staff context.

### Assumptions & Dependencies

- Current queue behavior and service management workflows remain available and stable.
- Admin users have sufficient permissions to manage staff and service assignments.
- Organizations adopting this feature need one shared queue view with staff-level filtering rather than separate queues.
- Staff-specific scheduling preferences and customer-selected staff are out of scope for this MVP and may be introduced later.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of admins can complete staff creation and assignment setup on first attempt during acceptance testing.
- **SC-002**: Admins can locate and filter queue entries for a specific staff member within 5 seconds in normal operating conditions.
- **SC-003**: 100% of new confirmed bookings for eligible services include a valid assigned staff member.
- **SC-004**: 100% of services without valid active staff assignments are excluded from customer booking.
- **SC-005**: Service reassignment changes affect only future bookings in all tested scenarios.
- **SC-006**: Customer booking completion rate does not decrease after rollout compared with the pre-feature baseline.

## Out of Scope (This Release)

- Separate queues per staff member.
- Customer ability to explicitly choose preferred staff during booking.
- Staff-specific working hours and personalized availability rules.
- Staff performance analytics and automated staff notifications.
