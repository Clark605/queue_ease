# Research: Fix Demo UI

**Feature**: 008-fix-demo-ui
**Date**: 2026-04-29
**Status**: Complete

## Overview

Research findings for fixing demo UI issues in Queue Ease. 7 user stories (4 P1, 3 P2) addressing dead UI elements, missing user journeys, and architecture/performance issues.

---

## Research Findings

### 1. Customer Booking Cancellation (P1 - US1)

**Decision**: Add `cancelAppointment` use case in `features/customer/booking/domain/`

**Rationale**:
- Customers currently have no way to cancel bookings - core journey gap
- Only allow cancellation for `inQueue` and `waiting` statuses (per clarification)
- Set status to `cancelled` state (need to verify this status exists in AppointmentEntity)
- UI: Add cancel button to customer dashboard appointment card

**Alternatives considered**:
- Adding cancellation to a separate "My Appointments" page → Rejected: Adds navigation step, spec requires "under 3 taps from home page"
- Admin-only cancellation → Rejected: Doesn't solve customer pain point

**Implementation Approach**:
1. Add `cancelAppointment` method to `AppointmentRepository` interface (domain layer)
2. Implement in `AppointmentRepositoryImpl` (data layer) - update Firestore document status field
3. Create `CancelAppointmentUseCase` (domain layer)
4. Add cancellation logic to `CustomerBookingCubit` or create dedicated cubit
5. Update UI to show cancel button for eligible appointments

---

### 2. Admin Date Navigation (P1 - US2)

**Decision**: Add date picker to QueueManagementPage AppBar, leverage existing `watchQueue` date parameter

**Rationale**:
- `watchQueue` use case already accepts `DateTime? date` parameter - backend support exists
- QueueManagementPage currently hardcoded to `DateTime.now()`
- Date picker in AppBar provides intuitive UX

**Alternatives considered**:
- Horizontal scrolling date selector → Rejected: More complex, AppBar date picker is standard Flutter pattern
- Calendar view → Rejected: Overkill for queue management, date picker is sufficient

**Implementation Approach**:
1. Add `selectedDate` state to QueueManagementCubit
2. Add date picker trigger in AppBar (icon button or text tap)
3. Pass `selectedDate` to `watchQueue` use case
4. Handle empty states for dates with no queue data

---

### 3. Fix "See All" Navigation (P1 - US3)

**Decision**: Change WatchCustomerDashboardUseCase "See all" navigation from `Routes.customerAccess` to appointments list route

**Rationale**:
- Current behavior navigates to QR scanner (customerAccess) - confusing for users
- Users expect "See all" to show list of their appointments
- Need to verify appointments list route exists in GoRouter configuration

**Alternatives considered**:
- Remove "See all" button → Rejected: Users need way to see all appointments
- Navigate to booking page → Rejected: "See all" implies viewing, not creating

**Implementation Approach**:
1. Identify correct appointments list route in `lib/core/router/app_router.dart`
2. Update "See all" onPressed/onTap to navigate to correct route
3. Verify route exists and is accessible to customers

---

### 4. Quick Open/Closed Toggle (P1 - US4)

**Decision**: Add Switch widget to admin dashboard header area, connected to `OrganizationEntity.isOpen`

**Rationale**:
- `OrganizationEntity.isOpen` field exists
- `updateOrganization` use case supports updating isOpen
- Quick toggle in header = under 2 taps (requirement SC-005)

**Alternatives considered**:
- Settings page toggle only → Rejected: Doesn't meet "under 2 taps from dashboard" requirement
- Dialog-based toggle → Rejected: More taps, less intuitive than switch

**Implementation Approach**:
1. Add Switch widget to dashboard AppBar or header section
2. Connect to `OrganizationEntity.isOpen` stream from Firestore
3. On toggle, call `updateOrganization` with updated isOpen value
4. Handle error states (network failure → revert toggle, show snackbar)

---

### 5. Architecture Fixes (P2 - US5)

#### 5a. transactionMarkNoShow Validation

**Decision**: Fix validation in `transactionMarkNoShow` to handle status check gracefully

**Rationale**:
- Current validation: `status == 'inQueue'` 
- `transactionMarkOverdueNoShow` calls it but may fail silently for wrong statuses
- Need to ensure graceful handling without throwing/crashing

**Implementation Approach**:
1. Review `transactionMarkNoShow` in data layer
2. Add proper status validation with Result<T> return
3. Ensure `transactionMarkOverdueNoShow` handles failure cases

#### 5b. AdminWorkingHoursDatasource.saveAll

**Decision**: Replace `batch.update` with `batch.set` with merge option for new organizations

**Rationale**:
- `batch.update` fails for non-existent documents (new orgs have no working hours docs)
- `batch.set` with `SetOptions(merge: true)` handles both create and update

**Implementation Approach**:
1. Locate `AdminWorkingHoursDatasource.saveAll` in data layer
2. Replace `batch.update(doc.ref, data)` with `batch.set(doc.ref, data, SetOptions(merge: true))`
3. Test with new organization (no existing working hours)

