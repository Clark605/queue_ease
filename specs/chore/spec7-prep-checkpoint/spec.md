# Feature Specification: Fix Demo UI

**Feature Branch**: `008-fix-demo-ui`  
**Created**: 2026-04-29  
**Status**: Draft  
**Input**: User description: "Looking through the codebase carefully, here are the most impactful issues and suggestions, grouped by severity: [Critical dead UI elements like NowServingCard hardcoded, _StatsStrip hardcoded numbers, Daily Summary card showing snackbar, service list search button dead, queue management filter button dead, settings page with 5 'Coming soon' items, customer can't cancel booking, admin no date navigation in queue management, WatchCustomerDashboardUseCase 'See all' navigates to QR scanner instead of appointments list, no open/closed quick toggle on admin dashboard, transactionMarkNoShow validation issue, AdminWorkingHoursDatasource.saveAll uses batch.update incorrectly, WaitTimerCountdown polls every 30 seconds unnecessarily, and various quick wins]"

## Clarifications

### Session 2026-04-29

- Q: What booking statuses should be cancellable? → A: Allow cancellation only for 'inQueue' and 'waiting' statuses, show message for others
- Q: What should be out-of-scope for this spec? → A: Only fix existing issues listed, no enhancements or new features

## User Scenarios & Validation

### User Story 1 - Enable Customer Booking Cancellation (Priority: P1)

Customers can create appointments but have no way to cancel them from their side. Once createAppointment fires, the customer has no recourse.

**Why this priority**: Core user journey gap — users must be able to cancel bookings they've made. This is a basic expectation for any booking system.

**Independent Validation**: Can be validated by adding a cancel action to the customer dashboard that sets status to a cancelled state.

**Acceptance Scenarios**:

1. **Given** a customer has an active booking, **When** they view their appointment on the home page, **Then** they see a cancel option
2. **Given** a customer taps cancel on their booking, **When** they confirm the cancellation, **Then** the appointment status is updated to cancelled

---

### User Story 2 - Add Admin Date Navigation to Queue Management (Priority: P1)

QueueManagementPage is locked to DateTime.now(). Admins cannot check tomorrow's bookings or yesterday's completed queue.

**Why this priority**: Admins need to view historical data and prepare for upcoming days. The watchQueue use case already accepts a date parameter.

**Independent Validation**: Can be validated by adding a date picker to the AppBar since watchQueue already accepts a date parameter.

**Acceptance Scenarios**:

1. **Given** admin is on the queue management page, **When** they tap a date navigation control, **Then** they can select a different date
2. **Given** admin selects a different date, **When** the page updates, **Then** they see queue data for the selected date

---

### User Story 3 - Fix "See All" Navigation on Customer Home (Priority: P1)

WatchCustomerDashboardUseCase's "See all" navigates to Routes.customerAccess (QR scanner) instead of an appointments list. Users tapping "See all" expect a list, not a camera.

**Why this priority**: Navigation bug that confuses users — expectation mismatch between UI label and actual behavior.

**Independent Validation**: Can be validated by changing the navigation target to an appointments list route.

**Acceptance Scenarios**:

1. **Given** customer is on the home page, **When** they tap "See all", **Then** they navigate to an appointments list

---

### User Story 4 - Add Quick Open/Closed Toggle to Admin Dashboard (Priority: P1)

OrganizationEntity.isOpen field exists and updateOrganization supports it, but there's no way to toggle it from the dashboard.

**Why this priority**: Simple but high-value feature for admins to start/end their day with a single tap.

**Independent Validation**: Can be validated by adding a switch in the header area of the dashboard.

**Acceptance Scenarios**:

1. **Given** admin is on the dashboard, **When** they view the header area, **Then** they see a toggle for the organization's open/closed status
2. **Given** admin toggles the open/closed switch, **When** the toggle is tapped, **Then** the organization's open/closed status is updated

---

### User Story 5 - Fix Architecture Issues (Priority: P2)

transactionMarkNoShow validates status == 'inQueue' but transactionMarkOverdueNoShow just calls it, causing potential silent failure loops. AdminWorkingHoursDatasource.saveAll uses batch.update which fails for new orgs.

**Why this priority**: These are backend issues that can cause silent failures and poor user experience, but don't affect the UI directly.

**Independent Validation**: Can be validated by fixing the validation logic and using batch.set with merge option.

**Acceptance Scenarios**:

