# Security Rules Contract: Authorization Behavior

**Feature**: 001-firestore-security-rules  
**Contract Type**: Backend Security Infrastructure  
**Date**: February 25, 2026

---

## Contract Purpose

This contract defines the **expected authorization behavior** of Firestore security rules for the Queue Ease application. It serves as:

1. **Test specification**: Automated tests validate these behaviors
2. **Documentation**: Developers understand access control model
3. **Acceptance criteria**: Feature completion verified against this contract

---

## Contract Format

Each section specifies:
- **Actor**: Who is attempting access (authenticated user, unauthenticated, specific role)
- **Action**: Firestore operation (read, create, update, delete)
- **Resource**: Collection/document path
- **Expected Result**: ✅ Allow or ❌ Deny
- **Conditions**: Required preconditions for the result

---

## 1. Users Collection (`/users/{userId}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Unauthenticated | `read` | Any user document | ❌ Deny | No auth token |
| Authenticated User | `read` | Own document (`userId == uid`) | ✅ Allow | User owns document |
| Authenticated User | `read` | Other user document | ❌ Deny | Not owner |
| Authenticated User | `create` | Own document (first-time) | ✅ Allow | All required fields present + valid role |
| Authenticated User | `create` | Document with wrong `uid` | ❌ Deny | `uid` field must match `userId` path |
| Authenticated User | `create` | Document with invalid role | ❌ Deny | Role must be "admin" or "customer" |
| Authenticated User | `update` | Own document | ✅ Allow | Cannot modify `uid` or `createdAt` |
| Authenticated User | `update` | Own document (modify `uid`) | ❌ Deny | `uid` is immutable |
| Authenticated User | `update` | Other user document | ❌ Deny | Not owner |
| Authenticated User | `delete` | Any user document | ❌ Deny | No deletes allowed (soft delete only) |

### Test Cases

```typescript
describe('Users Collection Authorization', () => {
  // ✅ PASS: User reads own profile
  test('authenticated user can read own document', async () => {
    await assertSucceeds(
      authenticatedDb('user1').collection('users').doc('user1').get()
    );
  });
  
  // ❌ FAIL: User reads other profile
  test('authenticated user cannot read other user document', async () => {
    await assertFails(
      authenticatedDb('user1').collection('users').doc('user2').get()
    );
  });
  
  // ✅ PASS: Create user with valid fields
  test('user can create own document with valid fields', async () => {
    await assertSucceeds(
      authenticatedDb('user1').collection('users').doc('user1').set({
        uid: 'user1',
        email: 'user1@example.com',
        role: 'customer',
        createdAt: new Date(),
      })
    );
  });
  
  // ❌ FAIL: Create with invalid role
  test('user cannot create document with invalid role', async () => {
    await assertFails(
      authenticatedDb('user1').collection('users').doc('user1').set({
        uid: 'user1',
        email: 'user1@example.com',
        role: 'superadmin',  // Invalid
        createdAt: new Date(),
      })
    );
  });
});
```

---

## 2. Organizations Collection (`/organizations/{orgId}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Unauthenticated | `read` | Any organization | ❌ Deny | No auth token |
| Authenticated User (any role) | `read` | Any organization | ✅ Allow | Public information for booking |
| Admin User | `create` | New organization | ✅ Allow | `adminUid == request.auth.uid` + valid fields |
| Admin User | `update` | Own organization | ✅ Allow | Owns organization (`adminUid` matches) |
| Admin User | `update` | Other admin's organization | ❌ Deny | Not owner |
| Admin User | `delete` | Own organization | ✅ Allow | Owns organization |
| Customer User | `create` | Any organization | ❌ Deny | Only admins can create orgs |
| Customer User | `update` | Any organization | ❌ Deny | Only owner admin can update |

### Test Cases

```typescript
describe('Organizations Collection Authorization', () => {
  // ✅ PASS: Any authenticated user reads public org info
  test('any authenticated user can read organization', async () => {
    await assertSucceeds(
      authenticatedDb('customer1').collection('organizations').doc('org1').get()
    );
  });
  
  // ❌ FAIL: Admin updates other admin's org
  test('admin cannot update another admin organization', async () => {
    await assertFails(
      adminDb('admin2').collection('organizations').doc('org1').update({
        isOpen: false
      })
    );
  });
  
  // ✅ PASS: Admin updates own org
  test('admin can update own organization', async () => {
    await assertSucceeds(
      adminDb('admin1').collection('organizations').doc('org1').update({
        isOpen: false
      })
    );
  });
});
```

---

## 3. Services Subcollection (`/organizations/{orgId}/services/{serviceId}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Unauthenticated | `read` | Any service | ❌ Deny | No auth token |
| Authenticated User | `read` | Any service | ✅ Allow | Public service catalog |
| Organization Owner (Admin) | `create` | Service in own org | ✅ Allow | `ownsOrganization(orgId)` + valid fields |
| Organization Owner | `update` | Service in own org | ✅ Allow | Owns parent organization |
| Organization Owner | `delete` | Service in own org | ✅ Allow | Owns parent organization |
| Other Admin | `create/update/delete` | Service in other org | ❌ Deny | Not owner of parent org |
| Customer User | `create/update/delete` | Any service | ❌ Deny | Only org owner can mutate services |

