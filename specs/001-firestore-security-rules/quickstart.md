# Quickstart Guide: Firestore Security Rules

**Feature**: 001-firestore-security-rules  
**Audience**: Developers implementing/testing/deploying security rules  
**Date**: February 25, 2026

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Setup](#development-setup)
3. [Testing Workflow](#testing-workflow)
4. [Deployment to Dev](#deployment-to-dev)
5. [Deployment to Production](#deployment-to-production)
6. [Rollback Procedure](#rollback-procedure)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Node.js**: v18.x or later
- **Firebase CLI**: v13.x or later
- **Git**: For version control

### Installation

```powershell
# Install Node.js (Windows - using Chocolatey)
choco install nodejs-lts

# Or download from: https://nodejs.org/

# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version  # Should show 13.x.x
node --version      # Should show v18.x.x or later
```

### Firebase Authentication

```powershell
# Login to Firebase
firebase login

# Verify access to projects
firebase projects:list

# You should see:
# - ease-queue-dev (alias: dev)
# - ease-queue (alias: prod)
```

### Project Aliases Setup

```powershell
# Navigate to project root
cd D:\MyProgrammingProjects\FlutterProjects\queue_ease

# Set up project aliases (if not already configured)
firebase use --add

# Select "ease-queue-dev" and enter alias: dev
# Select "ease-queue" and enter alias: prod

# Verify aliases
firebase use
# Should show: Currently using alias dev (ease-queue-dev)
```

---

## Development Setup

### 1. Checkout Feature Branch

```powershell
# Switch to feature branch
git checkout 001-firestore-security-rules

# Verify you're on correct branch
git branch --show-current
# Output: 001-firestore-security-rules
```

### 2. Install Testing Dependencies

```powershell
# Create test directory if doesn't exist
New-Item -ItemType Directory -Path "test\firestore_rules" -Force

# Navigate to test directory
cd test\firestore_rules

# Initialize Node.js project
npm init -y

# Install testing dependencies
npm install --save-dev @firebase/rules-unit-testing mocha chai typescript ts-node @types/mocha @types/chai

# Create TypeScript config
@"
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./",
    "resolveJsonModule": true
  },
  "include": ["./**/*.ts"],
  "exclude": ["node_modules", "dist"]
}
"@ | Out-File -FilePath "tsconfig.json" -Encoding utf8

# Add test script to package.json
# Manually edit package.json and add:
# "scripts": {
#   "test": "mocha --require ts-node/register **/*.test.ts --timeout 10000"
# }
```

### 3. Create Rules File

```powershell
# Navigate back to project root
cd ..\..

# Create firestore.rules file (template)
@"
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserRole() {
      return get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.role;
    }
    
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    // TODO: Implement collection-specific rules
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
"@ | Out-File -FilePath "firestore.rules" -Encoding utf8
```

---

## Testing Workflow

### Start Firebase Emulator

```powershell
# Terminal 1: Start emulator
firebase emulators:start --only firestore

# Output should show:
# ✔  firestore: Firestore Emulator running on http://localhost:8080
# ✔  All emulators ready! View status and logs at http://127.0.0.1:4000
```

**Keep this terminal running** while testing.

### Write Test Cases

Create `test/firestore_rules/users.test.ts`:

```typescript
import * as testing from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

const PROJECT_ID = 'queue-ease-test';
const RULES_PATH = path.resolve(__dirname, '../../firestore.rules');

let testEnv: any;

beforeEach(async () => {
  testEnv = await testing.initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterEach(async () => {
  await testing.clearFirestoreData({ projectId: PROJECT_ID });
  await testEnv.cleanup();
});

describe('Users Collection', () => {
  it('user can read own document', async () => {
    const userDb = testEnv.authenticatedContext('user1').firestore();
    
    // Setup: Create user document
    await testEnv.withSecurityRulesDisabled(async (context: any) => {
      await context.firestore().collection('users').doc('user1').set({
        uid: 'user1',
        email: 'user@example.com',
        role: 'customer',
        createdAt: new Date(),
      });
    });
    
    // Test: Read own document
    await testing.assertSucceeds(
      userDb.collection('users').doc('user1').get()
    );
  });
  
  it('user cannot read other user document', async () => {
    const userDb = testEnv.authenticatedContext('user1').firestore();
    
    await testEnv.withSecurityRulesDisabled(async (context: any) => {
      await context.firestore().collection('users').doc('user2').set({
        uid: 'user2',
        email: 'user2@example.com',
        role: 'customer',
        createdAt: new Date(),
      });
    });
    
    await testing.assertFails(
      userDb.collection('users').doc('user2').get()
    );
  });
});
```

### Run Tests

```powershell
# Terminal 2: Run tests (emulator still running in Terminal 1)
cd test\firestore_rules
npm test

# Watch mode (auto-rerun on file changes)
npm test -- --watch
```

### Iterate on Rules

1. Edit `firestore.rules` file
2. **Save file** (emulator auto-reloads rules)
3. **Re-run tests** (`npm test`)
4. Repeat until all tests pass

### Check Test Coverage

```powershell
# Generate coverage report (optional)
npm test -- --reporter json > test-results.json

# Manual coverage checklist:
# [ ] All 6 collections tested
# [ ] All 4 operations tested per collection
# [ ] Positive and negative cases for each rule
# [ ] All enum validations tested
# [ ] All immutable field protections tested
```

---

## Deployment to Dev

### Pre-Deployment Checklist

- [ ] All tests passing (`npm test` shows 0 failures)
- [ ] Rules file committed to git
- [ ] Tested with Firebase Emulator
- [ ] Code reviewed (PR approved)

### Deploy to Dev Environment

```powershell
# 1. Switch to dev project
firebase use dev

# 2. Verify current project
firebase projects:list
# Should show (*) next to ease-queue-dev

# 3. Dry run (optional - check for syntax errors)
firebase deploy --only firestore:rules --debug

# 4. Deploy rules
firebase deploy --only firestore:rules

# Output:
# === Deploying to 'ease-queue-dev'...
# i  firestore: reading indexes from firestore.indexes.json...
# i  firestore: reading rules from firestore.rules...
# ✔  firestore: released rules firestore.rules to cloud.firestore
# ✔  Deploy complete!
```

### Verify Deployment in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **QueueEase Dev**
3. Navigate to: **Firestore Database** → **Rules** tab
4. Verify:
   - Status: **Published** (green)
   - Timestamp: Current time
   - Rules content matches your `firestore.rules` file

### Test with Real App

```powershell
# Run Flutter app in dev mode
flutter run --flavor dev -t lib/main_dev.dart

# Test scenarios:
# 1. Sign in as customer → Browse organizations/services
# 2. Sign in as customer → Create appointment
# 3. Sign in as admin → Create service
# 4. Sign in as admin → View appointments

# Monitor Firestore logs in Firebase Console:
# Firestore → Usage tab → Check for "Permission denied" errors
```

### Monitoring (24 Hours)

**Day 1 Post-Deployment**:
- Check Firebase Console → Firestore → Usage tab
- Monitor for spike in "Permission denied" errors
- Check Crashlytics for any new authorization-related crashes
- Ask team members to report any access issues

**If Issues Found**:
- Document the error scenarios
- Fix rules locally
- Re-test with emulator
- Re-deploy to dev
- Monitor again

**If Stable After 24 Hours**:
- Proceed to production deployment

---

## Deployment to Production

### Pre-Production Checklist

- [ ] Dev deployment successful for 24+ hours
- [ ] Zero permission-denied errors in dev logs
- [ ] All stakeholders notified of deployment
- [ ] Rollback plan documented and understood
- [ ] Deployment window scheduled (low-traffic time)

### Deploy to Production

```powershell
# 1. Switch to production project
firebase use prod

# 2. VERIFY current project (CRITICAL!)
firebase use
# Output MUST show: Currently using alias prod (ease-queue)

# 3. Review rules one final time
Get-Content firestore.rules | Select-Object -First 30

# 4. Deploy with confirmation
firebase deploy --only firestore:rules

# Prompt: "You're about to deploy to prod. Continue? (Y/n)"
# Type: y

# Output:
# === Deploying to 'ease-queue'...
# ✔  firestore: released rules firestore.rules to cloud.firestore
# ✔  Deploy complete!
```

### Verify Production Deployment

1. Firebase Console → **ease-queue** project
2. Firestore → Rules tab
3. Verify:
   - Status: **Published**
   - Timestamp: Current time
   - Rules match expected content

### Production Monitoring (1 Hour)

**First Hour Post-Deployment**:
- Open Firebase Console → Firestore → Usage tab
- **Actively monitor** for permission-denied errors
- Check Crashlytics for authorization crashes
- Monitor user reports/support channels

**If Critical Issue Detected**:
- **Immediately rollback** (see Rollback Procedure)
- Notify team
- Document issue for post-mortem

**If Stable After 1 Hour**:
- Continue monitoring for 24 hours
- Deployment considered successful

---

## Rollback Procedure

### Option 1: Firebase Console (Fastest - 30 seconds)

1. Firebase Console → Firestore → **Rules** tab
2. Click **View history** button (top right)
3. Find previous version (before current deployment)
4. Click **Restore** button
5. Confirm restoration
6. **Verify**: Rules tab shows "Published" with previous timestamp

**Use this for**: Emergency rollback (critical production issue)

### Option 2: Git + CLI (Moderate - 2 minutes)

```powershell
# 1. Find previous rules version
git log --oneline firestore.rules

# Output example:
# abc1234 Add appointment booking rules
# def5678 Initial security rules  ← RESTORE THIS

# 2. Checkout previous version
git checkout def5678 firestore.rules

# 3. Verify content
Get-Content firestore.rules | Select-Object -First 20

# 4. Deploy previous version
firebase use prod
firebase deploy --only firestore:rules

# 5. Restore firestore.rules to HEAD (for continued development)
git checkout HEAD firestore.rules
```

**Use this for**: Controlled rollback with version awareness

### Option 3: Emergency Open Rules (Last Resort - 1 minute)

⚠️ **WARNING**: This removes ALL security. Use ONLY for critical incidents.

```powershell
# 1. Create emergency rules file
@"
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // ⚠️ EMERGENCY: Temporarily allow all authenticated access
      // TODO: Replace with proper rules within 1 hour
      allow read, write: if request.auth != null;
    }
  }
}
"@ | Out-File -FilePath "firestore.rules" -Encoding utf8

# 2. Deploy emergency rules
firebase use prod
firebase deploy --only firestore:rules

# 3. IMMEDIATELY schedule proper rules restoration
# Set reminder for 1 hour maximum
```

**Use this for**: Complete system outage where proper rollback fails

---

## Troubleshooting

### Error: "Permission denied" in emulator tests

**Symptom**: Tests fail with `PERMISSION_DENIED` error

**Cause**: Rules too restrictive or helper function error

**Solution**:
```powershell
# 1. Check emulator logs in Terminal 1
# Look for rule evaluation details

# 2. Add debug logging to rules
# Before:
allow read: if isAuthenticated();

# After:
allow read: if debug(isAuthenticated());  # Shows true/false in logs

# 3. Re-run test and check emulator logs
```

### Error: "Function call depth exceeded"

**Symptom**: Tests hang or fail with depth error

**Cause**: Circular `get()` calls in rules

**Solution**:
```javascript
// ❌ BAD: Circular dependency
function getUserOrg() {
  return get(...).data.orgId;
}
function getOrgAdmin() {
  return get(...).data.adminUid;  // Calls getUserOrg()
}

// ✅ GOOD: Cache get() results
function ownsOrganization(orgId) {
  let org = get(/databases/$(database)/documents/organizations/$(orgId));
  return org.data.adminUid == request.auth.uid;
}
```

### Error: "Emulator not running"

**Symptom**: `npm test` fails with connection refused

**Solution**:
```powershell
# Verify emulator is running
# Check Terminal 1 for "All emulators ready!"

# If not running:
firebase emulators:start --only firestore

# If port conflict:
firebase emulators:start --only firestore --port 8081

# Update tests to use new port:
# In test files, change port: 8080 → port: 8081
```

### Error: "Rules syntax error" on deployment

**Symptom**: `firebase deploy` fails with parse error

**Solution**:
```powershell
# 1. Check rules syntax with dry run
firebase deploy --only firestore:rules --debug

# 2. Common syntax issues:
# - Missing semicolons after function definitions
# - Incorrect string interpolation: Use $(variable), not ${variable}
# - Missing quotes in string comparisons

# 3. Validate in VS Code:
# Install extension: "Firebase" by Firebase
# It highlights syntax errors in firestore.rules files
```

### Error: "Too many document reads" (performance)

**Symptom**: Rules work but are slow / exceed quota

**Solution**:
```javascript
// ❌ BAD: Multiple get() calls
allow read: if get(...).data.isActive &&
              get(...).data.adminUid == request.auth.uid;

// ✅ GOOD: Single get(), reuse result
allow read: if exists(/databases/$(database)/documents/users/$(request.auth.uid));

// ✅ BETTER: Cache in helper function
function ownsOrganization(orgId) {
  let org = get(/databases/$(database)/documents/organizations/$(orgId));
  return org.data.adminUid == request.auth.uid && org.data.isActive;
}
```

### Can't Access Firebase Project

**Symptom**: `firebase use` shows no projects

**Solution**:
```powershell
# 1. Verify authentication
firebase login --reauth

# 2. Check project permissions
# Ask project owner to add you as Editor in Firebase Console:
# Firebase Console → Project Settings → Users and permissions

# 3. Clear cached credentials (if issues persist)
firebase logout
Remove-Item -Path "$env:USERPROFILE\.config\firebase" -Recurse -Force
firebase login
```

---

## Quick Reference Commands

```powershell
# Authentication
firebase login
firebase logout

# Project management
firebase use                          # Show current project
firebase use dev                      # Switch to dev
firebase use prod                     # Switch to prod
firebase projects:list                # List all projects

# Testing
firebase emulators:start --only firestore   # Start emulator
cd test\firestore_rules; npm test           # Run tests

# Deployment
firebase deploy --only firestore:rules      # Deploy rules
firebase deploy --only firestore:rules --debug  # Debug mode

# Rollback
firebase projects:get ease-queue           # Check prod status
# Use Firebase Console → Rules → View history → Restore
```

---

## Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/rules-structure)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Rules Unit Testing API](https://firebase.google.com/docs/rules/unit-tests)
- [Queue Ease Project Timeline](../../docs/PROJECT_TIMELINE.md)
- [Feature Specification](../spec.md)
- [Security Rules Contract](./contracts/security-rules-contract.md)

---

**Document Version**: 1.0.0  
**Last Updated**: February 25, 2026  
**Maintained By**: Queue Ease Development Team
