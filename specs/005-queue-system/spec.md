# Feature Specification: Queue System

**Feature Branch**: `005-queue-system`  
**Created**: March 14, 2026  
**Status**: Draft  
**Input**: User description: "start the specification of sprint 5 (queue system)"

## Clarifications

### Session 2026-03-14

- Q: Which appointment statuses should be eligible to generate an active queue entry? → A: Only `booked` appointments for today.
- Q: How should skipped customers rejoin queue? → A: Admin can rejoin skipped customers at the end of the queue.
- Q: How should concurrent admin queue actions resolve? → A: Single admin per organization; concurrent admin actions are out of scope.
- Q: What should wait-time estimation use? → A: Sum the service durations of queue entries ahead.
- Q: What queue details should customers see? → A: Only own status plus a current-serving indicator; no other customer identities.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin manages daily queue progression (Priority: P1)

An admin can open today's queue, see customers in order, and perform queue actions (next, skip, no-show) so operations continue smoothly throughout the day.

**Why this priority**: Queue control is the operational core of Sprint 5. Without admin progression controls, booked appointments cannot be served in a managed sequence.

**Independent Test**: With existing appointments for today, an admin opens queue management, performs next/skip/no-show actions, and the queue order/status updates immediately and consistently.

**Acceptance Scenarios**:

1. **Given** today has at least one queued customer, **When** the admin opens queue management, **Then** the current customer and upcoming customers are shown in a clear ordered list.
2. **Given** a current customer is being served, **When** the admin selects next, **Then** the current customer is marked served and the next waiting customer becomes current.
3. **Given** a current customer does not respond, **When** the admin selects skip, **Then** that customer is marked skipped and the next waiting customer becomes current.
4. **Given** a current customer misses their turn window, **When** the admin selects no-show, **Then** that customer is marked no-show and removed from active waiting order.
5. **Given** there are no waiting customers, **When** the admin opens the queue, **Then** an empty-state message indicates no active queue entries.

---

### User Story 2 - Customer tracks live queue status (Priority: P2)

A customer with an active appointment can view their queue status, including current position and estimated wait time, and receive live updates as the queue changes.

**Why this priority**: Customer visibility is the primary value proposition of queue management. It reduces uncertainty and improves customer arrival timing.

**Independent Test**: A customer with a queued appointment opens queue status and sees their position and wait estimate; after admin actions, the customer view updates without manual refresh.

**Acceptance Scenarios**:

1. **Given** a customer has a queued appointment for today, **When** they open queue status, **Then** they can see their current position and appointment state.
2. **Given** queue order changes due to admin actions, **When** the customer remains on the queue status screen, **Then** the displayed position updates automatically.
3. **Given** the customer becomes current, **When** queue status updates, **Then** the interface clearly indicates it is their turn.
4. **Given** the customer has no active queue entry for today, **When** they open queue status, **Then** they see a clear message that they are not currently in queue.
5. **Given** other customers are in the queue, **When** a customer views queue status, **Then** they see only their own status and current-serving indicator, without other customers' identities.

---

### User Story 3 - System generates queue from appointments (Priority: P3)

The system creates and maintains a daily queue based on valid appointments so admins and customers operate from one consistent source of truth.

**Why this priority**: Queue behavior depends on accurate queue generation. If queue entries are not generated correctly, admin actions and customer status become unreliable.

**Independent Test**: For a day with multiple valid appointments, queue entries are generated in scheduled-time order once per appointment, excluding ineligible appointments.

**Acceptance Scenarios**:

1. **Given** confirmed appointments exist for today, **When** queue generation runs, **Then** queue entries are created in chronological scheduled-time order.
2. **Given** an appointment has already been served, canceled, or marked no-show, **When** queue generation runs, **Then** no new active queue entry is created for that appointment.
3. **Given** queue generation runs multiple times, **When** the system checks existing entries, **Then** duplicate active queue entries are not created for the same appointment.

---

### User Story 4 - Wait time estimate is understandable and stable (Priority: P4)

Both admin and customer can view an estimated wait time that updates as queue progression changes while remaining understandable and predictable.

**Why this priority**: Estimated wait time is essential for customer trust and operational planning, but it depends on consistent queue progression and timing assumptions.

**Independent Test**: With a queue of known service durations, wait estimates are shown for each waiting customer and adjust after next/skip/no-show actions.

**Acceptance Scenarios**:

1. **Given** at least two waiting customers, **When** queue status is displayed, **Then** each waiting customer has an estimated wait time based on current queue order.
2. **Given** admin advances the queue, **When** status refreshes, **Then** wait estimates are recalculated and displayed consistently for remaining customers.
3. **Given** the queue is empty, **When** queue status is displayed, **Then** no misleading wait estimate is shown.

