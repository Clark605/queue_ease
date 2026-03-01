# Data Model: Firestore Collections & Security Access

**Feature**: 001-firestore-security-rules  
**Date**: February 25, 2026  
**Phase**: 1 - Design & Contracts

---

## Overview

This document defines the complete Firestore data model for Queue Ease, including all collections, their fields, relationships, and access control rules.

---

## Collection Hierarchy

```
/users/{userId}
/organizations/{orgId}
  /services/{serviceId}
  /working_hours/{dayOfWeek}
  /appointments/{appointmentId}
  /queues/{queueId}
```

---

## 1. Users Collection

**Path**: `/users/{userId}`  
**Document ID Format**: Firebase Auth UID (string)

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `uid` | string | ✅ | Must match document ID | Firebase Auth user ID |
| `email` | string | ✅ | Valid email format | User email address |
| `displayName` | string | ❌ | Max 100 chars | User display name |
| `phoneNumber` | string | ❌ | Max 20 chars | User phone number |
| `role` | string | ✅ | Enum: "admin", "customer" | User role |
| `photoUrl` | string | ❌ | Valid URL format | Profile photo URL |
| `createdAt` | timestamp | ✅ | Immutable | Account creation timestamp |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | User themselves | `request.auth.uid == userId` |
| `create` | First-time sign-up | `request.auth.uid == userId` + valid fields |
| `update` | User themselves | `request.auth.uid == userId` + immutable fields not modified |
| `delete` | ❌ No one | Soft delete via update instead |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['uid', 'email', 'role', 'createdAt'])

// Valid role enum
request.resource.data.role in ['admin', 'customer']

// uid matches document ID
request.resource.data.uid == userId

// Immutable fields on update
!request.resource.data.diff(resource.data).affectedKeys().hasAny(['uid', 'createdAt'])
```

### Relationships

- **1:1 with Firebase Auth**: `uid` field matches Auth UID
- **1:N with Organizations**: Admin users can own one organization (`organizations.adminUid`)
- **1:N with Appointments**: Customer users can have multiple appointments (`appointments.customerId`)

---

## 2. Organizations Collection

**Path**: `/organizations/{orgId}`  
**Document ID Format**: Auto-generated Firestore ID

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `adminUid` | string | ✅ | Must reference existing user with role="admin" | Owner admin user ID |
| `name` | string | ✅ | Max 100 chars | Organization display name |
| `bookingLinkSlug` | string | ✅ | Unique, alphanumeric + hyphen, max 50 chars | URL-friendly slug |
| `isOpen` | bool | ✅ | - | Whether organization is accepting bookings |
| `description` | string | ❌ | Max 500 chars | Organization description |
| `address` | string | ❌ | Max 200 chars | Physical address |
| `phoneNumber` | string | ❌ | Max 20 chars | Contact phone |
| `email` | string | ❌ | Valid email format | Contact email |
| `createdAt` | timestamp | ✅ | Immutable | Creation timestamp |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | Anyone authenticated | Public information for booking |
| `create` | Admin users | First organization for admin (1:1 relationship) |
| `update` | Organization owner | `adminUid == request.auth.uid` |
| `delete` | Organization owner | `adminUid == request.auth.uid` |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['adminUid', 'name', 'bookingLinkSlug', 'isOpen', 'createdAt'])

// Admin owns only one organization (checked at creation)
// Application logic ensures this constraint

// Immutable fields
!request.resource.data.diff(resource.data).affectedKeys().hasAny(['adminUid', 'createdAt'])

// Field types
request.resource.data.name is string &&
request.resource.data.isOpen is bool &&
request.resource.data.createdAt is timestamp
```

### Relationships

- **N:1 with Users**: Owned by one admin user (`adminUid`)
- **1:N with Services**: Has multiple services (subcollection)
- **1:N with Working Hours**: Has working hours per day (subcollection)
- **1:N with Appointments**: Has multiple appointments (subcollection)
- **1:N with Queues**: Has multiple queues (subcollection)

---

## 3. Services Subcollection

**Path**: `/organizations/{orgId}/services/{serviceId}`  
**Document ID Format**: Auto-generated Firestore ID

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `orgId` | string | ✅ | Must match parent `{orgId}` | Parent organization ID |
| `name` | string | ✅ | Max 100 chars | Service name |
| `durationMinutes` | int | ✅ | Min: 5, Max: 480 (8 hours) | Service duration |
| `timeMarginMinutes` | int | ✅ | Min: 0, Max: 120 | Grace period before no-show (minutes) |
| `price` | double | ❌ | Min: 0 | Service price (optional for MVP) |
| `description` | string | ❌ | Max 500 chars | Service description |
| `queueType` | string | ❌ | Enum: "appointment", "walkin", "both" | Queue type |
| `isActive` | bool | ✅ | - | Whether service is available for booking |
| `createdAt` | timestamp | ✅ | Immutable | Creation timestamp |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | Anyone authenticated | Public service catalog |
| `create` | Organization owner | `ownsOrganization(orgId)` |
| `update` | Organization owner | `ownsOrganization(orgId)` |
| `delete` | Organization owner | `ownsOrganization(orgId)` |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['orgId', 'name', 'durationMinutes', 'isActive', 'createdAt'])

