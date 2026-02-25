/**
 * Organizations Collection Security Rules Tests
 * User Story 1: Admin Data Protection
 * 
 * Tests verify that:
 * - Authenticated users can read organization data
 * - Only admins can create organizations
 * - Only organization owners can update/delete their organizations
 * - Other admins cannot modify organizations they don't own
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

describe('Organizations Collection Tests (US1)', () => {
  before(async () => {
    await setupTestEnvironment();
  });

  after(async () => {
    await teardownTestEnvironment();
  });

  afterEach(async () => {
    await clearFirestoreData();
  });

  // T015: authenticated user can read any organization
  it('should allow authenticated user to read any organization', async () => {
    // Setup: Create organization with rules disabled
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    // Test: Customer reads organization
    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');
    const orgDoc = customerContext.firestore().collection('organizations').doc('org1');

    await assertSucceeds(orgDoc.get());
  });

  // T016: admin can create organization with matching adminUid
  it('should allow admin to create organization with matching adminUid', async () => {
    await createTestUser('admin1', 'admin');
    const adminContext = getAuthenticatedContext('admin1');

    const orgData = TestData.organization('admin1', {
      name: 'My Business',
      bookingLinkSlug: 'my-business',
      isOpen: true,
    });

    const orgDoc = adminContext.firestore().collection('organizations').doc('org1');
    await assertSucceeds(orgDoc.set(orgData));
  });

  // T017: admin can update own organization
  it('should allow admin to update own organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Original Name');

    const adminContext = getAuthenticatedContext('admin1');
    const orgDoc = adminContext.firestore().collection('organizations').doc('org1');

    await assertSucceeds(orgDoc.update({ name: 'Updated Name' }));
  });

  // T018: admin cannot update another admin's organization
  it('should deny admin from updating another admin\'s organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');
    const org1Doc = admin2Context.firestore().collection('organizations').doc('org1');

    await assertFails(org1Doc.update({ name: 'Hacked Name' }));
  });

  // T019: customer cannot create or update organizations
  it('should deny customer from creating organization', async () => {
    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');

    const orgData = TestData.organization('customer1', {
      name: 'Hacker Business',
      bookingLinkSlug: 'hacker-biz',
      isOpen: true,
    });

    const orgDoc = customerContext.firestore().collection('organizations').doc('org1');
    await assertFails(orgDoc.set(orgData));
  });

  // T067: organization creation requires name field
  it('should deny creating organization without name field', async () => {
    await createTestUser('admin1', 'admin');
    const adminContext = getAuthenticatedContext('admin1');

    const invalidOrg = {
      adminUid: 'admin1',
      bookingLinkSlug: 'no-name',
      isOpen: true,
      createdAt: new Date(),
    };

    const orgDoc = adminContext.firestore().collection('organizations').doc('orgX');
    await assertFails(orgDoc.set(invalidOrg));
  });

  // T068: organization name must be string type
  it('should deny creating organization with non-string name', async () => {
    await createTestUser('admin1', 'admin');
    const adminContext = getAuthenticatedContext('admin1');

    const invalidOrg = {
      adminUid: 'admin1',
      name: 12345,
      bookingLinkSlug: 'bad-name',
      isOpen: true,
      createdAt: new Date(),
    };

    const orgDoc = adminContext.firestore().collection('organizations').doc('orgX');
    await assertFails(orgDoc.set(invalidOrg));
  });

  // T069: organization name max 100 characters
  it('should deny creating organization with name longer than 100 chars', async () => {
    await createTestUser('admin1', 'admin');
    const adminContext = getAuthenticatedContext('admin1');

    const longName = 'x'.repeat(101);
    const invalidOrg = {
      adminUid: 'admin1',
      name: longName,
      bookingLinkSlug: 'too-long',
      isOpen: true,
      createdAt: new Date(),
    };

    const orgDoc = adminContext.firestore().collection('organizations').doc('orgX');
    await assertFails(orgDoc.set(invalidOrg));
  });

  it('should deny customer from updating organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin Org');

    await createTestUser('customer1', 'customer');
    const customerContext = getAuthenticatedContext('customer1');
    const orgDoc = customerContext.firestore().collection('organizations').doc('org1');

    await assertFails(orgDoc.update({ name: 'Hacked Name' }));
  });

  // Additional test: Unauthenticated users cannot read
  it('should deny unauthenticated user from reading organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const unauthContext = getUnauthenticatedContext();
    const orgDoc = unauthContext.firestore().collection('organizations').doc('org1');

    await assertFails(orgDoc.get());
  });

  // Additional test: Admin can delete own organization
  it('should allow admin to delete own organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Test Org');

    const adminContext = getAuthenticatedContext('admin1');
    const orgDoc = adminContext.firestore().collection('organizations').doc('org1');

    await assertSucceeds(orgDoc.delete());
  });

  // Additional test: Admin cannot delete another's organization
  it('should deny admin from deleting another admin\'s organization', async () => {
    await createTestUser('admin1', 'admin', 'org1');
    await createTestOrganization('org1', 'admin1', 'Admin1 Org');

    await createTestUser('admin2', 'admin', 'org2');
    const admin2Context = getAuthenticatedContext('admin2');
    const org1Doc = admin2Context.firestore().collection('organizations').doc('org1');

    await assertFails(org1Doc.delete());
  });

  // T086b: unexpected fields are rejected
  it('should deny organization creation with unexpected fields', async () => {
    await createTestUser('admin1', 'admin');
    const adminContext = getAuthenticatedContext('admin1');

    const invalidOrgData = {
      adminUid: 'admin1',
      name: 'Test Org',
      bookingLinkSlug: 'test-org',
      isOpen: true,
      createdAt: new Date(),
      unexpectedField: 'should be rejected', // Unexpected field
    };

    const orgDoc = adminContext.firestore().collection('organizations').doc('org1');
    await assertFails(orgDoc.set(invalidOrgData));
  });
});
