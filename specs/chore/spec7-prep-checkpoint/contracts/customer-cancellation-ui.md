# Contract: Customer Booking Cancellation UI

**Feature**: 008-fix-demo-ui (US1)
**Date**: 2026-04-29
**Status**: Complete

## Overview

UI contract for adding cancellation capability to customer's appointment view on the home page.

---

## UI Component: Cancel Button

### Location
- **Widget**: Customer appointment card in `lib/features/customer/entry/` or `lib/features/customer/home/`
- **Visibility**: Only shown when appointment status is `inQueue` or `waiting`

### Behavior
1. **Display**: Show cancel button/icon next to appointment details
2. **Tap Action**: Show confirmation dialog
3. **Confirmation Dialog**:
   - Title: "Cancel Appointment"
   - Message: "Are you sure you want to cancel this appointment?"
   - Buttons: "No, Keep It" (default), "Yes, Cancel" (destructive style)
4. **On Confirm**: Call cancellation use case, update UI
5. **On Cancel**: Dismiss dialog, no action

### Validation Messages
| Scenario | Message |
|----------|---------|
| Status not cancellable (e.g., `inProgress`, `completed`) | "This booking can no longer be cancelled." |
| Network error during cancellation | "Failed to cancel appointment. Please try again." |
| Success | "Appointment cancelled successfully." (snackbar) |

---

## State Management

### Cubit State Changes
- **Current State**: `CustomerDashboardLoaded` (or similar)
- **New State**: Add `isCancelling: bool` flag to show loading state
- **Transition**: `Loaded` → `Cancelling` → `Loaded` (with updated appointment)

### Use Case Contract
```dart
class CancelAppointmentUseCase {
  Future<Result<void>> call(String orgId, String appointmentId);
}
```

### Repository Contract
```dart
abstract class AppointmentRepository {
  // ...existing methods...
  Future<Result<void>> cancelAppointment(String orgId, String appointmentId);
}
```

---

## Navigation

**No navigation changes**: Cancellation happens in-place on the home page (requirement: "under 3 taps from home page").

---

## Accessibility

- Cancel button: Minimum 48x48 tap target
- Confirmation dialog: Focus managed, screen reader announces "Cancel Appointment dialog"
- Loading state: Announced to screen reader

---

## Testing Checklist

- [ ] Cancel button only shows for `inQueue` and `waiting` statuses
- [ ] Confirmation dialog appears on tap
- [ ] "No, Keep It" dismisses dialog
- [ ] "Yes, Cancel" triggers cancellation
- [ ] Success snackbar shows on successful cancellation
- [ ] Error message shows for non-cancellable statuses
- [ ] Error message shows on network failure
