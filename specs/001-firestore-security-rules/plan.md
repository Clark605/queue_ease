# Implementation Plan: Firestore Security Rules

**Branch**: `001-firestore-security-rules` | **Date**: February 25, 2026 | **Spec**: [spec.md](./spec.md)

## Summary

Deploy comprehensive Firestore security rules to enforce role-based access control (RBAC) for all 6 collections (users, organizations, services, working_hours, appointments, queues). **NO application code changes required** - this is a pure backend security layer. Rules will authenticate all requests, validate data integrity, prevent cross-organization access, and enable customers to book appointments only under their own userId.

## 🚀 IMPORTANT: NO FLUTTER CODE CHANGES NEEDED

**This feature does NOT require any changes to the Flutter app.**

The existing app already:
- ✅ Uses Firebase Authentication
- ✅ Has proper data models with `toMap()` methods
- ✅ Has error handling that catches permission denied errors
- ✅ Uses correct field names and data types

Security rules execute server-side and operate transparently.

---

## Manual Steps Required in Firebase Console

### 📋 Pre-Implementation Checklist

1. **Verify Firebase CLI Installation**
```bash
firebase --version  # Should be 13.x+
```

2. **Login to Firebase**
```bash
firebase login
```

3. **Verify Project Access**
   - Open [Firebase Console](https://console.firebase.google.com/)
   - Confirm access to:
     - **Dev**: QueueEase Dev
     - **Prod**: ease-queue
   - Role required: Editor or Owner

4. **Verify `.firebaserc` Configuration**
```bash
# Check current config
cat .firebaserc

# Should show:
# {
#   "projects": {
#     "dev": "ease-queue-dev",
#     "prod": "ease-queue"
#   }
# }
```

5. **Install Emulator Dependencies** (for testing)
```bash
npm install -g firebase-tools
firebase init emulators  # Select: Firestore emulator
```

---

## Technical Context

**Language/Version**: Firestore Rules Language v2 (declarative, server-side execution)  
**Primary Dependencies**: Firebase CLI 13.x, Firebase Emulator Suite, @firebase/rules-unit-testing  
**Storage**: Cloud Firestore - Dev: QueueEase Dev, Prod: ease-queue  
**Testing**: Firebase Emulator Suite + automated rules unit tests  
**Performance Goals**: <100ms rule evaluation, <100KB file size  
**Constraints**: Declarative rules (no loops), 1:1 admin-org relationship, enum validation for status/role fields

---

## Constitutional Requirements Check ✅

All mandates **PASS** - no application code changes, pure infrastructure:

- ✅ **Code Quality**: Rules follow Firestore best practices (DRY with functions)
- ✅ **Testing**: 100% rules coverage via Firebase Emulator Suite
- ✅ **Security**: Implements Constitution "Security & Compliance" section (RBAC, PII protection)
- ✅ **Performance**: Server-side execution, zero app impact
- ✅ **Fast Delivery**: 3 days, no dependencies on other features

---

## Project Structure

### New Files Created

```text
# Security Rules (NEW)
firestore.rules                    # Main rules file at repo root

# Testing (NEW)
test/firestore_rules/              # Rules unit tests
├── setup.ts
├── users.test.ts
├── organizations.test.ts
├── services.test.ts
├── working_hours.test.ts
├── appointments.test.ts
└── queues.test.ts

# Documentation (NEW)
specs/001-firestore-security-rules/
├── plan.md                        # This file
├── research.md                    # Phase 0 output
├── data-model.md                  # Phase 1 output
├── quickstart.md                  # Phase 1 output
└── contracts/
    └── security-rules-contract.md
```

### No Changes to Existing Flutter Code

```text
lib/                               # ← NO CHANGES
├── shared/auth/                   # ← NO CHANGES
├── shared/organization/           # ← NO CHANGES
├── shared/booking/                # ← NO CHANGES
├── shared/queue/                  # ← NO CHANGES
└── core/error/                    # ← NO CHANGES (already handles permission errors)

firebase.json                      # ← NO CHANGES (already references firestore.rules)
pubspec.yaml                       # ← NO CHANGES (no new dependencies)
```

---

## Implementation Phases

### Phase 0: Research (0.5 days)

**Research Topics**:
1. Firestore RBAC patterns (admin ownership, customer read-only)
2. Enum validation techniques (status, role fields)
3. Firebase Emulator Suite testing strategies
4. Field validation patterns (required fields, data types, string lengths)
5. Deployment workflows (dev/prod, rollback procedures)

**Deliverable**: `research.md` with code examples and best practices

---

### Phase 1: Design & Documentation (0.5 days)

#### Create Data Model Documentation (`data-model.md`)

Document all 6 collections:
1. **users** - Document ID: Firebase Auth UID
   - Fields: uid, email, role ("admin"|"customer"), displayName, phone, orgName
   - Access: Own UID only (OR admin if customer has appointments in admin's org)

2. **organizations** - Document ID: Auto-generated
   - Fields: name, adminUid, bookingLinkSlug, isOpen, createdAt, qrCodeUrl, address, logoUrl, description
   - Access: Read all authenticated, Write admin owner only

3. **organizations/{orgId}/services** - Document ID: Auto-generated
   - Fields: orgId, name, durationMinutes, timeMarginMinutes, isActive, createdAt, price, queueType, description
   - Access: Read all authenticated, Write admin owner only

4. **organizations/{orgId}/working_hours** - Document ID: "0"-"6" (dayOfWeek)
   - Fields: orgId, isOpen, openTime ("HH:mm"), closeTime ("HH:mm"), breakStart, breakEnd
   - Access: Read all authenticated, Write admin owner only

5. **organizations/{orgId}/appointments** - Document ID: Auto-generated
   - Fields: customerId, serviceId, scheduledAt, status ("booked"|"inQueue"|"serving"|"completed"|"noShow"), createdAt
   - Access: Read (customer own OR admin owner), Create (customer only with own customerId), Update/Delete (admin owner only)

6. **organizations/{orgId}/queues** - Document ID: Auto-generated
   - Fields: customerId, serviceId, status ("active"|"paused"|"closed"), queueNumber, createdAt, waitEstimate
   - Access: Read (customer own OR admin owner), Write (admin owner only)

#### Create Security Rules Contract (`contracts/security-rules-contract.md`)

For each collection × operation, document:
- ✅ ALLOW conditions
- ❌ DENY conditions
- Test scenarios

#### Create Quickstart Guide (`quickstart.md`)

1. Prerequisites (Firebase CLI, Node.js, Java)
2. Local testing with emulator
3. Running rules unit tests
4. Deploying to dev
5. Deploying to prod
6. Rollback procedure

---

### Phase 2: Write Rules (1 day)

#### Create `firestore.rules` File

**Structure**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() { ... }
    function isAdmin() { ... }
    function ownsOrganization(orgId) { ... }
    function isValidEnum(value, allowed) { ... }
    function hasRequiredFields(required) { ... }
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId 
                    && request.resource.data.role in ['admin', 'customer'];
      allow update: if request.auth.uid == userId;
    }
    
    // Organizations collection
    match /organizations/{orgId} {
      allow read: if request.auth != null;
      allow create: if isAdmin() 
                    && request.resource.data.adminUid == request.auth.uid;
      allow update, delete: if ownsOrganization(orgId);
      
      // Subcollections
      match /services/{serviceId} { ... }
      match /working_hours/{dayOfWeek} { ... }
      match /appointments/{appointmentId} { ... }
      match /queues/{queueId} { ... }
    }
  }
}
```

**Key Validations**:
- Enum values: status (booked/inQueue/serving/completed/noShow, active/paused/closed), role (admin/customer)
- Required fields for each collection
- Data types (string, int, bool, timestamp)
- String lengths (name: 100, description: 500)
- Immutable `createdAt` on updates
- Working hours doc ID must be 0-6
- Time format: HH:mm regex

---

### Phase 3: Testing (1 day)

#### Setup Test Infrastructure

```bash
npm init -y
npm install --save-dev @firebase/rules-unit-testing mocha chai ts-node typescript
```

#### Create Test Files

**File**: `test/firestore_rules/users.test.ts`
```typescript
import { describe, it } from 'mocha';
import { expect } from 'chai';
import { setupTestEnv, getAuthenticatedContext } from './setup';
import * as testing from '@firebase/rules-unit-testing';