// orgId matches parent
request.resource.data.orgId == orgId

// Valid duration range
request.resource.data.durationMinutes >= 5 && 
request.resource.data.durationMinutes <= 480

// Immutable fields
!request.resource.data.diff(resource.data).affectedKeys().hasAny(['orgId', 'createdAt'])
```

### Relationships

- **N:1 with Organizations**: Belongs to one organization (via `orgId`)
- **1:N with Appointments**: Can have multiple appointments (`appointments.serviceId`)

---

## 4. Working Hours Subcollection

**Path**: `/organizations/{orgId}/working_hours/{dayOfWeek}`  
**Document ID Format**: Integer string "0" to "6" (0=Monday, 6=Sunday)

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `orgId` | string | ✅ | Must match parent `{orgId}` | Parent organization ID |
| `dayOfWeek` | int | ✅ | 0-6 (0=Monday, 6=Sunday) | Day of week |
| `isOpen` | bool | ✅ | - | Whether organization operates this day |
| `openTime` | string | Conditional | Format: "HH:mm" (24-hour), required if `isOpen=true` | Opening time |
| `closeTime` | string | Conditional | Format: "HH:mm" (24-hour), required if `isOpen=true` | Closing time |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | Anyone authenticated | Public operating hours |
| `create` | Organization owner | `ownsOrganization(orgId)` |
| `update` | Organization owner | `ownsOrganization(orgId)` |
| `delete` | Organization owner | `ownsOrganization(orgId)` |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['orgId', 'dayOfWeek', 'isOpen'])

// orgId matches parent
request.resource.data.orgId == orgId

// dayOfWeek matches document ID and is in range
request.resource.data.dayOfWeek == int(dayOfWeek) &&
request.resource.data.dayOfWeek >= 0 &&
request.resource.data.dayOfWeek <= 6

// Time fields required if isOpen=true
request.resource.data.isOpen == false ||
(request.resource.data.keys().hasAll(['openTime', 'closeTime']) &&
 request.resource.data.openTime.matches('^([01]?[0-9]|2[0-3]):[0-5][0-9]$') &&
 request.resource.data.closeTime.matches('^([01]?[0-9]|2[0-3]):[0-5][0-9]$'))
```

### Relationships

- **N:1 with Organizations**: Belongs to one organization (via `orgId`)

---

## 5. Appointments Subcollection

**Path**: `/organizations/{orgId}/appointments/{appointmentId}`  
**Document ID Format**: Auto-generated Firestore ID

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `orgId` | string | ✅ | Must match parent `{orgId}` | Parent organization ID |
| `customerId` | string | ✅ | Must reference existing user with role="customer" | Customer user ID |
| `serviceId` | string | ✅ | Must reference existing service in same org | Service ID |
| `scheduledAt` | timestamp | ✅ | Cannot be in the past | Scheduled date/time |
| `status` | string | ✅ | Enum: "booked", "inQueue", "serving", "completed", "noShow" | Appointment status |
| `customerNotes` | string | ❌ | Max 500 chars | Customer notes |
| `adminNotes` | string | ❌ | Max 500 chars | Admin notes (private) |
| `createdAt` | timestamp | ✅ | Immutable | Creation timestamp |
| `updatedAt` | timestamp | ✅ | Auto-updated | Last modification timestamp |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | Customer OR organization owner | `customerId == request.auth.uid` OR `ownsOrganization(orgId)` |
| `create` | Customer | `customerId == request.auth.uid` + valid fields |
| `update` | Customer (limited) OR owner | Customer: own appointment + status/notes only; Owner: any field |
| `delete` | Organization owner | `ownsOrganization(orgId)` |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['orgId', 'customerId', 'serviceId', 'scheduledAt', 'status', 'createdAt'])

// orgId matches parent
request.resource.data.orgId == orgId

// Valid status enum
request.resource.data.status in ['booked', 'inQueue', 'serving', 'completed', 'noShow']

// Appointment in future (on create)
request.method == 'create' implies 
  request.resource.data.scheduledAt > request.time

