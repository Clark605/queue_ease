/**
 * Services Subcollection Security Rules Tests
 * User Story 1: Admin Data Protection
 * 
 * Tests verify that:
 * - Authenticated users can read services
 * - Only organization owners can create/update/delete services
 * - Other admins cannot modify services in different organizations
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

describe('Services Subcollection Tests (US1)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T021: authenticated user can read services
  it('should allow authenticated user to read services', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create service with security disabled
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 5,
        isActive: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('services').doc('service1')
        .set(serviceData);
    });

    // Test: Customer can read
    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');
    const serviceDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertSucceeds(serviceDoc.get());
  });

  // T022: organization owner can create service
  it('should allow organization owner to create service', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const serviceData = TestData.service({
      orgId: 'org1',
      name: 'Haircut',
      durationMinutes: 30,
      timeMarginMinutes: 5,
      isActive: true,
    });

    const serviceDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertSucceeds(serviceDoc.set(serviceData));
  });

  // T023: organization owner can update/delete own services
  it('should allow organization owner to update service', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create service
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 5,
        isActive: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('services').doc('service1')
        .set(serviceData);
    });

    const adminContext = getAuthenticatedContext('admin1');
    const serviceDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertSucceeds(serviceDoc.update({ name: 'Updated Haircut' }));
  });

  it('should allow organization owner to delete service', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Create service
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 5,
        isActive: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('services').doc('service1')
        .set(serviceData);
    });

    const adminContext = getAuthenticatedContext('admin1');
    const serviceDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertSucceeds(serviceDoc.delete());
  });

  // T024: other admin cannot modify services in different org
  it('should deny other admin from creating service in different org', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');

    const serviceData = TestData.service({
      orgId: 'org1',
      name: 'Hacker Service',
      durationMinutes: 30,
      timeMarginMinutes: 5,
      isActive: true,
    });

    const serviceDoc = admin2Context.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertFails(serviceDoc.set(serviceData));
  });

  it('should deny other admin from updating service in different org', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    // Create service for org1
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 5,
        isActive: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('services').doc('service1')
        .set(serviceData);
    });

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');
    const serviceDoc = admin2Context.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertFails(serviceDoc.update({ name: 'Hacked Name' }));
  });

  it('should deny other admin from deleting service in different org', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    // Create service for org1
    const testEnv = await setupTestEnvironment();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const serviceData = TestData.service({
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 5,
        isActive: true,
      });
      await context.firestore()
        .collection('organizations').doc('org1')
        .collection('services').doc('service1')
        .set(serviceData);
    });

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');
    const serviceDoc = admin2Context.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertFails(serviceDoc.delete());
  });

  // Additional test: Customer cannot create service
  it('should deny customer from creating service', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');

    const serviceData = TestData.service({
      orgId: 'org1',
      name: 'Hacker Service',
      durationMinutes: 30,
      timeMarginMinutes: 5,
      isActive: true,
    });

    const serviceDoc = customerContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('service1');

    await assertFails(serviceDoc.set(serviceData));
  });

  // T070: service durationMinutes must be integer type
  it('should deny creating service with non-integer durationMinutes', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const badService = TestData.service({ orgId: 'org1', durationMinutes: 30.5 });
    const serviceDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('serviceX');

    await assertFails(serviceDoc.set(badService));
  });

  // T071: service durationMinutes must be 5-480 range
  it('should deny creating service with durationMinutes out of range', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const tooShort = TestData.service({ orgId: 'org1', durationMinutes: 4 });
    const tooLong = TestData.service({ orgId: 'org1', durationMinutes: 481 });
    const docA = adminContext.firestore().collection('organizations').doc('org1').collection('services').doc('sA');
    const docB = adminContext.firestore().collection('organizations').doc('org1').collection('services').doc('sB');

    await assertFails(docA.set(tooShort));
    await assertFails(docB.set(tooLong));
  });

  // T086b: unexpected fields are rejected
  it('should deny service creation with unexpected fields', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const invalidServiceData = {
      orgId: 'org1',
      name: 'Test Service',
      durationMinutes: 30,
      isActive: true,
      createdAt: new Date(),
      unexpectedField: 'should be rejected', // Unexpected field
    };

    const svcDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('svc1');

    await assertFails(svcDoc.set(invalidServiceData));
  });

  // Issue 6 fix: timeMarginMinutes is required on service create
  it('should deny creating service without timeMarginMinutes', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    // Explicitly omit timeMarginMinutes
    const serviceDataNoMargin = {
      orgId: 'org1',
      name: 'No Margin Service',
      durationMinutes: 30,
      isActive: true,
      createdAt: new Date(),
      // timeMarginMinutes intentionally missing
    };

    const svcDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('svc_no_margin');

    await assertFails(svcDoc.set(serviceDataNoMargin));
  });

  it('should deny creating service without orgId', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const serviceDataNoOrgId = {
      name: 'No OrgId Service',
      durationMinutes: 30,
      timeMarginMinutes: 5,
      isActive: true,
      createdAt: new Date(),
    };

    const svcDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('svc_no_orgid');

    await assertFails(svcDoc.set(serviceDataNoOrgId));
  });

  it('should deny creating service with timeMarginMinutes out of range', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');

    const tooHighMargin = TestData.service({ orgId: 'org1', timeMarginMinutes: 61 });
    const negativeMargin = TestData.service({ orgId: 'org1', timeMarginMinutes: -1 });

    const docA = adminContext.firestore().collection('organizations').doc('org1').collection('services').doc('sA');
    const docB = adminContext.firestore().collection('organizations').doc('org1').collection('services').doc('sB');

    await assertFails(docA.set(tooHighMargin));
    await assertFails(docB.set(negativeMargin));
  });

  it('should allow creating service with timeMarginMinutes of 0', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const serviceData = TestData.service({ orgId: 'org1', timeMarginMinutes: 0 });

    const svcDoc = adminContext.firestore()
      .collection('organizations').doc('org1')
      .collection('services').doc('svc_zero_margin');

    await assertSucceeds(svcDoc.set(serviceData));
  });
});