1. **Given** a queue item has a status that prevents no-show marking, **When** an automatic no-show process runs, **Then** it handles the status appropriately without throwing errors
2. **Given** a new organization has no working hours documents, **When** working hours are saved, **Then** the documents are created properly

---

### User Story 6 - Optimize Wait Timer Polling (Priority: P2)

WaitTimerCountdown polls every 30 seconds via Timer.periodic, but queue status is already real-time via Firestore streams.

**Why this priority**: Performance optimization that reduces unnecessary timer callbacks when real-time updates are already available.

**Independent Validation**: Can be validated by reducing poll interval to 60 seconds or removing timer and recalculating on WatchCustomerQueueStatusUseCase emission.

**Acceptance Scenarios**:

1. **Given** a customer is viewing their queue position, **When** the wait timer is active, **Then** it updates appropriately without unnecessary polling

---

### User Story 7 - Quick Wins (Priority: P2)

Various small improvements: consolidate PulsingDot components, show orgName on confirmation page, fix customer home drawer notification dot, and mask Admin ID in OrganizationProfilePage.

**Why this priority**: Low effort, high polish improvements that improve the overall feel of the app.

**Independent Validation**: Can be validated individually by implementing each small fix.

**Acceptance Scenarios**:

1. **Given** user views queue list and date header, **When** they see animated dots, **Then** both use the same consistent component
2. **Given** customer completes a booking, **When** they see the confirmation page, **Then** the organization name is displayed
3. **Given** customer opens the home drawer, **When** they see the notification dot, **Then** it is either removed or connected to real data
4. **Given** admin views organization profile, **When** they see Admin ID, **Then** it shows a masked/truncated version

---

## Out of Scope

The following items are **explicitly out of scope** for this specification:
- No new features (e.g., notifications, multi-staff support, analytics dashboard)
- No major UI redesigns or architectural refactoring beyond fixing identified issues
- No new integrations or third-party services
- Only the 7 listed user stories are in scope; enhancements beyond these are deferred

---

## Edge Cases

- What happens when a customer tries to cancel a booking that's already being served or completed? Show message: "This booking can no longer be cancelled."
- How does date navigation handle dates with no queue data? Should show empty state, not error.
- What happens when organization isOpen toggle fails (network error)? Should show error message and revert toggle.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Service list search button MUST either implement client-side filtering or be hidden
- **FR-002**: Queue management filter button MUST either implement status filter or be hidden
- **FR-003**: Customers MUST be able to cancel their bookings from the customer home page (only for 'inQueue' and 'waiting' statuses; show message for other statuses)
- **FR-004**: Admin queue management MUST allow date navigation to view historical or future queue data
- **FR-005**: Customer home "See all" button MUST navigate to appointments list
- **FR-006**: Admin dashboard MUST provide a quick toggle for organization open/closed status
- **FR-007**: No-show marking MUST handle status validation gracefully when called automatically
- **FR-008**: Working hours save MUST handle new organizations properly
- **FR-009**: Wait timer SHOULD update appropriately without unnecessary polling
- **FR-010**: Confirmation page MUST display organization name
- **FR-011**: Organization profile MUST display masked/truncated Admin ID instead of raw ID

### Key Entities *(include if feature involves data)*

- **Organization**: Contains open/closed status field that should be toggleable from admin dashboard
- **Appointment**: Represents customer bookings that should be cancellable
- **Working Hours**: Documents that should be created/updated properly to handle new organizations

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of buttons and interactive elements on admin dashboard perform their intended actions or are hidden if unimplemented
- **SC-002**: Customers can cancel a booking in under 3 taps from the home page
- **SC-003**: Admin can navigate to any date in queue management and see data within 1 second
- **SC-004**: Customer home "See all" navigates to appointments list with 100% accuracy
- **SC-005**: Admin can toggle organization open/closed status in under 2 taps from dashboard
- **SC-006**: Architecture issues are fixed with zero silent failures
- **SC-007**: User satisfaction improves as measured by elimination of "demo-like" UI elements

## Assumptions

- Queue data access already accepts a date parameter, so adding date navigation is straightforward
- Organization has an open/closed status field and update method that already exist and work correctly
- Customer booking cancellation can set status to a cancelled state
- The project uses a consistent state management pattern, so UI updates should follow existing patterns
- Real-time data streams are available, so reducing unnecessary polling is safe
