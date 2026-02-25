# Firestore Entity Models Plan

## Overview

Five pure domain entities + five Firestore model/mapper classes. Entities are `Equatable` value objects with no Firestore imports; models in the data layer handle serialization.

---

## Domain Layer — Pure Entities

### 1. `OrganizationEntity`
**File:** `lib/shared/organization/domain/entities/organization_entity.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | |
| `name` | `String` | |
| `adminUid` | `String` | Owner Firebase UID |
| `bookingLinkSlug` | `String` | Unique slug for QR/link |
| `qrCodeUrl` | `String?` | |
| `address` | `String?` | |
| `isOpen` | `bool` | Live open/closed status |
| `logoUrl` | `String?` | |
| `description` | `String?` | |
| `createdAt` | `DateTime` | |

**Firestore path:** `organizations/{orgId}`

---

### 2. `ServiceEntity`
**File:** `lib/shared/organization/domain/entities/service_entity.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | |
| `orgId` | `String` | Parent organization |
| `name` | `String` | |
| `durationMinutes` | `int` | Service duration |
| `timeMarginMinutes` | `int` | No-show grace period |
| `isActive` | `bool` | |
| `price` | `double?` | Optional display price |
| `queueType` | `String?` | e.g. "Priority", "Standard" |
| `description` | `String?` | |
| `createdAt` | `DateTime` | |

**Firestore path:** `organizations/{orgId}/services/{serviceId}`

---

### 3. `WorkingHoursEntity`
**File:** `lib/shared/organization/domain/entities/working_hours_entity.dart`

| Field | Type | Notes |
|---|---|---|
| `orgId` | `String` | |
| `dayOfWeek` | `int` | 0=Mon … 6=Sun — also serves as the Firestore doc ID |
| `isOpen` | `bool` | Is this day a working day |
| `openTime` | `String` | `"HH:mm"` e.g. `"09:00"` |
| `closeTime` | `String` | `"HH:mm"` |
| `breakStart` | `String?` | `"HH:mm"` |
| `breakEnd` | `String?` | `"HH:mm"` |

> No `createdAt` — this is configuration data, not a log.
> No `id` field — `dayOfWeek` is the document ID in Firestore; the composite key `orgId + dayOfWeek` uniquely identifies a record, making a separate `id` redundant.
> Times stored as `"HH:mm"` strings to avoid coupling the domain layer to Flutter's `TimeOfDay`.

**Firestore path:** `organizations/{orgId}/working_hours/{dayOfWeek}`

---

### 4. `AppointmentStatus` enum
**File:** `lib/shared/booking/domain/entities/appointment_status.dart`

Values: `booked`, `inQueue`, `serving`, `completed`, `noShow`

### 5. `AppointmentEntity`
**File:** `lib/shared/booking/domain/entities/appointment_entity.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | |
| `orgId` | `String` | |
| `serviceId` | `String` | |
| `customerId` | `String` | Firebase Auth UID |
| `customerName` | `String` | |
| `customerPhone` | `String?` | |
| `scheduledAt` | `DateTime` | Booked slot |
| `status` | `AppointmentStatus` | |
| `queuePosition` | `int?` | Assigned when queue is generated |
| `createdAt` | `DateTime` | |

**Firestore path:** `organizations/{orgId}/appointments/{appointmentId}`

---

### 6. `QueueStatus` enum
**File:** `lib/shared/queue/domain/entities/queue_status.dart`

Values: `active`, `paused`, `closed`

### 7. `QueueEntity`
**File:** `lib/shared/queue/domain/entities/queue_entity.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Synthesized as `"{orgId}_{date}"` — **not** read from `doc.id` (Firestore doc ID is just `{date}`); the model's `fromDoc` must construct this from the parent `orgId` + `doc.id` |
| `orgId` | `String` | |
| `date` | `String` | `"YYYY-MM-DD"` |
| `orderedAppointmentIds` | `List<String>` | Ordered appointment IDs |
| `currentServingIndex` | `int` | |
| `status` | `QueueStatus` | |
| `generatedAt` | `DateTime` | |

**Firestore path:** `organizations/{orgId}/queues/{date}`

---

## Data Layer — Firestore Model Classes

Each model is a static utility class with `fromDoc(DocumentSnapshot)` and `toMap(Entity)` — no Firestore imports in the domain layer.

| Model | File | Entity |
|---|---|---|
| `OrganizationModel` | `lib/shared/organization/data/models/organization_model.dart` | `OrganizationEntity` |
| `ServiceModel` | `lib/shared/organization/data/models/service_model.dart` | `ServiceEntity` |
| `WorkingHoursModel` | `lib/shared/organization/data/models/working_hours_model.dart` | `WorkingHoursEntity` |
| `AppointmentModel` | `lib/shared/booking/data/models/appointment_model.dart` | `AppointmentEntity` |
| `QueueModel` | `lib/shared/queue/data/models/queue_model.dart` | `QueueEntity` |

---

## Tests

- **Entity tests** — equality/`props` for all five entities in `test/shared/{feature}/domain/entities/`
- **Model tests** — `fromDoc` → `toMap` round-trips for all five models in `test/shared/{feature}/data/models/` using a `FakeDocumentSnapshot` helper consistent with `test/firebase_mocks.dart`

---

## Deferred Entities (future phases)

| Entity | Phase | Firestore Path |
|---|---|---|
| `QueueEntry` | Phase 5 | `organizations/{orgId}/queues/{date}/entries/{id}` |
| `Notification` | Phase 7 | `users/{userId}/notifications/{id}` |
| `DailySummary` | Phase 6 | `organizations/{orgId}/daily_summaries/{date}` |
| `FCMToken` | Phase 7 | `users/{userId}/fcm_tokens/{id}` |

---

## Decisions

- Model/mapper classes own all Firestore coupling; entities are pure domain objects (`dart:core` only)
- `WorkingHours` included in current sprint — directly blocks slot availability in the booking flow
- `createdAt` / `scheduledAt` / `generatedAt` exposed as `DateTime` in entities; stored as `Timestamp` in Firestore, converted in model classes
- `WorkingHours` times stored as `"HH:mm"` strings — avoids `TimeOfDay` coupling to the Flutter framework in the domain layer
- Enums serialized using `.name` / `values.byName()` — consistent with the existing `UserRole` pattern in `firestore_user_datasource.dart`; note that multi-word values like `AppointmentStatus.inQueue` serialize as `"inQueue"` (camelCase), not fully lowercase
- `List<String>` in `QueueEntity.props` is handled correctly by `Equatable`'s built-in `DeepCollectionEquality` — no `package:collection` import needed
- `QueueModel.fromDoc` must synthesize `QueueEntity.id` as `"{orgId}_{date}"` since the Firestore document ID is only the date string
- `WorkingHoursEntity` has no `id` field — `dayOfWeek` is the document ID; add `orgId` as a named parameter to `fromDoc` since it cannot be read from the document itself

## Pending Changes to Existing Entities

- **`UserEntity`** should gain `orgId: String?` when the organization feature ships — currently it stores `orgName` but has no reference to the organization document ID, making it impossible to look up an admin's org without a full Firestore query. This is a forward-reference gap between `UserEntity` and `OrganizationEntity.adminUid`.
