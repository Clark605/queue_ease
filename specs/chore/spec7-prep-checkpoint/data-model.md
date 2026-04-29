# Data Model: Fix Demo UI

**Feature**: 008-fix-demo-ui
**Date**: 2026-04-29
**Status**: Complete

## Overview

Data model changes required for the 7 user stories. Most changes are behavioral (UI fixes, navigation fixes, architecture fixes) rather than schema changes. Key entity modifications documented below.

---

## Entity Changes

### 1. AppointmentEntity

**Location**: `lib/features/shared_domain/entities/appointment_entity.dart`

**Current Status Field**: `status` (String or enum)

**Required Change**: Ensure `cancelled` is a valid status

**Fields** (existing, no changes unless noted):
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique appointment ID |
| orgId | String | Organization ID |
| serviceId | String | Service ID |
| customerId | String | Customer ID |
| status | String | Current status (must include 'cancelled') |
| scheduledAt | DateTime | Scheduled appointment time |
| createdAt | DateTime | When appointment was created |
| ... | ... | Other existing fields |

**New Status Value**:
- Add `'cancelled'` as valid status (if not already present)
- Cancellable statuses: `'inQueue'`, `'waiting'` (per clarification)
- Non-cancellable: `'inProgress'`, `'completed'`, `'cancelled'`, `'noShow'`

**State Transitions**:
```
[inQueue, waiting] → cancelled (customer-initiated)
```

**Validation Rules**:
- Only allow cancellation if current status is `inQueue` or `waiting`
- Show message "This booking can no longer be cancelled" for other statuses

---

### 2. OrganizationEntity

**Location**: `lib/features/shared_domain/entities/organization_entity.dart`

**Fields** (existing, no schema changes):
| Field | Type | Description |
|-------|------|-------------|
| id | String | Organization ID |
| name | String | Organization name |
| isOpen | bool | Open/closed status (already exists) |
| ... | ... | Other existing fields |

**No Schema Changes Needed**:
- `isOpen` field already exists
- `updateOrganization` use case already supports updating `isOpen`
- Only UI changes needed: add toggle to admin dashboard

---

### 3. WorkingHoursEntity

**Location**: `lib/features/shared_domain/entities/working_hours_entity.dart`

**Fields** (existing, no schema changes):
| Field | Type | Description |
|-------|------|-------------|
| orgId | String | Organization ID |
| dayOfWeek | int | 1=Monday to 7=Sunday |
| isOpen | bool | Whether open on this day |
| openTime | String | Opening time (e.g., "09:00") |
| closeTime | String | Closing time (e.g., "17:00") |
| ... | ... | Other existing fields |

**No Schema Changes Needed**:
- Architecture fix is in data layer (`AdminWorkingHoursDatasource.saveAll`)
- Replace `batch.update` with `batch.set` with `SetOptions(merge: true)`
- Handles both new organizations (no existing docs) and updates

---

## New Use Cases

### 1. CancelAppointmentUseCase

**Location**: `lib/features/customer/booking/domain/use_cases/cancel_appointment_use_case.dart`

**Purpose**: Cancel a customer's appointment

**Input**:
- `appointmentId`: String
- `orgId`: String

**Output**: `Result<void>`

**Logic**:
1. Fetch current appointment
2. Check if status is `inQueue` or `waiting`
3. If yes: update status to `cancelled`
4. If no: return `Result.failure(ValidationException('Cannot cancel appointment with status: $status'))`

**Repository Method** (add to interface):
```dart
Future<Result<void>> cancelAppointment(String orgId, String appointmentId);
```

---

## Model Changes (Firestore Serialization)

### AppointmentModel

**Location**: `lib/features/shared_domain/models/appointment_model.dart`

**No Changes Needed**:
- `cancelled` status is just a string value
- Existing `fromDoc()` and `toMap()` should handle it
- Verify round-trip: `cancelled` string → Firestore → `cancelled` string

---

## Data Flow Changes

### Customer Cancellation Flow
```
Customer Dashboard (UI)
    ↓ tap cancel button
CustomerBookingCubit (or CancelAppointmentCubit)
    ↓ call cancelAppointment()
CancelAppointmentUseCase
    ↓
AppointmentRepository.cancelAppointment()
    ↓
AppointmentRepositoryImpl (Data Layer)
    ↓ update Firestore document
Firestore (status = 'cancelled')
    ↓ stream update
Customer Dashboard (UI refreshes)
```

### Admin Date Navigation Flow
```
QueueManagementPage (UI)
    ↓ tap date picker
QueueManagementCubit (set selectedDate)
    ↓ call watchQueue(orgId, selectedDate)
WatchQueueUseCase
    ↓
QueueRepository.watchQueue()
    ↓ stream
Firestore (query by orgId + date)
    ↓ stream update
QueueManagementPage (UI refreshes with new date's data)
```

### Admin Open/Closed Toggle Flow
```
Admin Dashboard (UI)
    ↓ toggle Switch
DashboardCubit (set isOpen)
    ↓ call updateOrganization()
UpdateOrganizationUseCase
    ↓
OrganizationRepository.updateOrganization()
    ↓
OrganizationRepositoryImpl (Data Layer)
    ↓ update Firestore document
Firestore (isOpen = true/false)
    ↓ stream update
Admin Dashboard (UI refreshes, toggle reflects new state)
```

---

## Validation Rules

### Appointment Cancellation
- **Pre-condition**: Appointment status must be `inQueue` or `waiting`
- **Post-condition**: Appointment status = `cancelled`
- **Error Handling**: Show message "This booking can no longer be cancelled" if wrong status

### Date Navigation
- **Valid Dates**: Any date (past or future)
- **Empty State**: Show "No queue data for this date" if no appointments
- **Error Handling**: Show snackbar with error message on Firestore failure

### Open/Closed Toggle
- **Network Error**: Revert toggle to previous state, show snackbar "Failed to update status"
- **Success**: Toggle reflects new state, optional success snackbar

---

## Performance Considerations

### WaitTimerCountdown Optimization
- **Remove**: `Timer.periodic(Duration(seconds: 30), callback)`
- **Replace with**: Recalculate on `WatchCustomerQueueStatusUseCase` stream emission
- **Benefit**: Eliminates unnecessary polling, reduces battery/CPU usage
- **Real-time**: Firestore streams already provide <500ms updates (per Constitution VI)

---

## Conclusion

Minimal data model changes required:
1. Verify `cancelled` status exists in AppointmentEntity status handling
2. Add `CancelAppointmentUseCase` and repository method
3. Fix `AdminWorkingHoursDatasource.saveAll` (batch.update → batch.set with merge)
4. Fix `transactionMarkNoShow` validation
5. All other changes are UI/behavioral (no schema changes)