---

### 6. Wait Timer Polling Optimization (P2 - US6)

**Decision**: Remove Timer.periodic from WaitTimerCountdown, recalculate on WatchCustomerQueueStatusUseCase stream emission

**Rationale**:
- Queue status already real-time via Firestore streams
- 30s polling is unnecessary overhead
- Recalculating on stream emission is more efficient and responsive

**Alternatives considered**:
- Increase poll interval to 60s → Rejected: Still unnecessary with real-time streams
- Keep timer but make it configurable → Rejected: Adds complexity without benefit

**Implementation Approach**:
1. Review WaitTimerCountdown widget
2. Remove Timer.periodic logic
3. Recalculate elapsed/wait time when stream emits new state
4. Dispose any remaining timers properly

---

### 7. Quick Wins (P2 - US7)

#### 7a. Consolidate PulsingDot Components

**Decision**: Create single `PulsingDot` widget in `core/widgets/`, update all usages

**Rationale**:
- Multiple PulsingDot implementations likely exist (queue list, date header)
- Consolidation reduces duplication, ensures consistent animation

**Implementation Approach**:
1. Search for all PulsingDot implementations
2. Create unified widget in `core/widgets/pulsing_dot.dart`
3. Replace all usages with unified widget

#### 7b. Show orgName on Confirmation Page

**Decision**: Pass `orgName` to confirmation page, display in UI

**Rationale**:
- Confirmation page currently lacks organization name
- Customers need confirmation of which organization they booked with

**Implementation Approach**:
1. Check confirmation page route parameters
2. Pass orgName from booking flow
3. Display orgName in confirmation UI

#### 7c. Fix Customer Home Drawer Notification Dot

**Decision**: Either remove notification dot or connect to real data (e.g., unread notifications count)

**Rationale**:
- Dead notification dot is misleading UI
- Either remove it or make it functional

**Implementation Approach**:
1. Locate notification dot in customer home drawer
2. Either remove it entirely or connect to real notification data source

#### 7d. Mask Admin ID in OrganizationProfilePage

**Decision**: Display masked/truncated Admin ID (e.g., "ABC123...XYZ" or first 8 chars + ellipsis)

**Rationale**:
- Raw Admin ID exposed in UI is security/privacy concern
- Masked ID still allows visual verification without full exposure

**Implementation Approach**:
1. Locate Admin ID display in OrganizationProfilePage
2. Apply masking: show first 8 characters + "..." or use similar pattern
3. Optionally show full ID on long press (for support scenarios)

---

## Dead UI Elements to Remove/Hide

### FR-001: Service List Search Button
- **Current**: Search button exists but does nothing
- **Fix**: Either implement client-side filtering OR hide the button

### FR-002: Queue Management Filter Button
- **Current**: Filter button exists but does nothing  
- **Fix**: Either implement status filter OR hide the button

### NowServingCard (Hardcoded)
- **Current**: Displays hardcoded data
- **Fix**: Connect to real queue data OR remove if unused

### _StatsStrip (Hardcoded Numbers)
- **Current**: Shows hardcoded statistics
- **Fix**: Connect to real data from Firestore OR remove

### Daily Summary Card (Snackbar)
- **Current**: Tapping card shows snackbar instead of navigation
- **Fix**: Navigate to daily summary page OR remove card

### Settings Page "Coming Soon" Items
- **Current**: 5 items show "Coming soon" 
- **Fix**: Remove items that aren't implemented (per out-of-scope: no new features)

---

## Technical Dependencies

| Component | Dependency | Notes |
|-----------|-------------|-------|
| Customer Cancellation | AppointmentRepository, AppointmentEntity | Need to verify `cancelled` status exists |
| Date Navigation | watchQueue use case | Already accepts date parameter |
| See All Fix | GoRouter config | Need to find correct appointments list route |
| Open/Closed Toggle | OrganizationEntity, updateOrganization | Field and use case exist |
| Architecture Fixes | transactionMarkNoShow, AdminWorkingHoursDatasource | Located in data layer |
| Wait Timer | WatchCustomerQueueStatusUseCase | Real-time stream available |
| Quick Wins | Various UI components | Search, identify, and modify |

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| AppointmentEntity doesn't have `cancelled` status | High - Cancellation won't work | Check entity, add status if needed |
| Appointments list route doesn't exist | Medium - See All fix blocked | Create route or navigate to alternative |
| Multiple PulsingDot implementations hard to consolidate | Low - More work, same outcome | Create unified widget, gradually migrate |
| Organization profile doesn't show Admin ID | Low - Masking not needed | Verify field exists before implementing |

---

## Conclusion

All 7 user stories have clear implementation paths. No "NEEDS CLARIFICATION" items remain. P1 stories (cancellation, date nav, See All fix, toggle) should be implemented first, followed by P2 stories (architecture, performance, quick wins).
