# Feature Specification: Business Logic & Automation

**Feature Branch**: `006-business-automation`
**Created**: March 15, 2026
**Status**: Draft
**Input**: User description: "Sprint 6: Business Logic & Automation - Time margin enforcement, auto no-show detection, queue advancement automation"

## Clarifications

### Session 2026-03-15

- Q: When should auto no-show eligibility end? → A: Once the admin marks the customer as `serving`, the customer is considered to have shown up and is no longer eligible for auto no-show.
- Q: How should the system behave when a service is missing a valid time margin? → A: Use a global fallback default time margin.
- Q: What should the global fallback default time margin be? → A: 2 minutes.
- Q: What should the admin see before the booked appointment time arrives? → A: Show "Not due yet" until the booked appointment time, then start the no-show countdown.
- Q: What admin actions are allowed before the booked appointment time arrives? → A: The admin cannot mark the customer as skipped, served, or no-show before the booked appointment time.


## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin sees time margin countdown for current customer (Priority: P1)

An admin viewing the queue sees a live countdown timer showing how much time remains in the grace period before the current customer is automatically marked as no-show.

**Why this priority**: Time margin visibility is the foundation for the automation feature. Without a clear countdown, admins cannot anticipate automatic actions or make informed decisions about manual overrides.

**Independent Test**: With a customer at the front of the queue whose booked appointment time has started, the admin opens queue management and sees a countdown timer that decrements in real-time based on the gap between the booked appointment time and the no-show threshold. When the countdown reaches zero, the customer is auto-marked as no-show.

**Acceptance Scenarios**:

1. **Given** a customer is currently first in line and their booked appointment time has not yet arrived, **When** the admin views the queue, **Then** the UI shows "Not due yet" together with the scheduled booking time instead of a no-show countdown.
2. **Given** a customer is currently first in line and their booked appointment time has not yet arrived, **When** the admin views queue actions, **Then** the actions to mark that customer as skipped, served, or no-show are disabled or unavailable.
3. **Given** a customer is currently first in line, **When** the admin views the queue at or after that customer's booked appointment time, **Then** a countdown timer displays the remaining time margin until the customer becomes a no-show (e.g., "5:00 remaining").
4. **Given** a customer's booked appointment time plus the time margin has already passed, **When** the admin views the queue, **Then** the countdown shows "0:00" or "Overdue" and the system auto-triggers no-show.
5. **Given** a customer's service duration varies by service type, **When** the admin views different services' queues, **Then** the countdown uses each service's configured `timeMarginMinutes`.
6. **Given** a service does not have a valid time margin configured, **When** the admin views the queue, **Then** the countdown uses the 2-minute global default time margin.
7. **Given** the countdown reaches zero while admin is viewing and the customer has not been marked `serving`, **When** the timer expires, **Then** the system automatically marks the customer as no-show and advances to the next customer.
8. **Given** admin manually advances (Next) before countdown expires, **When** admin presses Next, **Then** the countdown timer is cleared and normal flow continues.

---

### User Story 2 - Auto no-show detection on queue view (Priority: P2)

When the admin opens the queue management screen, the system automatically evaluates whether the customer at the front of the queue has exceeded the allowed time since their booked appointment time and, if so, triggers the no-show flow without manual intervention.

**Why this priority**: This ensures that even if the admin was away from the app or the device was closed, resuming queue management immediately catches up on overdue customers rather than leaving stale state.

**Independent Test**: A customer has remained at the front of the queue for 15 minutes beyond their booked appointment time plus the configured time margin. The admin opens the queue management screen. The system immediately detects the overdue status and auto-marks the customer as no-show, advancing the queue.

**Acceptance Scenarios**:

1. **Given** the first customer's booked appointment time plus `timeMarginMinutes` is in the past and that customer has not been marked `serving`, **When** the admin opens queue management, **Then** the system auto-marks that customer as no-show.
2. **Given** multiple customers in sequence have exceeded their time margins (e.g., admin was away for an hour), **When** the admin opens queue management, **Then** the system processes one no-show at a time in queue order until reaching a customer who is still within the allowed time window or an empty queue.
3. **Given** the current customer is within their time margin, **When** the admin opens queue management, **Then** no automatic action is taken and the countdown displays normally.
4. **Given** auto no-show is triggered, **When** the system marks the customer as no-show, **Then** a brief visual/toast notification informs the admin of the automatic action.

