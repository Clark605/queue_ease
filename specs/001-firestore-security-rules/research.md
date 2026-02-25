# Research: Firestore Security Rules Best Practices

**Feature**: 001-firestore-security-rules  
**Date**: February 25, 2026  
**Phase**: 0 - Research & Discovery

## Research Objectives

This document consolidates best practices, patterns, and strategies for implementing comprehensive Firestore security rules for the Queue Ease application.

---

## 1. Firestore RBAC Patterns

### Admin Ownership Verification

**Pattern**: Verify admin owns organization before allowing mutations

```javascript
function isAuthenticated() {
  return request.auth != null;
}

function getUserRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}

function isAdmin() {
  return isAuthenticated() && getUserRole() == 'admin';
}

function ownsOrganization(orgId) {
  return isAdmin() && 
         get(/databases/$(database)/documents/organizations/$(orgId)).data.adminUid == request.auth.uid;
}
```

**Usage**:
```javascript
match /organizations/{orgId} {
  allow update, delete: if ownsOrganization(orgId);
}
```

### Customer Read-Only Access

**Pattern**: Allow authenticated customers to read public data

```javascript
function canReadPublicOrgData() {
  return isAuthenticated();  // Any authenticated user
}

match /organizations/{orgId} {
  allow read: if canReadPublicOrgData();
  
  match /services/{serviceId} {
    allow read: if canReadPublicOrgData();
  }
  
  match /working_hours/{dayOfWeek} {
    allow read: if canReadPublicOrgData();
  }
}
```

### Performance Optimization

**Recommendation**: Cache `get()` calls to avoid excessive document reads

```javascript
// ❌ BAD: Multiple get() calls
function ownsOrganization(orgId) {
  return get(...).data.adminUid == request.auth.uid &&
         get(...).data.isActive &&
         get(...).data.createdAt != null;
}

// ✅ GOOD: Single get() then reference
function ownsOrganization(orgId) {
  let org = get(/databases/$(database)/documents/organizations/$(orgId));
  return org.data.adminUid == request.auth.uid;
}
```

**Decision**: Use `get()` sparingly - only for critical cross-collection checks. Prefer `request.resource.data` for validation.

---

## 2. Enum Validation Techniques

### Reusable Enum Validator Function

**Pattern**: Create generic function for enum validation

```javascript
function isValidEnum(value, allowedValues) {
  return value in allowedValues;
}

// Usage for appointment status
function isValidAppointmentStatus(status) {
  return isValidEnum(status, ['booked', 'inQueue', 'serving', 'completed', 'noShow']);
}

// Usage for queue status
function isValidQueueStatus(status) {
  return isValidEnum(status, ['active', 'paused', 'closed']);
}

// Usage for user role
function isValidRole(role) {
  return isValidEnum(role, ['admin', 'customer']);
}
```

**Application**:
```javascript
match /organizations/{orgId}/appointments/{appointmentId} {
  allow create: if isAuthenticated() &&
                request.resource.data.customerId == request.auth.uid &&
                isValidAppointmentStatus(request.resource.data.status);
}
```

### Alternative: Direct Validation

**Pattern**: Inline validation for simpler cases

```javascript
allow create: if request.resource.data.status in ['booked', 'inQueue', 'serving', 'completed', 'noShow'];
```

**Decision**: Use function approach for consistency and maintainability.

---

## 3. Testing Strategy with Firebase Emulator Suite

### Setup Test Environment

**File**: `test/firestore_rules/setup.ts`

```typescript
import * as testing from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

export const PROJECT_ID = 'queue-ease-test';
export const RULES_PATH = path.resolve(__dirname, '../../firestore.rules');

let testEnv: any = null;

export async function setupTestEnv() {
  if (testEnv) {
    await testEnv.cleanup();
  }
  
  testEnv = await testing.initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
  
  return testEnv;
}

export function getAuthenticatedContext(env: any, uid: string, customClaims: any = {}) {
  return env.authenticatedContext(uid, customClaims);
}

export function getUnauthenticatedContext(env: any) {
  return env.unauthenticatedContext();
}

export async function cleanup(env: any) {
  await testing.clearFirestoreData({ projectId: PROJECT_ID });
  await env.cleanup();
}
```

### Test Pattern: Positive and Negative Cases

