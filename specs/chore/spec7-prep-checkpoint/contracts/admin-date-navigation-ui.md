# Contract: Admin Date Navigation UI

**Feature**: 008-fix-demo-ui (US2)
**Date**: 2026-04-29
**Status**: Complete

## Overview

UI contract for adding date navigation to QueueManagementPage, allowing admins to view historical or future queue data.

---

## UI Component: Date Picker

### Location
- **Widget**: QueueManagementPage AppBar
- **Trigger**: Icon button (calendar icon) or tappable date text

### Behavior
1. **Display**: Show currently selected date in AppBar (format: "MMM d, yyyy" e.g., "Apr 29, 2026")
2. **Tap Action**: Open `showDatePicker` dialog
3. **Date Picker Config**:
   - Initial date: `selectedDate` (defaults to `DateTime.now()`)
   - First date: No restriction (allow historical dates)
   - Last date: No restriction (allow future dates)
4. **On Date Selected**: Update `selectedDate`, refresh queue data
5. **On Cancel**: Dismiss picker, no action

### Empty State
- **When**: No appointments exist for selected date
- **Display**: Centered message "No queue data for this date"
- **Icon**: Calendar icon (optional)

---

## State Management

### Cubit State Changes
- **Current State**: QueueManagementCubit
- **New State Field**: `selectedDate` (DateTime, defaults to `DateTime.now()`)
- **Transition**: Date change → `Loading` → `Loaded` (with new date's data)

### Use Case Contract
```dart
class WatchQueueUseCase {
  Stream<Result<List<AppointmentEntity>>> call(String orgId, {DateTime? date});
}
```
Note: `date` parameter already exists in use case.

---

## Navigation

**No navigation changes**: Date selection happens in-place on QueueManagementPage.

---

## Performance

- **Data Refresh**: <1 second (requirement SC-003)
- **Real-time**: Firestore stream updates automatically when date changes
- **Caching**: Firestore cached queries may speed up historical data retrieval

---

## Accessibility

- Date display: Tappable with semantic label "Select date, current: [date]"
- Date picker: Standard Flutter date picker (accessibility built-in)
- Empty state: Announced to screen reader

---

## Testing Checklist

- [ ] Date displays correctly in AppBar
- [ ] Tapping date opens date picker
- [ ] Selecting date updates displayed data
- [ ] Empty state shows for dates with no data
- [ ] Data refreshes within 1 second
- [ ] Date picker dismisses on cancel