// Immutable fields
!request.resource.data.diff(resource.data).affectedKeys().hasAny(['orgId', 'customerId', 'serviceId', 'scheduledAt', 'createdAt'])

// Customer can only update own appointment's status and notes
request.auth.uid == resource.data.customerId implies
  !request.resource.data.diff(resource.data).affectedKeys().hasAny(['orgId', 'customerId', 'serviceId', 'appointmentDateTime', 'createdAt'])
```

### Relationships

- **N:1 with Organizations**: Belongs to one organization (via `orgId`)
- **N:1 with Users**: Booked by one customer (via `customerId`)
- **N:1 with Services**: For one service (via `serviceId`)

---

## 6. Queues Subcollection

**Path**: `/organizations/{orgId}/queues/{queueId}`  
**Document ID Format**: Auto-generated Firestore ID

### Fields

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `orgId` | string | ✅ | Must match parent `{orgId}` | Parent organization ID |
| `customerId` | string | ✅ | Must reference existing user with role="customer" | Customer user ID |
| `serviceId` | string | ✅ | Must reference existing service in same org | Service ID |
| `queueNumber` | int | ✅ | Auto-incremented per day | Queue position number |
| `status` | string | ✅ | Enum: "active", "paused", "closed" | Queue status |
| `estimatedWaitMinutes` | int | ❌ | Min: 0 | Estimated wait time |
| `joinedAt` | timestamp | ✅ | Immutable | Time customer joined queue |
| `updatedAt` | timestamp | ✅ | Auto-updated | Last modification timestamp |

### Access Rules

| Operation | Who Can Access | Conditions |
|-----------|----------------|------------|
| `read` | Customer OR organization owner | `customerId == request.auth.uid` OR `ownsOrganization(orgId)` |
| `create` | Customer | `customerId == request.auth.uid` + valid fields |
| `update` | Organization owner | `ownsOrganization(orgId)` (admin controls queue) |
| `delete` | Organization owner | `ownsOrganization(orgId)` |

### Validation Rules

```javascript
// Required fields
request.resource.data.keys().hasAll(['orgId', 'customerId', 'serviceId', 'queueNumber', 'status', 'joinedAt'])

// orgId matches parent
request.resource.data.orgId == orgId

// Valid status enum
request.resource.data.status in ['active', 'paused', 'closed']

// Immutable fields
!request.resource.data.diff(resource.data).affectedKeys().hasAny(['orgId', 'customerId', 'serviceId', 'queueNumber', 'joinedAt'])
```

### Relationships

- **N:1 with Organizations**: Belongs to one organization (via `orgId`)
- **N:1 with Users**: Joined by one customer (via `customerId`)
- **N:1 with Services**: For one service (via `serviceId`)

---

## Security Principles Applied

### 1. Principle of Least Privilege
- Users can only read their own user document
- Customers can only create appointments/queues for themselves
- Admins can only modify resources in their organization

### 2. Data Validation
- All required fields enforced
- Enum values strictly validated
- Field types checked
- Immutable fields protected

### 3. Public Read, Private Write
- Organizations, services, working hours: Public read (for booking flow)
- Appointments, queues: Private read (owner + admin only)
- All write operations require authentication + authorization

### 4. Defense in Depth
- Application logic + Security rules
- Field-level validation
- Document-level authorization
- Collection-level access control

---

## Data Flow Diagram

```
[Customer User] ─────read────→ [Organizations]
                              │
                              ├─→ [Services] (browse catalog)
                              │
                              └─→ [Working Hours] (check availability)
                              
[Customer User] ─────create───→ [Appointments] (book service)
                └─────read────→ [Own Appointments]
                
[Admin User] ────────read/write→ [Own Organization]
             │
             ├──────create/update→ [Services]
             │
             ├──────create/update→ [Working Hours]
             │
             └──────read/update───→ [Appointments in Org]
                    └──update─────→ [Queues in Org]
```

---

## Indexes Required

Firestore composite indexes needed for efficient queries:

1. **Appointments by Customer**
   - Collection: `organizations/{orgId}/appointments`
   - Fields: `customerId` (ASC), `scheduledAt` (DESC)
   
2. **Appointments by Date Range**
   - Collection: `organizations/{orgId}/appointments`
   - Fields: `scheduledAt` (ASC), `status` (ASC)

3. **Active Queues**
   - Collection: `organizations/{orgId}/queues`
   - Fields: `status` (ASC), `joinedAt` (ASC)

**Note**: These indexes will be auto-generated by Firestore on first query with warning. Deploy via `firestore.indexes.json` in production.

---

**Design Complete**: February 25, 2026  
**Next Step**: Create contracts/ directory with security behavior specifications