```typescript
describe('Organization Access Control', () => {
  let env: any;
  
  beforeEach(async () => {
    env = await setupTestEnv();
    
    // Setup: Create test user and organization
    await env.withSecurityRulesDisabled(async (context: any) => {
      await context.firestore().collection('users').doc('admin1').set({
        uid: 'admin1',
        email: 'admin@example.com',
        role: 'admin',
      });
      
      await context.firestore().collection('organizations').doc('org1').set({
        name: 'Test Org',
        adminUid: 'admin1',
        bookingLinkSlug: 'test-org',
        isOpen: true,
        createdAt: new Date(),
      });
    });
  });
  
  afterEach(async () => {
    await cleanup(env);
  });
  
  describe('Positive Cases', () => {
    it('admin can update own organization', async () => {
      const context = getAuthenticatedContext(env, 'admin1');
      const doc = context.firestore().collection('organizations').doc('org1');
      
      await testing.assertSucceeds(
        doc.update({ isOpen: false })
      );
    });
  });
  
  describe('Negative Cases', () => {
    it('admin cannot update another admin organization', async () => {
      const context = getAuthenticatedContext(env, 'admin2');
      const doc = context.firestore().collection('organizations').doc('org1');
      
      await testing.assertFails(
        doc.update({ isOpen: false })
      );
    });
  });
});
```

### Running Tests

```bash
# Start emulator
firebase emulators:start --only firestore

# In another terminal, run tests
npm test

# Or run specific test file
npm test -- test/firestore_rules/organizations.test.ts
```

**Decision**: Write comprehensive test suite covering all collections × all operations × positive/negative cases.

---

## 4. Field Validation Best Practices

### Required Fields Pattern

**Pattern**: Validate all required fields are present

```javascript
function hasRequiredUserFields() {
  return request.resource.data.keys().hasAll(['uid', 'email', 'role']);
}

function hasRequiredOrgFields() {
  return request.resource.data.keys().hasAll([
    'name',
    'adminUid',
    'bookingLinkSlug',
    'isOpen',
    'createdAt'
  ]);
}
```

### Data Type Validation

**Pattern**: Verify field types match schema

```javascript
function hasValidFieldTypes() {
  return request.resource.data.name is string &&
         request.resource.data.durationMinutes is int &&
         request.resource.data.isActive is bool &&
         request.resource.data.createdAt is timestamp;
}
```

### String Length Limits

**Pattern**: Enforce maximum string lengths

```javascript
function hasValidStringLengths() {
  return request.resource.data.name.size() <= 100 &&
         (request.resource.data.description == null || 
          request.resource.data.description.size() <= 500) &&
         (request.resource.data.address == null || 
          request.resource.data.address.size() <= 200);
}
```

### Time Format Validation (HH:mm)

**Pattern**: Use regex to validate time strings

```javascript
function isValidTimeFormat(time) {
  // Matches HH:mm (00:00 to 23:59)
  return time.matches('^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
}

match /organizations/{orgId}/working_hours/{dayOfWeek} {
  allow create, update: if 
    isValidTimeFormat(request.resource.data.openTime) &&
    isValidTimeFormat(request.resource.data.closeTime);
}
```

### Preventing Unexpected Fields

**Pattern**: Whitelist allowed fields

```javascript
function hasOnlyAllowedFields(allowedFields) {
  return request.resource.data.keys().hasOnly(allowedFields);
}

match /organizations/{orgId}/services/{serviceId} {
  allow create: if hasOnlyAllowedFields([
    'orgId',
    'name',
    'durationMinutes',
    'timeMarginMinutes',
    'isActive',
    'createdAt',
    'price',
    'queueType',
    'description'
  ]);
}
```

### Immutable Fields Pattern

**Pattern**: Prevent modification of specific fields on updates

```javascript
function createdAtNotModified() {
  return !request.resource.data.diff(resource.data).affectedKeys().hasAny(['createdAt']);
}

function immutableFieldsNotModified() {
  return !request.resource.data.diff(resource.data).affectedKeys().hasAny([
    'createdAt',
    'uid',
    'adminUid'
  ]);
}

match /users/{userId} {
  allow update: if request.auth.uid == userId &&
                immutableFieldsNotModified();
}
```

**Decision**: Use all these patterns to create robust validation rules.

---

## 5. Deployment Workflow

### Development Environment

**Steps**:
```bash
# 1. Switch to dev project
firebase use dev

# 2. (Optional) Dry run to check syntax
firebase deploy --only firestore:rules --debug

# 3. Deploy rules
firebase deploy --only firestore:rules

# 4. Verify in Firebase Console
# Navigate to: Firebase Console → QueueEase Dev → Firestore → Rules

# 5. Test with real app
# Run Flutter app with dev flavor:
flutter run --flavor dev -t lib/main_dev.dart
```

### Production Environment