describe('Users Collection', () => {
  it('allows user to read own document', async () => {
    const env = await setupTestEnv();
    const context = getAuthenticatedContext(env, 'user123');
    const doc = context.firestore().collection('users').doc('user123');
    
    await testing.assertSucceeds(doc.get());
  });

  it('denies user from reading another user', async () => {
    const env = await setupTestEnv();
    const context = getAuthenticatedContext(env, 'user123');
    const doc = context.firestore().collection('users').doc('user456');
    
    await testing.assertFails(doc.get());
  });
});
```

**Test Coverage**:
- All 6 collections
- All operations (read/create/update/delete)
- Positive cases (authorized access)
- Negative cases (unauthorized denials)
- Enum validation (invalid status/role values)
- Field validation (missing required, invalid types)

**Run Tests**:
```bash
npm test
# Expected: 50+ tests passing
```

---

### Phase 4: Deployment (0.5 days)

#### Deploy to Dev Environment

```bash
# Start with dev
firebase use dev

# Dry run (check rules syntax)
firebase deploy --only firestore:rules --debug

# Actual deployment
firebase deploy --only firestore:rules
```

**Verification**:
1. Firebase Console → QueueEase Dev → Firestore → Rules
2. Verify rules show as "Published"
3. Test with real app - admin creates org, customer books appointment
4. Monitor for 24 hours before prod deployment

#### Deploy to Production

**⚠️ CRITICAL: Production Deployment**

**Pre-Production Checklist**:
- [ ] Dev deployment successful for 24+ hours
- [ ] No permission errors in dev environment
- [ ] All stakeholders notified
- [ ] Rollback plan documented
- [ ] Deployment during low-traffic window

**Commands**:
```bash
# Switch to prod
firebase use prod

