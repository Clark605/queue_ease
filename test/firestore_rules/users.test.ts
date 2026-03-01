/**
 * Users Collection Security Rules Tests
 * User Story 3: User Profile Security
 * 
 * Tests verify that:
 * - Users can read their own profile
 * - Users cannot read other users' profiles
 * - Users can create their own profile on first-time sign-up
 * - Users can update their own profile
 * - Users cannot update other users' profiles
 * - Unauthenticated users cannot read any user document
 * - No user can delete any user document
 */

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
} from './setup.ts';

describe('Users Collection Tests (US3)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T056: user can read own document
  it('should allow user to read own document', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: User reads own document
    const user1Context = getAuthenticatedContext('user1');
    const userDoc = user1Context.firestore().collection('users').doc('user1');

    await assertSucceeds(userDoc.get());
  });

  // T057: user cannot read other user's document
  it('should deny user from reading other user\'s document', async () => {
    // Setup: Create two users
    await createTestUser('user1', 'customer');
    await createTestUser('user2', 'customer');

    // Test: User1 tries to read user2's document
    const user1Context = getAuthenticatedContext('user1');
    const user2Doc = user1Context.firestore().collection('users').doc('user2');

    await assertFails(user2Doc.get());
  });

  // T058: user can create own document on first-time sign-up
  it('should allow user to create own document on first-time sign-up', async () => {
    // Test: User creates own document
    const user1Context = getAuthenticatedContext('user1');
    const userData = TestData.user('user1', 'customer');

    const userDoc = user1Context.firestore().collection('users').doc('user1');
    await assertSucceeds(userDoc.set(userData));
  });

  // Additional test: user cannot create document for another user
  it('should deny user from creating document for another user', async () => {
    // Test: User1 tries to create document for user2
    const user1Context = getAuthenticatedContext('user1');
    const userData = TestData.user('user2', 'customer'); // user2's data but user1 is creating

    const user2Doc = user1Context.firestore().collection('users').doc('user2');
    await assertFails(user2Doc.set(userData));
  });

  // Additional test: user cannot create document with mismatched uid
  it('should deny user from creating document with mismatched uid', async () => {
    // Test: User1 tries to create own document but with wrong uid field
    const user1Context = getAuthenticatedContext('user1');
    const userData = TestData.user('user2', 'customer'); // uid field is 'user2'

    const user1Doc = user1Context.firestore().collection('users').doc('user1');
    await assertFails(user1Doc.set(userData));
  });

  // T059: user can update own document
  it('should allow user to update own document', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: User updates own document
    const user1Context = getAuthenticatedContext('user1');
    const userDoc = user1Context.firestore().collection('users').doc('user1');

    await assertSucceeds(userDoc.update({ displayName: 'Updated Name' }));
  });

  // T060: user cannot update other user's document
  it('should deny user from updating other user\'s document', async () => {
    // Setup: Create two users
    await createTestUser('user1', 'customer');
    await createTestUser('user2', 'customer');

    // Test: User1 tries to update user2's document
    const user1Context = getAuthenticatedContext('user1');
    const user2Doc = user1Context.firestore().collection('users').doc('user2');

    await assertFails(user2Doc.update({ displayName: 'Hacked Name' }));
  });

  // T061: unauthenticated user cannot read any user document
  it('should deny unauthenticated user from reading any user document', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: Unauthenticated user tries to read user document
    const unauthContext = getUnauthenticatedContext();
    const userDoc = unauthContext.firestore().collection('users').doc('user1');

    await assertFails(userDoc.get());
  });

  // T062: no user can delete any user document
  it('should deny user from deleting own document', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: User tries to delete own document
    const user1Context = getAuthenticatedContext('user1');
    const userDoc = user1Context.firestore().collection('users').doc('user1');

    await assertFails(userDoc.delete());
  });

  it('should deny user from deleting other user\'s document', async () => {
    // Setup: Create two users
    await createTestUser('user1', 'customer');
    await createTestUser('user2', 'customer');

    // Test: User1 tries to delete user2's document
    const user1Context = getAuthenticatedContext('user1');
    const user2Doc = user1Context.firestore().collection('users').doc('user2');

    await assertFails(user2Doc.delete());
  });

  // Additional test: admin cannot read other user's document
  it('should deny admin from reading other user\'s document (no special privileges)', async () => {
    // Setup: Create admin and customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestUser('customer1', 'customer');

    // Test: Admin tries to read customer's document
    const adminContext = getAuthenticatedContext('admin1');
    const customerDoc = adminContext.firestore().collection('users').doc('customer1');

    await assertFails(customerDoc.get());
  });

  // Additional test: verify immutable fields on update
  it('should deny user from modifying uid field on update', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: User tries to modify uid field
    const user1Context = getAuthenticatedContext('user1');
    const userDoc = user1Context.firestore().collection('users').doc('user1');

    await assertFails(userDoc.update({ uid: 'different-uid' }));
  });

  it('should deny user from modifying createdAt field on update', async () => {
    // Setup: Create user
    await createTestUser('user1', 'customer');

    // Test: User tries to modify createdAt field
    const user1Context = getAuthenticatedContext('user1');
    const userDoc = user1Context.firestore().collection('users').doc('user1');

    await assertFails(userDoc.update({ createdAt: new Date() }));
  });

  // T075: createdAt field is immutable across other collections (orgs/services)
  it('should deny admin from modifying createdAt on organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const orgDoc = adminContext.firestore().collection('organizations').doc('org1');

    await assertFails(orgDoc.update({ createdAt: new Date() }));
  });

  it('should deny admin from modifying createdAt on service', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create service
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({ orgId: 'org1' });
      await context.firestore().collection('organizations').doc('org1').collection('services').doc('s1').set(serviceData);
    });

    const adminContext = getAuthenticatedContext('admin1');
    const svcDoc = adminContext.firestore().collection('organizations').doc('org1').collection('services').doc('s1');

    await assertFails(svcDoc.update({ createdAt: new Date() }));
  });

  // T089: user cannot create profile with invalid role
  it('should deny user from creating profile with invalid role', async () => {
    const user1Context = getAuthenticatedContext('user1');

    const invalidUserData = {
      uid: 'user1',
      email: 'user1@test.com',
      displayName: 'User 1',
      role: 'superadmin', // Invalid role
      createdAt: new Date(),
    };

    const userDoc = user1Context.firestore().collection('users').doc('user1');
    await assertFails(userDoc.set(invalidUserData));
  });

  // T090: role field must be "admin" or "customer" only
  it('should allow user to create profile with valid admin role', async () => {
    const admin1Context = getAuthenticatedContext('admin1');

    const validAdminData = {
      uid: 'admin1',
      email: 'admin1@test.com',
      displayName: 'Admin 1',
      role: 'admin',
      createdAt: new Date(),
    };

    const userDoc = admin1Context.firestore().collection('users').doc('admin1');
    await assertSucceeds(userDoc.set(validAdminData));
  });

  it('should allow user to create profile with valid customer role', async () => {
    const customer1Context = getAuthenticatedContext('customer1');

    const validCustomerData = {
      uid: 'customer1',
      email: 'customer1@test.com',
      displayName: 'Customer 1',
      role: 'customer',
      createdAt: new Date(),
    };

    const userDoc = customer1Context.firestore().collection('users').doc('customer1');
    await assertSucceeds(userDoc.set(validCustomerData));
  });

  it('should deny user from creating profile with role that is not string', async () => {
    const user2Context = getAuthenticatedContext('user2');

    const invalidUserData = {
      uid: 'user2',
      email: 'user2@test.com',
      displayName: 'User 2',
      role: 123, // Invalid type
      createdAt: new Date(),
    };

    const userDoc = user2Context.firestore().collection('users').doc('user2');
    await assertFails(userDoc.set(invalidUserData));
  });

  // Issue 1 fix: role must be immutable after creation (privilege escalation prevention)
  it('should deny customer from changing own role to admin (privilege escalation)', async () => {
    await createTestUser('customer1', 'customer');

    const customerContext = getAuthenticatedContext('customer1');
    const userDoc = customerContext.firestore().collection('users').doc('customer1');

    await assertFails(userDoc.update({ role: 'admin' }));
  });

  it('should deny admin from changing own role to customer', async () => {
    await createTestUser('admin1', 'admin', 'org1');

    const adminContext = getAuthenticatedContext('admin1');
    const userDoc = adminContext.firestore().collection('users').doc('admin1');

    await assertFails(userDoc.update({ role: 'customer' }));
  });

  // Issue 5 fix: user create must have required fields and reject unexpected fields
  it('should deny user from creating profile without required email field', async () => {
    const user1Context = getAuthenticatedContext('user1');

    const missingEmailData = {
      uid: 'user1',
      role: 'customer',
      displayName: 'User 1',
      createdAt: new Date(),
      // email is missing
    };

    const userDoc = user1Context.firestore().collection('users').doc('user1');
    await assertFails(userDoc.set(missingEmailData));
  });

  it('should deny user from creating profile without required createdAt field', async () => {
    const user1Context = getAuthenticatedContext('user1');

    const missingCreatedAtData = {
      uid: 'user1',
      email: 'user1@test.com',
      role: 'customer',
      // createdAt is missing
    };

    const userDoc = user1Context.firestore().collection('users').doc('user1');
    await assertFails(userDoc.set(missingCreatedAtData));
  });

  it('should deny user from creating profile with unexpected fields', async () => {
    const user1Context = getAuthenticatedContext('user1');

    const unexpectedFieldData = {
      uid: 'user1',
      email: 'user1@test.com',
      role: 'customer',
      createdAt: new Date(),
      adminSecretField: 'should be rejected',  // Unexpected field
    };

    const userDoc = user1Context.firestore().collection('users').doc('user1');
    await assertFails(userDoc.set(unexpectedFieldData));
  });
});
