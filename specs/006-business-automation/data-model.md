# Data Model: Business Logic & Automation

## Overview

Sprint 6 does not introduce a new top-level Firestore collection. It refines how existing appointment, queue, and service data are interpreted and displayed, and it adds derived automation state used by the admin queue UI and customer queue status UI.

## Entities

### 1. Appointment

- Source: `lib/features/shared_domain/entities/appointment_entity.dart`
- Persistence: `organizations/{orgId}/appointments/{appointmentId}`
- Purpose: Canonical source of booking time and operational queue status.

| Field | Type | Notes |
|------|------|-------|
| `id` | `String` | Appointment identifier |
| `orgId` | `String` | Parent organization |
| `serviceId` | `String` | Used to resolve service duration and time margin |
| `customerId` | `String` | Customer owner |
| `customerName` | `String` | Admin and customer display |
| `scheduledAt` | `DateTime` | Canonical booking time used for automation |
| `status` | `AppointmentStatus` | Existing persisted lifecycle state |
| `queuePosition` | `int?` | Existing queue ordering support |
| `createdAt` | `DateTime` | Audit field |

Derived automation fields for planning:

| Derived Field | Type | Formula / Meaning |
|--------------|------|-------------------|
| `effectiveTimeMarginMinutes` | `int` | Service margin or 2-minute fallback |
| `noShowDeadline` | `DateTime` | `scheduledAt + effectiveTimeMarginMinutes` |
| `isPreBookingLocked` | `bool` | `now < scheduledAt` |
| `isAutoNoShowEligible` | `bool` | `status != serving` and `now >= noShowDeadline` and status is non-terminal |

Validation rules:

- `scheduledAt` must exist for every queued appointment.
- Appointments in terminal states (`completed`, `noShow`, `cancelled`) are excluded from auto no-show.
- Before `scheduledAt`, admin cannot mark the appointment as skipped, served, or no-show.

Planned transition rules:

| From | To | Trigger |
|------|----|---------|
| `booked` | `inQueue` | Daily queue generation |
| `inQueue` | `serving` | Admin explicitly starts service / attends customer |
| `inQueue` | `noShow` | Manual or automatic no-show after deadline |
| `inQueue` | `inQueue` | Skip before service by moving entry to end of queue |
| `serving` | `completed` | Admin completes current customer |
| `serving` | `inQueue` | Existing skip/reinsert flow while preserving compatibility |
| `noShow` | `inQueue` | Rejoin |

### 2. Service

- Source: `lib/features/shared_domain/entities/service_entity.dart`
- Persistence: `organizations/{orgId}/services/{serviceId}`
- Purpose: Provides duration and no-show margin policy.

| Field | Type | Notes |
|------|------|-------|
| `id` | `String` | Service identifier |
| `durationMinutes` | `int` | Used for wait estimates |
| `timeMarginMinutes` | `int` | Primary no-show margin input |
| `isActive` | `bool` | Existing booking availability |

Validation rules:

- Persisted service margins remain constrained by Firestore rules to `0..60`.
- If data is missing or invalid in a legacy or malformed snapshot, the effective margin becomes `2`.

### 3. Queue

- Source: `lib/features/shared_domain/entities/queue_entity.dart`
- Persistence: `organizations/{orgId}/queues/{yyyy-MM-dd}`
- Purpose: Determines daily ordering and front-of-queue pointer.

| Field | Type | Notes |
|------|------|-------|
| `orderedAppointmentIds` | `List<String>` | Queue order |
| `currentServingIndex` | `int` | Front pointer for the active entry |
| `status` | `QueueStatus` | Existing queue lifecycle |
| `generatedAt` | `DateTime` | Queue generation audit |

Validation rules:

- `currentServingIndex` must always point at the current front entry or the queue end.
- Reordering operations must preserve `orderedAppointmentIds` uniqueness.
- Auto no-show iterates one entry at a time, re-evaluating after each transaction.

### 4. QueueEntryView

- Source: `lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart`
- Persistence: None, derived repository projection
- Purpose: Admin-safe display object for the current entry and waiting list.

Current fields already present:

- `appointmentId`
- `position`
- `customerName`
- `serviceDurationMinutes`
- `status`
- `estimatedWaitMinutes`

Planned additions:

| Field | Type | Purpose |
|------|------|---------|
| `scheduledAt` | `DateTime` | Render booking time and lock pre-booking actions |
| `effectiveTimeMarginMinutes` | `int` | Display and countdown basis |
| `noShowDeadline` | `DateTime` | Derived deadline for eligibility |
| `automationState` | enum/value object | `notDueYet`, `awaitingArrival`, `overdue`, `serving` |
| `remainingSeconds` | `int?` | Per-second countdown rendering |
| `allowedActions` | value object | `canStartServing`, `canComplete`, `canSkip`, `canMarkNoShow` |

Validation rules:

- For `notDueYet`, `canSkip`, `canComplete`, and `canMarkNoShow` must all be false.
- For `serving`, auto no-show must be disabled.
- `allowedActions` must be derived in domain/data logic, not in widgets.

### 5. QueueAutomationEvaluation

- Persistence: None, derived domain helper/value object
- Purpose: Encapsulates business-rule evaluation for the current queue entry.

| Field | Type | Meaning |
|------|------|---------|
| `state` | enum | Operational state for the current entry |
| `scheduledAt` | `DateTime` | Current appointment booking time |
| `noShowDeadline` | `DateTime` | Derived deadline |
| `remainingDuration` | `Duration?` | Countdown display |
| `canStartServing` | `bool` | Whether admin can mark attendance/start service |
| `canComplete` | `bool` | Whether Next/Done can complete the entry |
| `canSkip` | `bool` | Whether skip is available |
| `canMarkNoShow` | `bool` | Whether manual no-show is available |

## Relationships

- `QueueEntity.orderedAppointmentIds[*]` references `Appointment.id`.
- `Appointment.serviceId` references `Service.id`.
- `QueueEntryView` joins queue ordering, appointment timing, and service policy.
- `QueueAutomationEvaluation` is derived from `QueueEntryView` plus current time.

## State Notes

- The current repository and datasource assume the front queue entry becomes `serving` immediately after queue generation or advancement.
- The clarified spec requires a new separation between "front of queue" and "serving" so pre-booking entries can stay locked and auto no-show can apply before attendance is confirmed.
- This is the primary design change for Phase 1 and should drive repository, datasource, rules, and Cubit updates.