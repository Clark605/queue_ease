/**
 * Working Hours Subcollection Security Rules Tests
 * User Story 1: Admin Data Protection
 * 
 * Tests verify that:
 * - Authenticated users can read working hours
 * - Only organization owners can create/update working hours
 * - Document ID must be valid dayOfWeek (0-6)
 */

import { describe, it, before, after, afterEach } from 'mocha';
import { expect } from 'chai';
import {
  setupTestEnvironment,
  teardownTestEnvironment,
  clearFirestoreData,
  getAuthenticatedContext,
  createTestUser,
  createTestOrganization,
  assertSucceeds,
  assertFails,
  TestData,
} from './setup.ts';

describe('Working Hours Subcollection Tests (US1)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T026: authenticated user can read working hours
  it('should allow authenticated user to read working hours', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create working hours with security disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const hoursData = TestData.workingHours(1, {
        orgId: 'org1',
        isOpen: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('working_hours').doc('1')
        .set(hoursData);
    });

    // Test: Customer can read
    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');
    const hoursDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('1');

    await assertSucceeds(hoursDoc.get());
  });

  // T027: organization owner can create/update working hours
  it('should allow organization owner to create working hours', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const hoursData = TestData.workingHours(1, {
      orgId: 'org1',
      isOpen: true,
    });

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('1');

    await assertSucceeds(hoursDoc.set(hoursData));
  });

  it('should allow organization owner to update working hours', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create working hours
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const hoursData = TestData.workingHours(1, {
        orgId: 'org1',
        isOpen: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('working_hours').doc('1')
        .set(hoursData);
    });

    const adminContext = getAuthenticatedContext('admin1');
    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('1');

    await assertSucceeds(hoursDoc.update({ openTime: '08:00' }));
  });

  // T028: dayOfWeek document ID must be 0-6
  it('should allow dayOfWeek document ID 0 (Monday)', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const hoursData = TestData.workingHours(0, {
      orgId: 'org1',
      isOpen: true,
    });

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('0');

    await assertSucceeds(hoursDoc.set(hoursData));
  });

  it('should allow dayOfWeek document ID 6 (Sunday)', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const hoursData = TestData.workingHours(6, {
      orgId: 'org1',
      openTime: '10:00',
      closeTime: '16:00',
      isOpen: true,
    });

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('6');

    await assertSucceeds(hoursDoc.set(hoursData));
  });

  it('should deny dayOfWeek document ID outside 0-6 range', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    // Test invalid day (7)
    const hoursData = TestData.workingHours(7, {
      orgId: 'org1',
      isOpen: true,
    });

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('7');

    await assertFails(hoursDoc.set(hoursData));
  });

  // Additional test: Other admin cannot modify working hours
  it('should deny other admin from modifying working hours in different org', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');

    const hoursData = TestData.workingHours(1, {
      orgId: 'org1',
      isOpen: true,
    });

    const hoursDoc = admin2Context.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('1');

    await assertFails(hoursDoc.set(hoursData));
  });

  // Additional test: Customer cannot create working hours
  it('should deny customer from creating working hours', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');

    const hoursData = TestData.workingHours(1, {
      orgId: 'org1',
      isOpen: true,
    });

    const hoursDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('1');

    await assertFails(hoursDoc.set(hoursData));
  });

  // T074: working hours time format must match HH:mm regex
  it('should deny working hours with invalid time format', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    // Test invalid time format (not HH:mm)
    const invalidHoursData = {
      orgId: 'org1',
      dayOfWeek: 2,
      isOpen: true,
      openTime: '9am', // Invalid format
      closeTime: '17:00',
      createdAt: new Date(),
    };

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('2');

    await assertFails(hoursDoc.set(invalidHoursData));
  });

  it('should allow working hours with valid HH:mm time format', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    // Test valid time formats
    const validHoursData = {
      orgId: 'org1',
      dayOfWeek: 3,
      isOpen: true,
      openTime: '09:30',
      closeTime: '17:45',
      createdAt: new Date(),
    };

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('3');

    await assertSucceeds(hoursDoc.set(validHoursData));
  });

  // T086b: unexpected fields are rejected
  it('should deny working hours with unexpected fields', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const invalidHoursData = {
      orgId: 'org1',
      dayOfWeek: 4,
      isOpen: true,
      openTime: '09:00',
      closeTime: '17:00',
      createdAt: new Date(),
      unexpectedField: 'should be rejected', // Unexpected field
    };

    const hoursDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('working_hours').doc('4');

    await assertFails(hoursDoc.set(invalidHoursData));
  });
});