### Test Cases

```typescript
describe('Services Subcollection Authorization', () => {
  // ✅ PASS: Customer reads public service
  test('customer can read service catalog', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/services')
        .doc('service1')
        .get()
    );
  });
  
  // ❌ FAIL: Customer creates service
  test('customer cannot create service', async () => {
    await assertFails(
      authenticatedDb('customer1')
        .collection('organizations/org1/services')
        .add({
          orgId: 'org1',
          name: 'Haircut',
          durationMinutes: 30,
          isActive: true,
          createdAt: new Date(),
        })
    );
  });
  
  // ✅ PASS: Admin creates service in own org
  test('admin can create service in own organization', async () => {
    await assertSucceeds(
      adminDb('admin1')
        .collection('organizations/org1/services')
        .add({
          orgId: 'org1',
          name: 'Haircut',
          durationMinutes: 30,
          isActive: true,
          createdAt: new Date(),
        })
    );
  });
});
```

---

## 4. Working Hours Subcollection (`/organizations/{orgId}/working_hours/{dayOfWeek}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Authenticated User | `read` | Any working hours | ✅ Allow | Public operating hours |
| Organization Owner | `create` | Working hours in own org | ✅ Allow | Valid `dayOfWeek` (0-6) + time format |
| Organization Owner | `update` | Working hours in own org | ✅ Allow | Owns parent organization |
| Organization Owner | `delete` | Working hours in own org | ✅ Allow | Owns parent organization |
| Other Admin | `create/update/delete` | Working hours in other org | ❌ Deny | Not owner |
| Customer User | `create/update/delete` | Any working hours | ❌ Deny | Only org owner can mutate |

### Test Cases

```typescript
describe('Working Hours Subcollection Authorization', () => {
  // ✅ PASS: Customer reads working hours
  test('customer can read working hours', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/working_hours')
        .doc('0')
        .get()
    );
  });
  
  // ❌ FAIL: Create with invalid time format
  test('cannot create working hours with invalid time format', async () => {
    await assertFails(
      adminDb('admin1')
        .collection('organizations/org1/working_hours')
        .doc('0')
        .set({
          orgId: 'org1',
          dayOfWeek: 0,
          isOpen: true,
          openTime: '25:00',  // Invalid
          closeTime: '17:00',
        })
    );
  });
  
  // ✅ PASS: Create with valid time format
  test('admin can create working hours with valid HH:mm format', async () => {
    await assertSucceeds(
      adminDb('admin1')
        .collection('organizations/org1/working_hours')
        .doc('0')
        .set({
          orgId: 'org1',
          dayOfWeek: 0,
          isOpen: true,
          openTime: '09:00',
          closeTime: '17:00',
        })
    );
  });
});
```

---

## 5. Appointments Subcollection (`/organizations/{orgId}/appointments/{appointmentId}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Customer User | `read` | Own appointment | ✅ Allow | `customerId == request.auth.uid` |
| Customer User | `read` | Other customer appointment | ❌ Deny | Not owner |
| Organization Owner | `read` | Appointment in own org | ✅ Allow | Owns parent organization |
| Customer User | `create` | Appointment for self | ✅ Allow | `customerId == uid` + valid status + future date |
| Customer User | `create` | Appointment with invalid status | ❌ Deny | Status must be valid enum |
| Customer User | `update` | Own appointment (status/notes) | ✅ Allow | Limited fields only |
| Customer User | `update` | Own appointment (immutable fields) | ❌ Deny | Cannot change `orgId`, `serviceId`, `scheduledAt` |
| Organization Owner | `update` | Appointment in own org | ✅ Allow | Any field updates |
| Organization Owner | `delete` | Appointment in own org | ✅ Allow | Owns parent organization |

### Test Cases

