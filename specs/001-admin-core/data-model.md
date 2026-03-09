# Data Model: Admin Core — Organization Setup & Service Management

**Phase**: 1  
**Date**: March 1, 2026  
**Status**: Complete

---

## Entities & Fields

### UserEntity *(MODIFIED)*

**Collection**: `users/{uid}`  
**Change**: `orgName: String?` replaced by `organizationId: String?`

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| `uid` | `String` | ✅ | immutable after creation | Firebase Auth UID |
| `email` | `String` | ✅ | valid email format | |
| `role` | `UserRole` | ✅ | `admin` or `customer` | immutable after creation |
| `displayName` | `String?` | ❌ | max 100 chars | |
| `phone` | `String?` | ❌ | | |
| `organizationId` | `String?` | ❌ | Firestore doc ID of linked org | `null` until org creation completes; triggers router guard |
| `tutorialCompleted` | `bool` | ✅ | default `false` | Written to Firestore; persists across reinstalls (FR-022) |

**Removed field**: `orgName: String?` — replaced by `organizationId` reference.

**Firestore document shape**:
```json
{
  "uid": "abc123",
  "email": "admin@example.com",
  "role": "admin",
  "displayName": "Jane Smith",
  "phone": "+1-555-0100",
  "organizationId": "org_xyz789",
  "tutorialCompleted": false
}
```

---

### OrganizationEntity *(EXISTING — no structural changes)*

**Collection**: `organizations/{orgId}`

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| `id` | `String` | ✅ | Firestore doc ID | |
| `name` | `String` | ✅ | 1–100 chars | FR-008 |
| `adminUid` | `String` | ✅ | immutable after creation | Links to `users/{uid}` |
| `bookingLinkSlug` | `String` | ✅ | URL-safe; immutable after creation | Auto-generated: `{sanitized-name}-{6-char-alphanum}` |
| `isOpen` | `bool` | ✅ | default `false` | Live open/closed toggle |
| `createdAt` | `DateTime` | ✅ | immutable after creation | Server timestamp at creation |
| `address` | `String?` | ❌ | max 200 chars | |
| `description` | `String?` | ❌ | max 500 chars | |
| `logoUrl` | `String?` | ❌ | valid URL format | |
| `qrCodeUrl` | `String?` | ❌ | valid URL format | Populated in Sprint 3 (QR generation) |

**Firestore document shape**:
```json
{
  "name": "Sunrise Clinic",
  "adminUid": "abc123",
  "bookingLinkSlug": "sunrise-clinic-a3x9kp",
  "isOpen": false,
  "createdAt": "2026-03-01T10:00:00Z",
  "address": "123 Main St, Springfield",
  "description": "General practice clinic",
  "logoUrl": null,
  "qrCodeUrl": null
}
```

---

### ServiceEntity *(EXISTING — no structural changes)*

**Collection**: `organizations/{orgId}/services/{serviceId}`

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| `id` | `String` | ✅ | Firestore doc ID | |
| `orgId` | `String` | ✅ | immutable after creation | Parent org reference |
| `name` | `String` | ✅ | 1–100 chars | FR-016a |
| `durationMinutes` | `int` | ✅ | > 0 | FR-016 |
| `timeMarginMinutes` | `int` | ✅ | ≥ 0; default `5` | FR-017 — no-show grace period |
| `isActive` | `bool` | ✅ | default `true` | FR-014 |
| `createdAt` | `DateTime` | ✅ | immutable after creation | |
| `price` | `double?` | ❌ | ≥ 0 if present | FR-018 — display-only |
| `description` | `String?` | ❌ | max 500 chars | |
| `queueType` | `String?` | ❌ | | Future use |

**Firestore document shape**:
```json
{
  "orgId": "org_xyz789",
  "name": "General Consultation",
  "durationMinutes": 30,
  "timeMarginMinutes": 5,
  "isActive": true,
  "createdAt": "2026-03-01T10:05:00Z",
  "price": 50.00,
  "description": "Standard 30-minute consultation",
  "queueType": null
}
```

---

## Validation Rules Summary

| Entity | Field | Rule |
|--------|-------|------|
| User | `organizationId` | `null` triggers `/a/setup` router redirect for admin role |
| User | `tutorialCompleted` | `false` (or absent) → tutorial shown on first dashboard visit |
| Organization | `name` | Required, 1–100 characters, non-empty after trimming |
| Organization | `bookingLinkSlug` | Auto-generated; `{slug}-{6-char}` format; URL-safe characters only |
| Organization | `adminUid` | Immutable after creation; must match authenticated user's UID |
| Service | `name` | Required, 1–100 characters, non-empty after trimming |
| Service | `durationMinutes` | Integer > 0 |
| Service | `timeMarginMinutes` | Integer ≥ 0; defaults to `5` if not provided |
| Service | `price` | Optional; if present, must be ≥ 0 |

---

## State Transitions

### Organization Creation (sign-up flow)

```
[Admin submits sign-up form]
        ↓
[Firebase Auth creates account]
        ↓
[Firestore: create user doc with organizationId: null]
        ↓ ← WriteBatch starts here
[Firestore: create organization doc → returns orgId]
[Firestore: update user doc organizationId = orgId]
        ↓ ← WriteBatch committed
[AuthCubit emits Authenticated(user with organizationId)]
        ↓
[Router redirects to /a/dashboard]
        ↓
[TutorialCubit detects tutorialCompleted=false → show tutorial]
```

### Missing-Org Recovery (FR-005 path)

```
[Admin signs in — existing account, no organizationId]
        ↓
[Router guard detects organizationId == null]
        ↓
[Redirect to /a/setup]
        ↓
[Admin submits organization name]
        ↓
[WriteBatch: create org doc + update user doc organizationId]
        ↓
[AuthCubit re-emits Authenticated with updated user]
        ↓
[Router redirects to /a/dashboard]
```

### Service Lifecycle

```
[isActive: true]  ←──────────────── toggle ───────────────→  [isActive: false]
     ↑                                                               
  [created]                                                 [admin deletes → removed]
```

---

## Relationship Diagram

```
users/{uid}
  └── organizationId ──→ organizations/{orgId}
                              └── /services/{serviceId}
                              └── /services/{serviceId}
```