---

### User Story 3 - Admin can undo auto no-show via rejoin (Priority: P3)

If the system auto-marks a customer as no-show incorrectly (e.g., customer arrived just as countdown expired), the admin can use the existing rejoin functionality to restore the customer to the queue.

**Why this priority**: Auto-actions must be reversible to handle edge cases and maintain admin control. The rejoin flow already exists; this story ensures it integrates seamlessly with auto no-show.

**Independent Test**: After auto no-show, the affected customer appears in the skipped/no-show section. Admin presses Rejoin and the customer is appended to the end of the queue as `inQueue`.

**Acceptance Scenarios**:

1. **Given** a customer was auto-marked as no-show, **When** admin selects Rejoin on that entry, **Then** the customer is restored to `inQueue` at the end of the waiting queue.
2. **Given** multiple customers were auto-marked as no-show in rapid succession, **When** admin views the queue, **Then** all no-show entries are visible in the history/skipped section with Rejoin available for each.
3. **Given** admin rejoins a no-show customer, **When** that customer's turn comes again, **Then** the no-show countdown is recalculated from that customer's current valid booking time and service time margin.

---

### User Story 4 - Customer sees "No longer in queue" message after auto no-show (Priority: P4)

A customer viewing their queue status who has been marked as no-show (manually or automatically) sees a clear message indicating they are no longer actively in the queue.

**Why this priority**: Customer-facing clarity is essential to avoid confusion. Customers should know immediately when they've been marked as no-show so they can contact the business if there's an error.

**Independent Test**: After auto no-show, the customer app refreshes to show "You have been marked as no-show. Please contact the business if you believe this is in error."

**Acceptance Scenarios**:

1. **Given** a customer's status is updated to `noShow`, **When** the customer views their queue status, **Then** they see a distinct "No Show" state instead of queue position.
2. **Given** the customer was still viewing queue status when marked as no-show, **When** the status updates in real-time, **Then** the UI transitions to showing the no-show message without manual refresh.
3. **Given** the customer's appointment is marked no-show, **When** they view queue status, **Then** they see guidance to contact the business (phone number or next steps).

---

### Edge Cases

- Customer's booked appointment time is in the past when the admin first opens the queue for the day.
- Customer is first in line but their booked appointment time is still in the future.
- Admin attempts to mark a future appointment as skipped, served, or no-show before its booked appointment time.
- Time margin is set to 0 minutes on a service (immediate no-show at the booked appointment time if the customer has not shown up).
- Service configuration is missing or contains an invalid time margin; the 2-minute fallback default should be used consistently.
- Customer is marked `serving` just before the no-show deadline; auto no-show should not fire.
- Admin manually marks no-show before the timer expires; should not double-trigger.
- Network failure occurs during auto no-show Firestore write; app should retry or display error.
- Queue has only one customer who is marked as no-show; queue should show empty state cleanly.
- Customer opens queue status seconds before being marked as no-show; transition should be smooth.
- Admin rapidly switches away from and back to queue screen multiple times; should not duplicate no-show actions.
- Customer is checked in or moved forward manually after the booking time has passed but before the time margin expires.

## Requirements *(mandatory)*

### Functional Requirements

#### Time Tracking
- **FR-001**: The system MUST determine each customer's no-show deadline using the booked appointment time plus the configured time margin for that service.
- **FR-002**: The system MUST use a consistent authoritative time source when comparing the current time against the no-show deadline.
- **FR-003**: The system MUST fetch service `timeMarginMinutes` for the customer currently eligible to be called or marked as no-show.
- **FR-004**: When a service-specific time margin is missing or invalid, the system MUST use a single 2-minute global default time margin.

