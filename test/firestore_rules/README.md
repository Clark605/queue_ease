# Firestore Rules Test Suite

Test infrastructure for Firebase Security Rules using Firebase Emulator Suite.

## Prerequisites

- Node.js >= 18.0.0
- Firebase CLI installed globally (`npm install -g firebase-tools`)
- Firebase Emulator Suite configured

## Setup

Dependencies are already installed. If you need to reinstall:

```bash
npm install
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run tests in watch mode
```bash
npm run test:watch
```

### Run tests with coverage report
```bash
npm run test:coverage
```

### Run specific test file
```bash
npm test -- organizations.test.ts
```

## Test Structure

Tests are organized by collection and user story:

- `organizations.test.ts` - Organization collection rules (US1)
- `services.test.ts` - Services subcollection rules (US1)
- `working_hours.test.ts` - Working hours subcollection rules (US1)
- `appointments.test.ts` - Appointments subcollection rules (US2)
- `queues.test.ts` - Queues subcollection rules (US2)
- `users.test.ts` - Users collection rules (US3)

## Writing Tests

### Basic Test Structure

```typescript
import { describe, it, before, after, afterEach } from 'mocha';
import { expect } from 'chai';
import {
  setupTestEnvironment,
  teardownTestEnvironment,
  clearFirestoreData,
  getAuthenticatedContext,
  getUnauthenticatedContext,
  createTestUser,
  createTestOrganization,
  assertSucceeds,
  assertFails,
  TestData,
} from './setup';

describe('Collection Name Tests', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  it('should allow operation X', async () => {
    // Setup test data
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1');

    // Get authenticated context
    const adminContext = getAuthenticatedContext('admin1');
    
    // Perform operation
    const doc = adminContext.firestore()
      .collection('organizations')
      .doc('org1');
    
    // Assert success
    await assertSucceeds(doc.get());
  });

  it('should deny operation Y', async () => {
    // Setup test data
    const customerContext = getAuthenticatedContext('customer1');
    
    // Perform operation
    const doc = customerContext.firestore()
      .collection('organizations')
      .doc('org1');
    
    // Assert failure
    await assertFails(doc.delete());
  });
});
```

### Using Test Data Factories

```typescript
// Create test organization
const orgData = TestData.organization('admin1', { 
  name: 'Custom Name',
  isOpen: true 
});

// Create test service
const serviceData = TestData.service({ 
  durationMinutes: 60 
});

// Create test appointment
const appointmentData = TestData.appointment('customer1', 'service1', {
  status: 'booked'
});
```

### Helper Functions Available

- `setupTestEnvironment()` - Initialize Firebase Emulator
- `teardownTestEnvironment()` - Clean up after all tests
- `clearFirestoreData()` - Clear all data between tests
- `getAuthenticatedContext(uid, customClaims?)` - Get authenticated Firestore context
- `getUnauthenticatedContext()` - Get unauthenticated context
- `createTestUser(uid, role, organizationId?)` - Create user in Firestore (bypasses security)
- `createTestOrganization(orgId, adminUid, name?)` - Create organization (bypasses security)
- `assertSucceeds(promise)` - Assert operation succeeds
- `assertFails(promise)` - Assert operation fails with permission-denied

## TDD Workflow

1. **Write test first** (it should FAIL initially)
2. **Implement security rule** in `firestore.rules`
3. **Run test** - it should now PASS
4. **Refactor** if needed
5. **Repeat** for next test

## Firebase Emulator

Tests automatically start and configure the Firebase Emulator. Default configuration:

- Host: `localhost`
- Port: `8080`
- Project ID: `queue-ease-test`

## Coverage Requirements

Per Constitution Principle III, all tests must achieve **>80% coverage** of security rules.

Generate coverage report:
```bash
npm run test:coverage
```

## Debugging

Add detailed logging:
```typescript
console.log('Test data:', JSON.stringify(testData, null, 2));
```

Check Firebase Emulator UI:
```bash
firebase emulators:start --only firestore --inspect-functions
```

## Resources

- [Firebase Rules Testing Guide](https://firebase.google.com/docs/rules/unit-tests)
- [Firestore Security Rules Reference](https://firebase.google.com/docs/firestore/security/rules-structure)
- [Mocha Test Framework](https://mochajs.org/)
- [Chai Assertion Library](https://www.chaijs.com/)