```typescript
describe('Appointments Subcollection Authorization', () => {
  // ✅ PASS: Customer reads own appointment
  test('customer can read own appointment', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/appointments')
        .doc('appt1')
        .get()
    );
  });
  
  // ❌ FAIL: Create with invalid status
  test('customer cannot create appointment with invalid status', async () => {
    await assertFails(
      authenticatedDb('customer1')
        .collection('organizations/org1/appointments')
        .add({
          orgId: 'org1',
          customerId: 'customer1',
          serviceId: 'service1',
          scheduledAt: new Date(Date.now() + 86400000),
          status: 'confirmed',  // Invalid
          createdAt: new Date(),
        })
    );
  });
  
  // ✅ PASS: Create with valid status enum
  test('customer can create appointment with valid status', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/appointments')
        .add({
          orgId: 'org1',
          customerId: 'customer1',
          serviceId: 'service1',
          scheduledAt: new Date(Date.now() + 86400000), // Tomorrow
          status: 'booked',  // Valid
          createdAt: new Date(),
        })
    );
  });
  
  // ❌ FAIL: Customer updates immutable field
  test('customer cannot change appointment dateTime', async () => {
    await assertFails(
      authenticatedDb('customer1')
        .collection('organizations/org1/appointments')
        .doc('appt1')
        .update({
          scheduledAt: new Date(Date.now() + 172800000),  // Different date
        })
    );
  });
  
  // ✅ PASS: Admin updates any field
  test('admin can update appointment status', async () => {
    await assertSucceeds(
      adminDb('admin1')
        .collection('organizations/org1/appointments')
        .doc('appt1')
        .update({
          status: 'serving',
        })
    );
  });
});
```

---

## 6. Queues Subcollection (`/organizations/{orgId}/queues/{queueId}`)

### Authorization Matrix

| Actor | Action | Resource | Expected Result | Conditions |
|-------|--------|----------|----------------|------------|
| Customer User | `read` | Own queue entry | ✅ Allow | `customerId == request.auth.uid` |
| Customer User | `read` | Other customer queue entry | ❌ Deny | Not owner |
| Organization Owner | `read` | Queue entry in own org | ✅ Allow | Owns parent organization |
| Customer User | `create` | Queue entry for self | ✅ Allow | `customerId == uid` + valid status |
| Customer User | `create` | Queue entry with invalid status | ❌ Deny | Status must be "active", "paused", or "closed" |
| Customer User | `update` | Own queue entry | ❌ Deny | Only admin controls queue progression |
| Organization Owner | `update` | Queue entry in own org | ✅ Allow | Admin controls queue |
| Organization Owner | `delete` | Queue entry in own org | ✅ Allow | Owns parent organization |

### Test Cases

```typescript
describe('Queues Subcollection Authorization', () => {
  // ✅ PASS: Customer reads own queue entry
  test('customer can read own queue entry', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/queues')
        .doc('queue1')
        .get()
    );
  });
  
  // ❌ FAIL: Create with invalid status
  test('customer cannot create queue with invalid status', async () => {
    await assertFails(
      authenticatedDb('customer1')
        .collection('organizations/org1/queues')
        .add({
          orgId: 'org1',
          customerId: 'customer1',
          serviceId: 'service1',
          queueNumber: 5,
          status: 'pending',  // Invalid
          joinedAt: new Date(),
        })
    );
  });
  
  // ✅ PASS: Create with valid status
  test('customer can create queue with valid status', async () => {
    await assertSucceeds(
      authenticatedDb('customer1')
        .collection('organizations/org1/queues')
        .add({
          orgId: 'org1',
          customerId: 'customer1',
          serviceId: 'service1',
          queueNumber: 5,
          status: 'active',  // Valid
          joinedAt: new Date(),
        })
    );
  });
  
  // ❌ FAIL: Customer updates queue
  test('customer cannot update queue status', async () => {
    await assertFails(
      authenticatedDb('customer1')
        .collection('organizations/org1/queues')
        .doc('queue1')
        .update({
          status: 'paused',
        })
    );
  });
  
  // ✅ PASS: Admin updates queue
  test('admin can update queue in own organization', async () => {
    await assertSucceeds(
      adminDb('admin1')
        .collection('organizations/org1/queues')
        .doc('queue1')
        .update({
          status: 'serving',
          estimatedWaitMinutes: 0,
        })
    );
  });
});
```

---

## Contract Success Criteria

The Firestore security rules implementation is considered **complete** when:

1. ✅ All 50+ authorization test cases pass
2. ✅ Test coverage includes all 6 collections
3. ✅ Test coverage includes all 4 operations (read/create/update/delete)
4. ✅ Both positive (✅ Allow) and negative (❌ Deny) cases tested
5. ✅ All enum validations tested with valid + invalid values
6. ✅ All immutable field protections tested
7. ✅ All required field validations tested
8. ✅ Firebase Emulator Suite tests run without errors
9. ✅ No security warnings in Firebase Console after deployment
10. ✅ Manual testing passes with real Flutter app (dev environment)

---

## Security Guarantees

By adhering to this contract, the system **guarantees**:

- **Data Privacy**: Users can only read their own private data
- **Data Integrity**: Immutable fields cannot be modified
- **Role Enforcement**: Admins manage orgs, customers book services
- **Data Validation**: Invalid enums, types, and formats rejected
- **Ownership Verification**: Cross-document ownership checks enforced
- **Public Information**: Booking-related data publicly readable
- **Audit Trail**: `createdAt` timestamps immutable for all documents

---

**Contract Version**: 1.0.0  
**Date**: February 25, 2026  
**Status**: ✅ Ready for Implementation (Phase 2)  
**Next Step**: Implement `firestore.rules` file adhering to this contract
