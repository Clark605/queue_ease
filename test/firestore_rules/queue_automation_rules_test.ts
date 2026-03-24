/**
 * Queue Automation Security Rules Tests
 * Sprint 6/7: Business Logic & Automation
 *
 * Tests verify that:
 * - inQueue -> noShow transitions require server-side deadline validation
 * - Malicious clients cannot bypass auto no-show logic
 * - Service time margins are properly resolved with fallbacks
 * - Server timestamp is used for deadline calculations
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
  createTestService,
  assertSucceeds,
  assertFails,
  TestData,
} from './setup.ts';

describe('Queue Automation Security Rules Tests', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  describe('Status Transition Validation', () => {
    it('should allow inQueue->noShow only when appointment is overdue', async () => {
      // Setup: Create org, admin, service, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create service with 2-minute time margin
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const serviceData = TestData.service('org1', {
          timeMarginMinutes: 2,
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('services')
          .doc('service1')
          .set(serviceData);

        // Create appointment scheduled 5 minutes ago (overdue by 3 minutes)
        const overdueTime = new Date(Date.now() - 5 * 60 * 1000);
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          scheduledAt: overdueTime,
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin can mark overdue appointment as no-show
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      await assertSucceeds(apptDoc.update({ status: 'noShow' }));
    });

    it('should reject inQueue->noShow when appointment is not yet overdue', async () => {
      // Setup: Create org, admin, service, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create service with 5-minute time margin
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const serviceData = TestData.service('org1', {
          timeMarginMinutes: 5,
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('services')
          .doc('service1')
          .set(serviceData);

        // Create appointment scheduled 2 minutes ago (still 3 minutes until overdue)
        const recentTime = new Date(Date.now() - 2 * 60 * 1000);
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          scheduledAt: recentTime,
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin cannot mark non-overdue appointment as no-show
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      await assertFails(apptDoc.update({ status: 'noShow' }));
    });

    it('should use 2-minute fallback for missing service time margin', async () => {
      // Setup: Create org, admin, service without time margin, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create service without timeMarginMinutes field
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const serviceData = {
          orgId: 'org1',
          name: 'Test Service',
          durationMinutes: 30,
          isActive: true,
          createdAt: new Date(),
        };
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('services')
          .doc('service1')
          .set(serviceData);

        // Create appointment scheduled 3 minutes ago (overdue by 1 minute with 2-min fallback)
        const overdueTime = new Date(Date.now() - 3 * 60 * 1000);
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          scheduledAt: overdueTime,
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin can mark overdue appointment as no-show (using 2-min fallback)
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      await assertSucceeds(apptDoc.update({ status: 'noShow' }));
    });

    it('should use 2-minute fallback for invalid service time margin', async () => {
      // Setup: Create org, admin, service with invalid time margin, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create service with invalid timeMarginMinutes (-1)
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const serviceData = {
          orgId: 'org1',
          name: 'Test Service',
          durationMinutes: 30,
          timeMarginMinutes: -1, // Invalid - should use 2-min fallback
          isActive: true,
          createdAt: new Date(),
        };
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('services')
          .doc('service1')
          .set(serviceData);

        // Create appointment scheduled just 1 minute ago (not overdue with 2-min fallback)
        const recentTime = new Date(Date.now() - 1 * 60 * 1000);
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          scheduledAt: recentTime,
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin cannot mark non-overdue appointment as no-show (2-min fallback applies)
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      await assertFails(apptDoc.update({ status: 'noShow' }));
    });

    it('should allow zero-minute time margin for immediate no-show', async () => {
      // Setup: Create org, admin, service with 0-minute margin, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create service with 0-minute time margin
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const serviceData = TestData.service('org1', {
          timeMarginMinutes: 0,
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('services')
          .doc('service1')
          .set(serviceData);

        // Create appointment scheduled exactly now (immediately overdue with 0 margin)
        const nowTime = new Date();
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          scheduledAt: nowTime,
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin can mark immediately overdue appointment as no-show
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      await assertSucceeds(apptDoc.update({ status: 'noShow' }));
    });

    it('should allow other status transitions without deadline validation', async () => {
      // Setup: Create org, admin, customer
      await createTestUser('admin1', 'admin', 'org1');
      await createTestOrganization('org1', 'admin1', 'Test Org');
      await createTestUser('customer1', 'customer');

      // Create appointment in inQueue status
      const testEnv = await setupTestEnvironment();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const appointmentData = TestData.appointment('customer1', 'service1', {
          orgId: 'org1',
          status: 'inQueue',
        });
        await context
          .firestore()
          .collection('organizations')
          .doc('org1')
          .collection('appointments')
          .doc('appt1')
          .set(appointmentData);
      });

      // Test: Admin can perform other transitions without deadline check
      const adminContext = getAuthenticatedContext('admin1');
      const apptDoc = adminContext
        .firestore()
        .collection('organizations')
        .doc('org1')
        .collection('appointments')
        .doc('appt1');

      // inQueue -> serving should work regardless of time
      await assertSucceeds(apptDoc.update({ status: 'serving' }));

      // serving -> completed should work
      await assertSucceeds(apptDoc.update({ status: 'completed' }));
    });
  });
});