#### Countdown Timer UI
- **FR-005**: The admin queue UI MUST display a live countdown timer for the customer currently at the front of the queue.
- **FR-006**: The countdown MUST decrement in real-time (at least once per second) while the queue screen is visible.
- **FR-007**: When the countdown reaches zero, the UI MUST display "Overdue" or equivalent visual indicator.
- **FR-008**: The countdown calculation MUST use the remaining time between the current moment and the no-show deadline derived from the booked appointment time plus the configured time margin or the global fallback default.
- **FR-009**: Before the booked appointment time arrives, the admin queue UI MUST show a "Not due yet" state with the scheduled booking time instead of starting the no-show countdown.
- **FR-010**: Before the booked appointment time arrives, the admin queue UI MUST prevent the customer at the front of the queue from being marked as skipped, served, or no-show.

#### Auto No-Show Detection
- **FR-011**: On queue screen mount, the system MUST evaluate if the customer at the front of the queue is overdue relative to their booked appointment time and auto-trigger no-show if so, only when that customer has not been marked `serving`.
- **FR-012**: Auto no-show MUST use the existing `markNoShow` repository method to ensure atomic queue advancement.
- **FR-013**: Auto no-show MUST process one overdue entry at a time, re-evaluating after each until the queue is current or empty.
- **FR-014**: Auto no-show MUST display a brief notification (snackbar/toast) informing the admin of the automatic action.
- **FR-015**: The system MUST prevent duplicate no-show triggers if admin rapidly remounts the screen.

#### Queue Advancement
- **FR-016**: After auto no-show, the system MUST automatically promote the next waiting customer to `serving` (handled by existing `markNoShow` transaction).
- **FR-017**: The newly promoted customer's no-show deadline MUST be based on that customer's booked appointment time and service time margin.

#### Customer Visibility
- **FR-018**: When a customer's status is `noShow`, their queue status view MUST display a distinct "No Show" state.
- **FR-019**: The no-show state MUST include guidance for the customer (e.g., "Contact the business").
- **FR-020**: Real-time updates MUST transition the customer's view from queue position to no-show state without delay.

#### Safety and Reversibility
- **FR-021**: All auto no-show actions MUST be reversible via the existing Rejoin functionality.
- **FR-022**: The auto no-show logic MUST be idempotent; retries or reconnects MUST NOT cause duplicate status transitions.
- **FR-023**: Auto no-show MUST NOT trigger if the appointment is already in a terminal state (`completed`, `noShow`, `cancelled`) or has been marked `serving`.

### Key Entities *(include if feature involves data)*

- **Appointment**: Stores the customer's booked appointment time, which is the reference point for no-show evaluation.
- **Queue Entry**: Represents the current customer order and determines which customer's no-show deadline should be evaluated next.
- **Service**: Provides `timeMarginMinutes`, which defines how long after the booked appointment time the customer may remain eligible before being marked as a no-show.

### Assumptions & Dependencies

- Sprint 5 queue management (next, skip, markNoShow, rejoin) is complete and working.
- `timeMarginMinutes` is configured per service when available, and the system uses a single 2-minute global fallback default for missing or invalid values.
- Appointment records already contain a reliable booked appointment time for every queued customer.
- Customer notification upon no-show is deferred to Sprint 7 (FCM notifications).
- Auto no-show is purely client-side triggered; no Cloud Functions are involved in Sprint 6.
- If `timeMarginMinutes` is 0, auto no-show triggers immediately when the booked appointment time is reached and the customer has not shown up.
- Network issues during auto no-show should be handled gracefully; the system will retry on next screen mount.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Admins can see the countdown timer within 1 screen transition after the booked appointment time is reached for the customer currently at the front of the queue.
- **SC-002**: 100% of overdue front-of-queue entries are auto-detected and marked as no-show when admin opens queue management.
- **SC-003**: Auto no-show + queue advancement completes within 3 seconds on standard network conditions.
- **SC-004**: In user acceptance testing, at least 95% of admins correctly understand the countdown timer meaning on first view.
- **SC-005**: Auto-triggered no-shows can be successfully reversed via Rejoin in 100% of test cases.
- **SC-006**: Customers see the no-show state update within 2 seconds of the status change.
- **SC-007**: No duplicate no-show transitions occur in any test scenario involving rapid screen remounts or network retries.
