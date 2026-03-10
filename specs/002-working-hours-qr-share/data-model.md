# Data Model: Working Hours Configuration & QR/Share Access
**Sprint**: Sprint 3 | **Branch**: `002-working-hours-qr-share`

---

## Domain Entities

### `WorkingHoursEntity` *(existing — Sprint 1)*

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `orgId` | `String` | No | Organization ID (FK to organizations collection) |
| `dayOfWeek` | `int` | No | 0=Monday … 6=Sunday; also the Firestore document ID |
| `isOpen` | `bool` | No | Whether this day is a working day |
| `openTime` | `String` | No | Opening time in `"HH:mm"` 24h format (e.g. `"09:00"`) |
| `closeTime` | `String` | No | Closing time in `"HH:mm"` 24h format (e.g. `"17:00"`) |
| `breakStart` | `String?` | Yes | Break start in `"HH:mm"` format; null = no break |
| `breakEnd` | `String?` | Yes | Break end in `"HH:mm"` format; null = no break |

**File**: `lib/shared/organization/domain/entities/working_hours_entity.dart`

**Invariants**:
- `dayOfWeek` is 0–6; values outside this range are invalid
- If `isOpen == false`, `openTime`/`closeTime` are still stored (to preserve last-used times) but have no semantic effect
- `breakStart` and `breakEnd` are both null or both non-null — a partial break is invalid
- Time strings are always `"HH:mm"` format with zero-padded hours and minutes

---

### `OrganizationEntity` *(existing — Sprint 2, relevant fields)*

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `bookingLinkSlug` | `String` | No | URL-safe slug generated at org creation; immutable |
| `qrCodeUrl` | `String?` | Yes | Not used this sprint; QR is generated client-side |

**File**: `lib/shared/organization/domain/entities/organization_entity.dart`

The full booking URL is derived at runtime: `https://queueease.app/org/{bookingLinkSlug}`

---

## Firestore Schema

### Collection Path

```
organizations/{orgId}/working_hours/{dayOfWeek}
```

- **Parent**: `organizations/{orgId}` (existing organization document)
- **Subcollection**: `working_hours` (7 documents per organization, fixed IDs)
- **Document ID**: String representation of `dayOfWeek` — `"0"` through `"6"`
- **Note**: Collection name is `working_hours` (snake_case), matching the Firestore security rules

---

### Document Structure

```json
{
  "orgId": "abc123xyz",
  "dayOfWeek": 0,
  "isOpen": true,
  "openTime": "09:00",
  "closeTime": "17:00",
  "breakStart": "12:00",
  "breakEnd": "13:00",
  "createdAt": "<Firestore Timestamp>",
  "updatedAt": "<Firestore Timestamp>"
}
```

| Field | Firestore Type | Written By | Notes |
|-------|---------------|-----------|-------|
| `orgId` | String | Datasource (init) | Immutable after creation |
| `dayOfWeek` | Integer | Datasource (init) | Equals `int(docId)`; security rule enforces this |
| `isOpen` | Boolean | Datasource (init + save) | |
| `openTime` | String | Datasource (init + save) | HH:mm; only required when `isOpen = true` |
| `closeTime` | String | Datasource (init + save) | HH:mm; only required when `isOpen = true` |
| `breakStart` | String \| null | Datasource (init + save) | null when no break |
| `breakEnd` | String \| null | Datasource (init + save) | null when no break |
| `createdAt` | Timestamp | Datasource (init) | `FieldValue.serverTimestamp()`; never modified |
| `updatedAt` | Timestamp | Datasource (save) | `FieldValue.serverTimestamp()` on every update |

---

### Default Document Values (New Organization)

Created by `_initializeDefaults()` when the subcollection is empty on first `watchWorkingHours`:

| Day | `dayOfWeek` | `isOpen` | `openTime` | `closeTime` | `breakStart` | `breakEnd` |
|-----|-------------|---------|-----------|-----------|-------------|---------|
| Monday | 0 | `true` | `"09:00"` | `"17:00"` | `null` | `null` |
| Tuesday | 1 | `true` | `"09:00"` | `"17:00"` | `null` | `null` |
| Wednesday | 2 | `true` | `"09:00"` | `"17:00"` | `null` | `null` |
| Thursday | 3 | `true` | `"09:00"` | `"17:00"` | `null` | `null` |
| Friday | 4 | `true` | `"09:00"` | `"17:00"` | `null` | `null` |
| Saturday | 5 | `false` | `"09:00"` | `"17:00"` | `null` | `null` |
| Sunday | 6 | `false` | `"09:00"` | `"17:00"` | `null` | `null` |

---

### Security Rules Impact

The existing `firestore.rules` must be updated before `breakStart`/`breakEnd` can be written:
- Add `'breakStart'` and `'breakEnd'` to `hasOnlyAllowedFields(...)` in both `allow create` and `allow update` for `working_hours`
- Add conditional validation: `"breakStart"` and `"breakEnd"` must be either both absent or both valid HH:mm strings

This is the first implementation task of the sprint (blocks all other Firestore writes).

---

## Validation Rules

Implemented in `WorkingHoursRepositoryImpl._validateAll()`:

| Rule | Condition | Error |
|------|-----------|-------|
| Close after open | `_timeToMinutes(closeTime) > _timeToMinutes(openTime)` for all open days | `ValidationException` |
| Equal times rejected | `closeTime != openTime` for all open days | `ValidationException` |
| Break inside range | `_timeToMinutes(breakStart) >= _timeToMinutes(openTime)` | `ValidationException` |
| Break end before close | `_timeToMinutes(breakEnd) <= _timeToMinutes(closeTime)` | `ValidationException` |
| Break has duration | `_timeToMinutes(breakEnd) > _timeToMinutes(breakStart)` | `ValidationException` |
| Break completeness | `breakStart != null ↔ breakEnd != null` | `ValidationException` |

Helper (pure Dart, no Flutter import):
```dart
int _timeToMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
```

---

## Model Layer

### `WorkingHoursModel` *(existing — Sprint 1)*

**File**: `lib/shared/organization/data/models/working_hours_model.dart`

Existing methods — no changes to the model class itself:
- `factory WorkingHoursModel.fromDoc(DocumentSnapshot doc, {required String orgId})` — `dayOfWeek = int.parse(doc.id)`
- `Map<String, dynamic> toMap()` — returns `{orgId, isOpen, openTime, closeTime, breakStart, breakEnd}` (does NOT include `dayOfWeek` or timestamps)
- `WorkingHoursEntity toEntity()`

The datasource adds `dayOfWeek`, `createdAt`, and `updatedAt` to the write map; `toMap()` is not modified.

---

## UI Data Flow

### Working Hours Page

```
OrganizationCubit (existing, provides orgId)
    ↓ orgId
WorkingHoursCubit
    ↓ WorkingHoursLoaded(List<WorkingHoursEntity>)
WorkingHoursPage
    ├── List of DayWorkingHoursTile widgets (one per day, 0–6)
    │     ├── open/closed toggle → local state
    │     ├── openTime field → showTimePicker → local state
    │     ├── closeTime field → showTimePicker → local state
    │     └── BreakTimeSection:
    │           ├── break toggle → local state
    │           ├── breakStart field → showTimePicker → local state
    │           └── breakEnd field → showTimePicker → local state
    └── "Save All" button → collect all tile states → cubit.saveAll(orgId, days)
```

The page holds a `List<WorkingHoursEntity>` of pending edits (local state). On stream update, the list is reset to the persisted values.

### Share Access Page

```
OrganizationCubit (existing ancestor, provides bookingLinkSlug)
    ↓ slug extracted in page initState
ShareAccessCubit
    ↓ ShareAccessState
ShareAccessPage
    ├── QrCodeDisplay (RepaintBoundary wrapping QrImageView)
    ├── bookingUrl text + copy button → cubit.copyLink(url)
    ├── Share button → cubit.shareContent(url, qrBytes)
    └── Download button → cubit.downloadQrCode(qrBytes)
```

---

## Indexes Required

No new compound indexes are needed for this sprint. The `working_hours` subcollection is queried by `orgId` (the parent collection path) and retrieved as a full collection scan with `orderBy` implicit on document ID. Firestore handles this efficiently without an index.
