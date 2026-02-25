/**
 * Queues Subcollection Security Rules Tests
 * User Story 2: Customer Access Control
 * 
 * Tests verify that:
 * - Customers can read their own queue entries
 * - Organization owners can read all queues in their org
 * - Customers can create queue entries with matching customerId
 * - Customers cannot impersonate other customers
 * - Customers cannot update or delete queue entries
 * - Organization owners can update/delete queues in their org
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

describe('Queues Subcollection Tests (US2)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T044: customer can read own queue entry
  it('should allow customer to read own queue entry', async () => {
    // Setup: Create organization, admin, service, and customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Customer reads own queue entry
    const customerContext = getAuthenticatedContext('customer1');
    const queueDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertSucceeds(queueDoc.get());
  });

  // T045: organization owner can read queues in own org
  it('should allow organization owner to read queues in own org', async () => {
    // Setup: Create organization, admin, customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Admin reads queue entry in own org
    const adminContext = getAuthenticatedContext('admin1');
    const queueDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertSucceeds(queueDoc.get());
  });

  // T046: customer can create queue entry with matching customerId
  it('should allow customer to create queue entry with matching customerId', async () => {
    // Setup: Create organization and customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Test: Customer creates queue entry with own customerId
    const customerContext = getAuthenticatedContext('customer1');
    const queueData = TestData.queue('customer1', 'service1', {
      orgId: 'org1',
    });

    const queueDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertSucceeds(queueDoc.set(queueData));
  });

  // Additional test: customer cannot create queue entry with different customerId
  it('should deny customer from creating queue entry with different customerId', async () => {
    // Setup: Create organization and customers
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');
    await createTestUser('customer2', 'customer');

    // Test: Customer1 tries to create queue entry with customer2's ID
    const customer1Context = getAuthenticatedContext('customer1');
    const queueData = TestData.queue('customer2', 'service1', {
      orgId: 'org1',
    });

    const queueDoc = customer1Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertFails(queueDoc.set(queueData));
  });

  // T047: customer cannot update or delete queue entries
  it('should deny customer from updating queue entry', async () => {
    // Setup: Create organization, customer, and queue entry
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Customer tries to update own queue entry
    const customerContext = getAuthenticatedContext('customer1');
    const queueDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertFails(queueDoc.update({ status: 'closed' }));
  });

  it('should deny customer from deleting queue entry', async () => {
    // Setup: Create organization, customer, and queue entry
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Customer tries to delete own queue entry
    const customerContext = getAuthenticatedContext('customer1');
    const queueDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertFails(queueDoc.delete());
  });

  // T048: organization owner can update/delete queues in own org
  it('should allow organization owner to update queues in own org', async () => {
    // Setup: Create organization, admin, customer, and queue entry
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Admin updates queue entry in own org
    const adminContext = getAuthenticatedContext('admin1');
    const queueDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertSucceeds(queueDoc.update({ status: 'closed' }));
  });

  it('should allow organization owner to delete queues in own org', async () => {
    // Setup: Create organization, admin, customer, and queue entry
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create queue entry with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Admin deletes queue entry in own org
    const adminContext = getAuthenticatedContext('admin1');
    const queueDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertSucceeds(queueDoc.delete());
  });

  // Additional test: Other admin cannot read queues in different org
  it('should deny admin from reading queues in different org', async () => {
    // Setup: Create two orgs with different admins
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Org 1');
    await createTestUser('admin2', 'admin', 'org2');
    await createTestOrganization('org2', 'admin2', 'Org 2');
    await createTestUser('customer1', 'customer');

    // Create queue entry in org1 with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Admin2 tries to read queue entry in org1
    const admin2Context = getAuthenticatedContext('admin2');
    const queueDoc = admin2Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertFails(queueDoc.get());
  });

  // Additional test: Customer cannot read another customer's queue entry
  it('should deny customer from reading another customer\'s queue entry', async () => {
    // Setup: Create organization and two customers
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');
    await createTestUser('customer2', 'customer');

    // Create queue entry for customer1 with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const queueData = TestData.queue('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('queues')
        .doc('queue1')
        .set(queueData);
    });

    // Test: Customer2 tries to read customer1's queue entry
    const customer2Context = getAuthenticatedContext('customer2');
    const queueDoc = customer2Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('queues')
      .doc('queue1');

    await assertFails(queueDoc.get());
  });

  // T073: queue status must be valid enum value
  it('should deny creating queue entry with invalid status', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    const customerContext = getAuthenticatedContext('customer1');
    const badQueue = TestData.queue('customer1', 'service1', { orgId: 'org1', status: 'bad_status' });
    const queueDoc = customerContext.firestore().collection('organizations').doc('org1').collection('queues').doc('bad');

    await assertFails(queueDoc.set(badQueue));
  });

  // T086b: unexpected fields are rejected
  it('should deny queue entry creation with unexpected fields', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    const customerContext = getAuthenticatedContext('customer1');

    const invalidQueueData = {
      orgId: 'org1',
      customerId: 'customer1',
      serviceId: 'service1',
      queueNumber: 1,
      status: 'active',
      joinedAt: new Date(),
      createdAt: new Date(),
      unexpectedField: 'should be rejected', // Unexpected field
    };

    const queueDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('queues').doc('queue1');

    await assertFails(queueDoc.set(invalidQueueData));
  });
});
