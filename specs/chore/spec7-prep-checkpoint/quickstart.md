# Quickstart: Fix Demo UI

**Feature**: 008-fix-demo-ui
**Date**: 2026-04-29
**Status**: Complete

## Quick Start Guide

Step-by-step guide to begin implementing the 7 user stories for fixing demo UI issues.

---

## Prerequisites

1. **Branch**: Ensure you're on `008-fix-demo-ui` branch (or create it)
   ```bash
   git checkout -b 008-fix-demo-ui
   ```

2. **Dependencies**: Run `flutter pub get` to ensure all packages are available

3. **Firebase**: Ensure dev environment is configured (`flutter run --flavor dev -t lib/main_dev.dart`)

---

## Implementation Order (Priority-Based)

### P1 Stories (Do First)

#### 1. Customer Booking Cancellation (US1)
**Files to Modify**:
- `lib/features/shared_domain/entities/appointment_entity.dart` - Verify `cancelled` status
- `lib/features/customer/booking/domain/use_cases/` - Add `cancel_appointment_use_case.dart`
- `lib/features/customer/booking/data/repositories/` - Add `cancelAppointment` method
- `lib/features/customer/entry/` or `lib/features/customer/home/` - Add cancel button to UI

**Quick Test**:
1. Create a test appointment with status `inQueue`
2. Verify cancel button appears
3. Tap cancel, confirm dialog
4. Check Firestore - status should be `cancelled`

---

#### 2. Admin Date Navigation (US2)
**Files to Modify**:
- `lib/features/admin/queue_management/presentation/` - Add date picker to QueueManagementPage
- `lib/features/admin/queue_management/presentation/cubit/` - Add `selectedDate` to cubit

**Quick Test**:
1. Open Queue Management page
2. Tap date in AppBar
3. Select different date
4. Verify queue data updates (or empty state shows)

---

#### 3. Fix "See All" Navigation (US3)
**Files to Modify**:
- `lib/features/customer/entry/` or home page - Find "See all" button
- `lib/core/router/app_router.dart` - Verify appointments list route exists

**Quick Test**:
1. Open customer home page
2. Tap "See all"
3. Verify navigation goes to appointments list (not QR scanner)

---

#### 4. Quick Open/Closed Toggle (US4)
**Files to Modify**:
- `lib/features/admin/dashboard/` - Add Switch to header area
- `lib/features/admin/dashboard/presentation/cubit/` - Handle toggle action

**Quick Test**:
1. Open admin dashboard
2. Find open/closed toggle
3. Tap to toggle
4. Verify Firestore updates, toggle reflects new state

---

### P2 Stories (Do After P1)

#### 5. Fix Architecture Issues (US5)
**Files to Modify**:
- `lib/features/admin/queue_management/data/datasources/` - Fix `transactionMarkNoShow` validation
- `lib/features/admin/working_hours_management/data/datasources/` - Fix `AdminWorkingHoursDatasource.saveAll` (batch.update → batch.set with merge)

**Quick Test**:
1. Run app with new organization (no working hours)
2. Save working hours - should create documents (not fail)
3. Test no-show marking with various statuses

---

#### 6. Optimize Wait Timer (US6)
**Files to Modify**:
- Locate `WaitTimerCountdown` widget - Remove Timer.periodic
- Connect to `WatchCustomerQueueStatusUseCase` stream for updates

**Quick Test**:
1. Open customer queue view
2. Verify timer updates on stream emission (not 30s polling)
3. Check no unnecessary timer callbacks in logs

---

#### 7. Quick Wins (US7)
**Files to Modify** (can be done in any order):
- Consolidate PulsingDot: Create `lib/core/widgets/pulsing_dot.dart`, update usages
- Show orgName: Pass to confirmation page, display in UI
- Fix notification dot: Remove or connect to real data in customer home drawer
- Mask Admin ID: Update `lib/features/admin/app_section/` OrganizationProfilePage

**Quick Test**:
1. Check queue list and date header - both use same PulsingDot
2. Complete a booking - confirmation page shows org name
3. Open customer home drawer - notification dot is gone or shows real data
4. View organization profile - Admin ID is masked

---

## Dead UI Elements to Remove/Hide

| Element | Location | Action |
|---------|----------|--------|
| NowServingCard (hardcoded) | Admin dashboard | Connect to real data or remove |
| _StatsStrip (hardcoded) | Admin dashboard | Connect to real data or remove |
| Daily Summary card (snackbar) | Admin dashboard | Navigate to daily summary page or remove |
| Service list search button | Admin service_management | Implement filter or hide |
| Queue filter button | Admin queue_management | Implement filter or hide |
| "Coming soon" items (5) | Admin app_section/settings | Remove if not implemented |

---

## Running & Testing

### Dev Mode
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Test Specific Stories
1. **Cancellation**: Create booking → Home page → Tap cancel
2. **Date Nav**: Queue Management → Tap date → Select date → Verify data
3. **See All**: Customer home → Tap "See all" → Verify appointments list
4. **Toggle**: Admin dashboard → Tap open/closed switch → Verify update

### Check Architecture
```bash
# Verify layer separation
grep -r "import 'package:flutter/" lib/features/*/domain/  # Should be empty
grep -r "import 'package:firebase_" lib/features/*/domain/  # Should be empty
```

---

## Common Pitfalls

1. **Cancellation**: Forgetting to check status before allowing cancel (only `inQueue`/`waiting`)
2. **Date Navigation**: Not handling empty states for dates with no data
3. **See All Fix**: Navigating to wrong route (verify route exists first)
4. **Toggle**: Not reverting on network error (optimistic UI + rollback)
5. **Architecture Fixes**: Breaking existing functionality (test thoroughly)

---

## Next Steps

After implementing all stories:
1. Run `flutter analyze` to check for errors
2. Test all 7 user stories manually
3. Verify no regressions in existing functionality
4. Commit with message: `fix(demo): implement 7 user stories for demo UI fixes`
5. Create PR to `develop` branch
