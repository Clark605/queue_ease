# Contract: Admin Open/Closed Toggle UI

**Feature**: 008-fix-demo-ui (US4)
**Date**: 2026-04-29
**Status**: Complete

## Overview

UI contract for adding quick open/closed toggle to admin dashboard header area, allowing admins to start/end their day with a single tap.

---

## UI Component: Open/Closed Switch

### Location
- **Widget**: Admin dashboard header area (AppBar or top section)
- **Display**: Switch widget + label "Open"/"Closed"

### Behavior
1. **Initial State**: Reflects `OrganizationEntity.isOpen` value (streamed from Firestore)
2. **Toggle Action**: Admin taps switch
3. **Immediate Feedback**: Switch animates to new position (optimistic UI)
4. **Backend Update**: Call `updateOrganization` with new `isOpen` value
5. **Success**: Keep new state
6. **Failure**: Revert switch to previous state, show error snackbar

### Visual Design
- **Open State**: Switch = ON, label "Open" (green color)
- **Closed State**: Switch = OFF, label "Closed" (red/gray color)
- **Loading State**: Switch disabled during update (optional: show small spinner)

---

## State Management

### Cubit State Changes
- **Current State**: DashboardCubit (or similar)
- **Stream**: Watch `OrganizationEntity` for `isOpen` changes
- **Toggle Action**: Call `updateOrganization` use case

### Use Case Contract
```dart
class UpdateOrganizationUseCase {
  Future<Result<void>> call(OrganizationEntity organization);
}
```
Note: Use case already exists, supports updating `isOpen` field.

### Repository Contract
```dart
abstract class OrganizationRepository {
  // ...existing methods...
  Stream<Result<OrganizationEntity>> watchOrganization(String orgId);
  Future<Result<void>> updateOrganization(OrganizationEntity organization);
}
```

---

## Error Handling

| Scenario | Behavior |
|----------|-----------|
| Network error during toggle | Revert switch, show snackbar "Failed to update status. Please try again." |
| Invalid organization ID | Show snackbar "Organization not found." |
| Success | Optional success snackbar "Organization is now open/closed" |

---

## Performance

- **Toggle Response**: Under 2 taps from dashboard (requirement SC-005)
- **Update Time**: <2 seconds (Constitution VI: Writes MUST acknowledge <2s)
- **Optimistic UI**: Switch toggles immediately, reverts only on failure

---

## Accessibility

- Switch: Minimum 48x48 tap target
- Semantic label: "Organization is [open/closed], tap to toggle"
- State change announced to screen reader
- Loading state announced if implemented

---

## Testing Checklist

- [ ] Toggle displays correct initial state (open/closed)
- [ ] Tapping toggle calls updateOrganization with new isOpen value
- [ ] Success keeps new toggle state
- [ ] Network error reverts toggle + shows error snackbar
- [ ] Toggle is reachable in under 2 taps from dashboard
- [ ] Accessibility: screen reader announces state changes