# Deploy
firebase deploy --only firestore:rules

# Prompt: Do you want to continue? → Type 'y'
```

**Post-Deployment**:
1. Firebase Console → ease-queue → Firestore → Rules
2. Verify "Published" status
3. Monitor error logs for 1 hour
4. Test critical paths:
   - Admin creates organization
   - Customer books appointment
5. Watch Crashlytics for app crashes

#### Rollback if Needed

**Option 1: Firebase Console** (FASTEST)
1. Firestore → Rules → "View history"
2. Select previous version
3. Click "Restore"

**Option 2: CLI**
```bash
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules
```

---

## Manual Steps Summary

### Before Implementation
1. ✅ Verify Firebase CLI: `firebase --version`
2. ✅ Login: `firebase login`
3. ✅ Confirm access to both Firebase projects
4. ✅ Check `.firebaserc` configuration
5. ✅ Install emulator: `firebase init emulators`

### During Testing
1. ✅ Start emulator: `firebase emulators:start`
2. ✅ Open UI: http://localhost:4000
3. ✅ Manual test scenarios in emulator
4. ✅ Run automated tests: `npm test`

### During Deployment
1. ✅ **Dev Deployment**:
   - `firebase use dev`
   - `firebase deploy --only firestore:rules`
   - Verify in Console (QueueEase Dev)
   - Monitor for 24 hours

2. ✅ **Prod Deployment**:
   - `firebase use prod`
   - `firebase deploy --only firestore:rules`
   - Verify in Console (ease-queue)
   - Monitor error logs for 1 hour

### Post-Deployment Monitoring
1. ✅ Firebase Console → Firestore → Usage (watch for permission denied spikes)
2. ✅ Crashlytics → Monitor for app crashes
3. ✅ Firestore → Rules → History (audit trail)

---

##Success Criteria Validation

| ID | Criterion | How to Verify | Expected Result |
|----|-----------|---------------|-----------------|
| SC-001 | 100% unauthorized access blocked | Run test suite | All negative tests pass |
| SC-002 | Deploy to dev + prod successful | Firebase CLI output | "✓ Deploy complete!" |
| SC-003 | All 20 FRs validated | Test coverage report | 20/20 tests passing |
| SC-004 | Cross-org access prevented | Test: Admin A → Admin B's org | Permission denied |
| SC-005 | Customer impersonation prevented | Test: Customer A → Customer B appointment | Permission denied |
| SC-006 | Missing fields rejected | Test: Create org without name | Invalid argument error |
| SC-007 | Invalid types rejected | Test: String for int field | Invalid argument error |
| SC-008 | Rules file <100KB | `ls -lh firestore.rules` | ~5-8KB (well under limit) |
| SC-009 | Evaluation <100ms | Firebase Console metrics | Avg <10ms |
| SC-010 | Zero vulnerabilities | Code review + testing | No bypass patterns |
| SC-011 | Test coverage >80% | Emulator coverage report | Constitution Principle III |

---

## Timeline

| Phase | Duration | Dates |
|-------|----------|-------|
| Phase 0: Research | 0.5 days | Feb 26 AM-PM |
| Phase 1: Design & Docs | 0.5 days | Feb 26 PM - Feb 27 AM |
| Phase 2: Write Rules | 1 day | Feb 27 AM-PM |
| Phase 3: Testing | 1 day | Feb 28 AM-PM |
| Phase 4: Deployment | 0.5 days | Mar 1 AM-PM |
| **Total** | **3.5 days** | **Feb 26 - Mar 1** |

**Aligns with PROJECT_TIMELINE.md ✅** (Phase 2: Security Rules, 3 days allocated)

---

## Risk Mitigation

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Rules break app functionality | Low | Comprehensive emulator testing + staged rollout |
| Permission denied for valid operations | Medium | Positive test cases for all user actions + monitoring |
| Deployment to wrong project | Low | Use CLI aliases + confirm prompts |
| Rules become unmaintainable | Low | DRY with functions + clear comments |

---

## Next Steps

1. ✅ **Execute Phase 0**: Create `research.md`
2. ✅ **Execute Phase 1**: Create `data-model.md`, `contracts/`, `quickstart.md`
3. ✅ **Update Agent Context**: Run `update-agent-context.ps1`
4. ✅ **Execute Phase 2**: Write `firestore.rules`
5. ✅ **Execute Phase 3**: Create test suite
6. ✅ **Execute Phase 4**: Deploy to dev → prod
7. ✅ **Merge to Develop**: After successful monitoring period

---

**Plan Status**: ✅ COMPLETE  
**Estimated Effort**: 3.5 days (1 developer)  
**Risk Level**: LOW (declarative, comprehensive testing, staged deployment)  
**Code Changes**: ZERO Flutter app changes required ✅