### Edge Cases

- Appointments exist for today, but all are already completed/canceled/no-show.
- The same admin retries an action after temporary connectivity loss and the system must avoid duplicate status transitions.
- A customer opens queue status for a past appointment date.
- Queue action succeeds for admin but customer device is temporarily offline and reconnects later.
- A skipped customer is rejoined by admin and must be appended to the end of the waiting queue.
- Service duration data is missing or invalid for one appointment.

## Requirements *(mandatory)*

### Functional Requirements

#### Queue Generation
- **FR-001**: The system MUST generate daily queue entries from valid appointments for the selected organization and date.
- **FR-002**: Queue generation MUST preserve chronological order by scheduled appointment time.
- **FR-003**: Queue generation MUST prevent duplicate active queue entries for the same appointment.
- **FR-004**: The system MUST treat only appointments with status `booked` and scheduled for today as eligible for active queue participation.

#### Admin Queue Operations
- **FR-005**: Admins MUST be able to view the current queue for today, including current and waiting customers.
- **FR-006**: Admins MUST be able to mark the current queue entry as served.
- **FR-007**: Admins MUST be able to skip the current queue entry.
- **FR-008**: Admins MUST be able to mark the current queue entry as no-show.
- **FR-009**: After each admin action, the system MUST promote the next eligible waiting entry as current.
- **FR-010**: Queue action processing MUST be atomic so retries, duplicate taps, or stale client state cannot produce duplicate or conflicting queue transitions.
- **FR-021**: Admins MUST be able to rejoin a skipped customer, and rejoined customers MUST be appended to the end of the current waiting queue.

#### Customer Queue Visibility
- **FR-011**: Customers MUST be able to view their active queue status for today.
- **FR-012**: Customer status MUST include queue position and current appointment/queue state.
- **FR-013**: Queue status MUST update in near real-time when queue order or state changes.
- **FR-014**: Customers MUST receive clear empty-state messaging when no active queue entry exists.
- **FR-022**: Customer queue views MUST expose only the authenticated customer's own queue details plus a current-serving indicator, and MUST NOT expose other customers' identities.

#### Wait Time Estimation
- **FR-015**: The system MUST provide an estimated wait time for waiting customers by summing the service durations of all active queue entries ahead of them.
- **FR-016**: Wait time estimates MUST be recalculated whenever queue progression changes.
- **FR-017**: Wait time estimates MUST never display negative values.

#### Reliability, Security, and Scope Boundaries
- **FR-018**: Queue data shown to a user MUST be limited to organizations and appointments they are authorized to access.
- **FR-019**: Errors in queue generation or queue actions MUST return explicit, user-facing failure states and preserve traceable operational logs.
- **FR-020**: Sprint 5 scope MUST include queue generation, admin queue management, customer queue status, and wait time estimation; automated notifications and full performance optimization are out of scope.

### Key Entities *(include if feature involves data)*

- **Queue Entry**: Represents one appointment's position in the active daily queue; includes appointment reference, order position, current state, and timestamps needed for progression.
- **Appointment**: Represents the scheduled customer booking that may become a queue entry; provides service duration, scheduled time, and eligibility state.
- **Queue Snapshot**: Represents the current ordered queue view for a specific organization/date, including current entry, waiting entries, and aggregate metadata for status displays.

### Assumptions & Dependencies

- Sprint 4 booking flow remains the source of truth for appointment creation.
- Queue behavior is initially focused on same-day operational queues.
- Queue generation eligibility is limited to today's appointments with status `booked`.
- One organization has one active daily queue context.
- Exactly one admin manages queue actions per organization in Sprint 5 scope.
- Business policy for skipped-entry rejoin is an explicit admin action and always appends the customer to the end of the waiting queue.
- Wait-time estimation is computed as the sum of durations for active entries ahead in the queue order.
- Notification delivery for turn alerts is deferred to a later sprint.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Admins can complete a queue action (next/skip/no-show) in 3 taps or fewer from the queue screen.
- **SC-002**: In user acceptance testing, at least 95% of queue actions result in correct next-customer promotion without manual correction.
- **SC-003**: Customers see queue position updates within 2 seconds for at least 95% of queue state changes under normal network conditions.
- **SC-004**: For a day with up to 100 appointments, queue generation completes and produces an ordered, duplicate-free queue in all validation runs.
- **SC-005**: At least 90% of tested customers can correctly interpret their queue state and estimated wait time on first view.
