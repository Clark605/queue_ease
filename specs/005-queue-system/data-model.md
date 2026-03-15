# Data Model: Queue System (Sprint 5)

**Date**: 2026-03-14  
**Feature**: `005-queue-system`

## Entities

### QueueEntity (existing, operationally activated)

**Source**: `lib/features/shared_domain/entities/queue_entity.dart`  
**Firestore path**: `organizations/{orgId}/queues/{yyyy-MM-dd}`

| Field | Type | Required | Notes |
|------|------|----------|------|
| `id` | `String` | Yes | Synthesized `{orgId}_{date}` |
| `orgId` | `String` | Yes | Queue owner organization |
| `date` | `String` | Yes | Queue day (`yyyy-MM-dd`) |
| `orderedAppointmentIds` | `List<String>` | Yes | Queue order source of truth |
| `currentServingIndex` | `int` | Yes | Pointer into ordered IDs |
| `status` | `QueueStatus` | Yes | `active`, `paused`, `closed` |
| `generatedAt` | `DateTime` | Yes | Initial generation timestamp |

**Operational rules**:
- `orderedAppointmentIds` must contain no duplicates.
- `currentServingIndex` must be `>= 0` and `<= orderedAppointmentIds.length`.
- Queue generation is idempotent for the same org/date.

---

### AppointmentEntity (existing, queue-driven transitions)

**Source**: `lib/features/shared_domain/entities/appointment_entity.dart`  
**Firestore path**: `organizations/{orgId}/appointments/{appointmentId}`

| Field | Type | Required | Sprint 5 usage |
|------|------|----------|----------------|
| `id` | `String` | Yes | Queue item identity reference |
| `orgId` | `String` | Yes | Partitioning and authorization |
| `serviceId` | `String` | Yes | Used to resolve duration |
| `customerId` | `String` | Yes | Customer status filtering |
| `customerName` | `String` | Yes | Admin display only |
| `scheduledAt` | `DateTime` | Yes | Initial ordering key |
| `status` | `AppointmentStatus` | Yes | Queue lifecycle transitions |
| `queuePosition` | `int?` | No | Optional display aid |
| `createdAt` | `DateTime` | Yes | Auditing |

**Sprint 5 eligibility**:
- Queue generation includes only appointments where `status == booked` and date == today.

---

### QueueSnapshot (derived view model)

Represents computed runtime state for UI and use-case output.

| Field | Type | Description |
|------|------|-------------|
| `date` | `DateTime` | Snapshot day |
| `currentEntryId` | `String?` | Current serving appointment ID |
| `waitingEntryIds` | `List<String>` | Remaining queue IDs after current index |
| `totalWaiting` | `int` | Count of waiting entries |
| `isEmpty` | `bool` | Whether queue has active entries |

**Notes**:
- Derived from queue doc + appointment docs.
- Not persisted as separate collection in Sprint 5.

---

## State Transitions

### AppointmentStatus transitions in scope

```text
booked  -> inQueue   (during generation/activation)
inQueue -> serving   (when entry becomes current)
serving -> completed (admin next)
serving -> noShow    (admin no-show)
serving -> inQueue   (admin skip; reinsert at end)
```

### Queue index transitions

```text
currentServingIndex = i
next action    -> i + 1
skip action    -> reinsert current entry to end, index remains i
noShow action  -> i + 1
rejoin action  -> append skipped entry ID to end (explicit admin action)
```

---

## Relationships

```text
Organization (1) -> Queue (1 per date)
Organization (1) -> Appointment (many)
Queue (1)        -> Appointment (many via orderedAppointmentIds)
Customer (1)     -> Appointment (many), visibility restricted to own active entry
```

---

## Validation Rules

- Queue generation must ignore non-`booked` appointments.
- Rejoin always appends to end of waiting order.
- Wait time estimate for a customer is `sum(durationMinutes of entries ahead)`.
- Customer queue status must not include other customers' identities.
- Queue action processing must be atomic and idempotent (safe retry behavior).

---

## Query Patterns

1. **Generate Daily Queue Candidates**
   - Filter appointments by `orgId`, date window (today), `status == booked`
   - Order by `scheduledAt ASC`

2. **Watch Admin Queue State**
   - Watch queue doc for date
   - Resolve ordered appointment IDs to appointment documents

3. **Watch Customer Queue Status**
   - Filter appointments by `orgId`, `customerId`, date window, active statuses
   - Combine with queue doc to compute position and current-serving indicator

4. **Apply Queue Action (transaction)**
   - Read queue doc + targeted appointment state
   - Validate expected state and index
   - Apply queue mutation and appointment status mutation in one transaction