**Checklist before prod deployment**:
- [ ] Dev deployment successful for 24+ hours
- [ ] No permission-denied errors in dev logs
- [ ] All automated tests passing
- [ ] Manual testing completed
- [ ] Stakeholders notified
- [ ] Deployment during low-traffic window
- [ ] Rollback plan documented

**Steps**:
```bash
# 1. Switch to prod project
firebase use prod

# 2. Review rules one final time
cat firestore.rules

# 3. Deploy with confirmation
firebase deploy --only firestore:rules
# Prompt: "Do you want to continue?" → Type 'y'

# 4. Verify in Firebase Console
# Navigate to: Firebase Console → ease-queue → Firestore → Rules
# Check for "Published" status with timestamp

# 5. Monitor logs for 1 hour
# Firebase Console → Firestore → Usage tab
# Watch for spike in "Permission denied" errors
```

### Rollback Procedure

**Option 1: Via Firebase Console (Fastest)**
1. Firebase Console → Firestore → Rules
2. Click "View history" button
3. Select previous version
4. Click "Restore"
5. Confirm restoration

**Option 2: Via CLI**
```bash
# Checkout previous version
git log --oneline firestore.rules
git checkout <commit-hash> firestore.rules

# Deploy reverted rules
firebase deploy --only firestore:rules

# Or rollback to HEAD~1
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules
```

**Option 3: Emergency Open Rules** (Last Resort)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // ⚠️ TEMPORARY: Emergency open rules
      // TODO: Replace with proper rules ASAP
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ WARNING**: Emergency rules remove all security. Use ONLY for critical incidents. Replace within 1 hour.

### Version Control

**Best Practices**:
- Commit `firestore.rules` to git after every change
- Use descriptive commit messages: "Add appointment booking rules for customers"
- Tag production deployments: `git tag -a firestore-rules-v1.0 -m "Initial production deployment"`
- Maintain `RULES_CHANGELOG.md` documenting major rule changes

**Decision**: Always test in dev → monitor 24 hours → deploy to prod → monitor 1 hour → merge PR.

---

## 6. Cross-Collection Authorization Pattern

### Admin Access to Customer Profiles

**Requirement**: Admin can read customer user profile IF customer has appointments/queues in admin's organization.

**Challenge**: Firestore rules cannot query subcollections efficiently. Need alternative approach.

**Solution Patterns**:

#### Pattern A: Application-Level Enforcement (Recommended)
- Security rules: Users can only read own profile (strict)
- Application code: Admin queries appointments/queues directly (already has customerId)
- Admin UI displays customer info from appointment/queue documents (duplicate data)

**Pros**: Simple rules, no performance issues
**Cons**: Data duplication (customer name in appointments)

#### Pattern B: Custom Claims (Future Enhancement)
- Cloud Function on appointment creation adds custom claim to admin auth token
- Security rules check custom claim for extended access
- Token refresh required to update claims

**Pros**: Clean separation, no data duplication
**Cons**: Requires Cloud Functions (Phase 5), token refresh complexity

**Decision**: Use Pattern A for MVP. Customer contact info (name, phone) already duplicated in appointment documents for admin display. Pattern B considered for future enhancement when Cloud Functions are implemented.

---

## Summary of Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| **Admin Ownership** | Single `get()` call with caching | Balance security with performance |
| **Enum Validation** | Reusable functions for all enums | DRY principle, maintainability |
| **Testing Strategy** | @firebase/rules-unit-testing with 50+ tests | Constitutional requirement, comprehensive coverage |
| **Field Validation** | Whitelist pattern + type checks + length limits | Defense in depth, strict validation |
| **Time Format** | Regex validation for HH:mm | Prevent invalid time strings |
| **Immutable Fields** | Prevent createdAt, uid, adminUid modification | Data integrity |
| **Deployment** | Dev 24h → Prod with monitoring | Staged rollout, risk mitigation |
| **Admin-Customer Access** | Application-level enforcement (Pattern A) | MVP-appropriate, no Cloud Functions dependency |
| **Rollback Strategy** | Firebase Console history restoration | Fastest recovery path |
| **Version Control** | Git + tags for prod deployments | Audit trail, easy rollback |

---

## References

1. [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
2. [Firestore Security Rules Reference](https://firebase.google.com/docs/firestore/security/rules-structure)
3. [Firebase Rules Unit Testing](https://firebase.google.com/docs/rules/unit-tests)
4. [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
5. [Effective Firestore Rules Patterns](https://fireship.io/lessons/firestore-security-rules-guide/)

---

**Research Complete**: February 25, 2026  
**Next Phase**: Phase 1 - Design & Contracts (create data-model.md, contracts/, quickstart.md)
