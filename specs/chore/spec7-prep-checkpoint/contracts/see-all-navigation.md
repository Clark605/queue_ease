# Contract: "See All" Navigation Fix

**Feature**: 008-fix-demo-ui (US3)
**Date**: 2026-04-29
**Status**: Complete

## Overview

Fix navigation bug where "See all" button on customer home navigates to QR scanner (Routes.customerAccess) instead of appointments list.

---

## Current Behavior (Bug)

- **Location**: Customer home page (WatchCustomerDashboardUseCase)
- **UI Element**: "See all" button/text
- **Current Navigation Target**: `Routes.customerAccess` (QR scanner)
- **Expected Navigation Target**: Appointments list page

---

## Fixed Behavior

### Navigation Target
- **Route**: `Routes.customerAppointments` (or similar, to be verified in GoRouter config)
- **Page**: Customer appointments list page (showing all bookings)

### Verification Steps
1. Check `lib/core/router/app_router.dart` for existing appointments list route
2. If route doesn't exist, create it (out of scope? Per spec: "no new features", but navigation fix requires destination)
3. Update "See all" onPressed/onTap to navigate to correct route

---

## Route Contract

### Expected Route Definition (in app_router.dart)
```dart
GoRoute(
  path: '/c/appointments',
  name: 'customerAppointments',
  builder: (context, state) => const CustomerAppointmentsPage(),
  // Add RBAC guard if needed
)
```

### Navigation Call
```dart
// Before (buggy):
context.go(Routes.customerAccess);

// After (fixed):
context.go(Routes.customerAppointments); // or '/c/appointments'
```

---

## Acceptance Criteria

| Scenario | Expected Result |
|----------|------------------|
| Customer taps "See all" | Navigates to appointments list page |
| Appointments list page | Shows all customer's bookings |
| Navigation accuracy | 100% (requirement SC-004) |

---

## Testing Checklist

- [ ] "See all" button exists on customer home page
- [ ] Tapping "See all" navigates to appointments list (not QR scanner)
- [ ] Appointments list page displays customer's bookings
- [ ] Navigation works consistently (100% accuracy)
- [ ] Back button returns to home page
