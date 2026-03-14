# Data Model: Customer Booking Flow

**Date**: March 11, 2026  
**Feature**: `004-customer-booking-flow`

---

## Entities

### AppointmentEntity (existing — write path added)

**Firestore path**: `organizations/{orgId}/appointments/{appointmentId}`  
**Source**: `lib/shared/booking/domain/entities/appointment_entity.dart`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | Yes | Auto-generated Firestore doc ID |
| `orgId` | `String` | Yes | Parent organization |
| `serviceId` | `String` | Yes | Booked service |
| `customerId` | `String` | Yes | Firebase Auth UID of customer |
| `customerName` | `String` | Yes | Display name (editable on form) |
| `customerPhone` | `String?` | No | Optional phone |
| `scheduledAt` | `DateTime` | Yes | Appointment start time |
| `status` | `AppointmentStatus` | Yes | Set to `booked` on creation |
| `queuePosition` | `int?` | No | Null at creation, assigned in Sprint 5 |
| `createdAt` | `DateTime` | Yes | Timestamp of booking |

**Status transitions** (this sprint only creates `booked`):
```
booked → inQueue → serving → completed
                           → noShow
```

**Validation rules**:
- `scheduledAt` must be in the future (enforced client-side and in Firestore rules)
- `customerName` must not be empty
- `status` must be `booked` on creation
- `orgId` must match the subcollection parent
- `customerId` must match the authenticated user's UID

---

### OrganizationEntity (existing — read only)

**Firestore path**: `organizations/{orgId}`  
**Source**: `lib/shared/organization/domain/entities/organization_entity.dart`

Fields used in this feature:
- `id` — for subcollection paths
- `name` — landing page, confirmation
- `bookingLinkSlug` — deep link resolution (new query: `getBySlug`)
- `isOpen` — landing page status display
- `address` — landing page, confirmation (optional)
- `description` — landing page (optional)

**No modifications to entity or model.**

---

### ServiceEntity (existing — read only)

**Firestore path**: `organizations/{orgId}/services/{serviceId}`  
**Source**: `lib/shared/organization/domain/entities/service_entity.dart`

Fields used in this feature:
- `id`, `orgId` — identification
- `name` — service list, confirmation
- `durationMinutes` — slot calculation input
- `price` — service list display (optional)
- `isActive` — filter: only active services shown
- `description` — service list display (optional)

**No modifications to entity or model.**

---

### AppointmentModel (new — write path)

The customer booking flow introduces the **write path** for `AppointmentModel`. The model MUST expose:

| Method | Direction | Purpose |
|--------|-----------|---------|
| `AppointmentModel.fromDoc(doc, {required orgId})` | Firestore → Model | Read path (existing) |
| `AppointmentModel.fromEntity(AppointmentEntity)` | Entity → Model | Write path (new) |
| `toMap()` | Model → Firestore | Serialization (existing) |
| `toEntity()` | Model → Entity | Domain conversion (existing) |

The datasource MUST use `AppointmentModel.fromEntity(entity).toMap()` when writing to Firestore. It MUST NOT access `AppointmentEntity` fields directly.

---

### WorkingHoursEntity (existing — read only)

**Firestore path**: `organizations/{orgId}/working_hours/{dayOfWeek}`  
**Source**: `lib/shared/organization/domain/entities/working_hours_entity.dart`

Fields used in this feature:
- `dayOfWeek` — map date to correct schedule
- `isOpen` — determine if booking available
- `openTime`, `closeTime` — slot boundaries
- `breakStart`, `breakEnd` — excluded zone

**No modifications to entity or model.**

---

## Relationships

```
Organization (1) ──< Service (many)        [existing]
Organization (1) ──< WorkingHours (7)      [existing]
Organization (1) ──< Appointment (many)    [new write path]
Service (1) ──< Appointment (many)         [new relationship used]
Customer (1) ──< Appointment (many)        [new write path]
```

---

## New Queries

### 1. Slug-to-Organization Lookup
```
organizations WHERE bookingLinkSlug == :slug LIMIT 1
```
- Added to `OrganizationRepository.getOrganizationBySlug(String slug)`
- Existing `FirestoreOrganizationDatasource` extended with `getBySlug()`

### 2. Appointments by Service and Date
```
organizations/{orgId}/appointments
  WHERE serviceId == :serviceId
  AND scheduledAt >= :dayStart
  AND scheduledAt < :dayEnd
```
- New method on `AppointmentRepository`
- **Requires compound index**: `serviceId` ASC + `scheduledAt` ASC

### 3. Create Appointment (transactional)
```
runTransaction:
  1. Query appointments for orgId + serviceId + date range
  2. Check overlap with requested scheduledAt
  3. If clean → set new appointment document
  4. If conflict → abort with ValidationException
```

---

## Firestore Rules Changes Required

### Appointment Create — Add Missing Fields
Current allowed fields:
```
['orgId','customerId','serviceId','scheduledAt','status','customerNotes','adminNotes','createdAt','updatedAt']
```

Required allowed fields:
```
['orgId','customerId','serviceId','scheduledAt','status','customerName','customerPhone','queuePosition','customerNotes','adminNotes','createdAt','updatedAt']
```

Added: `customerName`, `customerPhone`, `queuePosition`

### Appointment List — Allow Customer Read
Current rule: `allow list: if isAuthenticated() && ownsOrganization(orgId);`

New rule: `allow list: if isAuthenticated();`

Rationale: Customers need to query appointments for slot availability. Appointment data (names, times) is non-sensitive.

### Appointment Update — Add Missing Fields
Same field additions (`customerName`, `customerPhone`, `queuePosition`) to the update rule's `hasOnlyAllowedFields()`.

---

## Firestore Indexes Required

Add to `firestore.indexes.json`:

```json
{
  "collectionGroup": "appointments",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "serviceId", "order": "ASCENDING" },
    { "fieldPath": "scheduledAt", "order": "ASCENDING" }
  ]
}
```
