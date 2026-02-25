/**
 * Appointments Subcollection Security Rules Tests
 * User Story 2: Customer Access Control
 * 
 * Tests verify that:
 * - Customers can read their own appointments
 * - Organization owners can read all appointments in their org
 * - Customers can create appointments with matching customerId
 * - Customers cannot impersonate other customers
 * - Customers cannot update or delete appointments
 * - Organization owners can update/delete appointments in their org
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

describe('Appointments Subcollection Tests (US2)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T037: customer can read own appointment
  it('should allow customer to read own appointment', async () => {
    // Setup: Create organization, admin, service, and customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Customer reads own appointment
    const customerContext = getAuthenticatedContext('customer1');
    const apptDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertSucceeds(apptDoc.get());
  });

  // T038: organization owner can read appointments in own org
  it('should allow organization owner to read appointments in own org', async () => {
    // Setup: Create organization, admin, customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Admin reads appointment in own org
    const adminContext = getAuthenticatedContext('admin1');
    const apptDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertSucceeds(apptDoc.get());
  });

  // T039: customer can create appointment with matching customerId
  it('should allow customer to create appointment with matching customerId', async () => {
    // Setup: Create organization and customer
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Test: Customer creates appointment with own customerId
    const customerContext = getAuthenticatedContext('customer1');
    const appointmentData = TestData.appointment('customer1', 'service1', {
      orgId: 'org1',
    });

    const apptDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertSucceeds(apptDoc.set(appointmentData));
  });

  // T040: customer cannot create appointment with different customerId
  it('should deny customer from creating appointment with different customerId', async () => {
    // Setup: Create organization and customers
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');
    await createTestUser('customer2', 'customer');

    // Test: Customer1 tries to create appointment with customer2's ID
    const customer1Context = getAuthenticatedContext('customer1');
    const appointmentData = TestData.appointment('customer2', 'service1', {
      orgId: 'org1',
    });

    const apptDoc = customer1Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertFails(apptDoc.set(appointmentData));
  });

  // T041: customer cannot update or delete any appointment
  it('should deny customer from updating appointment', async () => {
    // Setup: Create organization, customer, and appointment
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Customer tries to update own appointment
    const customerContext = getAuthenticatedContext('customer1');
    const apptDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertFails(apptDoc.update({ status: 'completed' }));
  });

  it('should deny customer from deleting appointment', async () => {
    // Setup: Create organization, customer, and appointment
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Customer tries to delete own appointment
    const customerContext = getAuthenticatedContext('customer1');
    const apptDoc = customerContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertFails(apptDoc.delete());
  });

  // T042: organization owner can update/delete appointments in own org
  it('should allow organization owner to update appointments in own org', async () => {
    // Setup: Create organization, admin, customer, and appointment
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Admin updates appointment in own org
    const adminContext = getAuthenticatedContext('admin1');
    const apptDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertSucceeds(apptDoc.update({ status: 'completed' }));
  });

  it('should allow organization owner to delete appointments in own org', async () => {
    // Setup: Create organization, admin, customer, and appointment
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    // Create appointment with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Admin deletes appointment in own org
    const adminContext = getAuthenticatedContext('admin1');
    const apptDoc = adminContext
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertSucceeds(apptDoc.delete());
  });

  // Additional test: Other admin cannot read appointments in different org
  it('should deny admin from reading appointments in different org', async () => {
    // Setup: Create two orgs with different admins
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Org 1');
    await createTestUser('admin2', 'admin', 'org2');
    await createTestOrganization('org2', 'admin2', 'Org 2');
    await createTestUser('customer1', 'customer');

    // Create appointment in org1 with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Admin2 tries to read appointment in org1
    const admin2Context = getAuthenticatedContext('admin2');
    const apptDoc = admin2Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertFails(apptDoc.get());
  });

  // Additional test: Customer cannot read another customer's appointment
  it('should deny customer from reading another customer\'s appointment', async () => {
    // Setup: Create organization and two customers
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');
    await createTestUser('customer2', 'customer');

    // Create appointment for customer1 with rules disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const appointmentData = TestData.appointment('customer1', 'service1', {
        orgId: 'org1',
      });
      await context
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1')
        .set(appointmentData);
    });

    // Test: Customer2 tries to read customer1's appointment
    const customer2Context = getAuthenticatedContext('customer2');
    const apptDoc = customer2Context
      .firestore()
      .collection('organizations')
      .doc('org1')
      .collection('appointments')
      .doc('appt1');

    await assertFails(apptDoc.get());
  });

  // T072: appointment status must be valid enum value
  it('should deny creating appointment with invalid status', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    const customerContext = getAuthenticatedContext('customer1');
    const badAppointment = TestData.appointment('customer1', 'service1', { orgId: 'org1', status: 'invalid_status' });
    const apptDoc = customerContext.firestore().collection('organizations').doc('org1').collection('appointments').doc('bad');

    await assertFails(apptDoc.set(badAppointment));
  });

  // T086b: unexpected fields are rejected
  it('should deny appointment creation with unexpected fields', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');
    await createTestUser('customer1', 'customer');

    const customerContext = getAuthenticatedContext('customer1');

    const invalidAppointmentData = {
      orgId: 'org1',
      customerId: 'customer1',
      serviceId: 'service1',
      scheduledAt: new Date(Date.now() + 86400000),
      status: 'booked',
      createdAt: new Date(),
      unexpectedField: 'should be rejected', // Unexpected field
    };

    const apptDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('appointments').doc('appt1');

    await assertFails(apptDoc.set(invalidAppointmentData));
  });
});
