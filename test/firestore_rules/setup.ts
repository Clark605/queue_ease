/**
 * Firebase Emulator Test Setup Utilities
 * 
 * Provides helper functions for initializing Firebase Emulator Suite,
 * creating test environments, and managing test data lifecycle.
 */

import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import type { RulesTestEnvironment } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

// ES module equivalent of __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Firebase test environment singleton
 */
let testEnv: RulesTestEnvironment | null = null;

/**
 * Initialize Firebase Emulator test environment
 * 
 * @param projectId - Firebase project ID for testing (defaults to test-only project)
 * @returns Initialized test environment
 */
export async function setupTestEnvironment(projectId: string = 'queue-ease-test'): Promise<RulesTestEnvironment> {
  if (testEnv) {
    return testEnv;
  }

  // Load security rules from repository root
  const rulesPath = resolve(__dirname, '../../firestore.rules');
  const rules = readFileSync(rulesPath, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules,
      host: 'localhost',
      port: 9080,
    },
  });

  return testEnv;
}

/**
 * Clean up test environment after all tests
 */
export async function teardownTestEnvironment(): Promise<void> {
  if (testEnv) {
    await testEnv.cleanup();
    testEnv = null;
  }
}

/**
 * Clear all data from Firestore emulator between tests
 */
export async function clearFirestoreData(): Promise<void> {
  if (testEnv) {
    await testEnv.clearFirestore();
  }
}

/**
 * Get an authenticated Firestore context for a specific user
 * 
 * @param uid - User ID
 * @param customClaims - Optional custom claims (e.g., role)
 * @returns Firestore context for the authenticated user
 */
export function getAuthenticatedContext(uid: string, customClaims?: Record<string, any>) {
  if (!testEnv) {
    throw new Error('Test environment not initialized. Call setupTestEnvironment() first.');
  }
  return testEnv.authenticatedContext(uid, customClaims);
}

/**
 * Get an unauthenticated Firestore context
 * 
 * @returns Firestore context for unauthenticated access
 */
export function getUnauthenticatedContext() {
  if (!testEnv) {
    throw new Error('Test environment not initialized. Call setupTestEnvironment() first.');
  }
  return testEnv.unauthenticatedContext();
}

/**
 * Create a test user document in Firestore
 * 
 * @param uid - User ID
 * @param role - User role (admin or customer)
 * @param organizationId - Optional organization ID for admin users
 */
export async function createTestUser(
  uid: string,
  role: 'admin' | 'customer',
  organizationId?: string
): Promise<void> {
  if (!testEnv) {
    throw new Error('Test environment not initialized. Call setupTestEnvironment() first.');
  }

  const userData: any = {
    uid,
    email: `${uid}@test.com`,
    displayName: `Test User ${uid}`,
    role,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  if (role === 'admin' && organizationId) {
    userData.organizationId = organizationId;
  }

  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('users').doc(uid).set(userData);
  });
}

/**
 * Create a test organization in Firestore
 * 
 * @param orgId - Organization ID
 * @param adminUid - Admin user ID who owns the organization
 * @param name - Organization name
 */
export async function createTestOrganization(
  orgId: string,
  adminUid: string,
  name: string = 'Test Organization'
): Promise<void> {
  if (!testEnv) {
    throw new Error('Test environment not initialized. Call setupTestEnvironment() first.');
  }

  const orgData = {
    name,
    adminUid,
    description: 'Test organization for unit tests',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('organizations').doc(orgId).set(orgData);
  });
}

/**
 * Re-export assertion helpers from @firebase/rules-unit-testing
 */
export { assertSucceeds, assertFails };

/**
 * Test data factories
 */
export const TestData = {
  /**
   * Generate a valid organization document
   */
  organization: (adminUid: string, overrides?: Partial<any>) => ({
    name: 'Test Organization',
    adminUid,
    description: 'Test organization',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),

  /**
   * Generate a valid service document
   */
  service: (overrides?: Partial<any>) => ({
    name: 'Test Service',
    durationMinutes: 30,
    timeMarginMinutes: 5,
    description: 'Test service',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),

  /**
   * Generate a valid appointment document
   */
  appointment: (customerId: string, serviceId: string, overrides?: Partial<any>) => ({
    customerId,
    serviceId,
    scheduledAt: new Date(Date.now() + 86400000), // Tomorrow
    status: 'booked',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),

  /**
   * Generate a valid queue document
   */
  queue: (customerId: string, serviceId: string, overrides?: Partial<any>) => ({
    customerId,
    serviceId,
    queueNumber: 1,
    status: 'active',
    joinedAt: new Date(),
    estimatedWaitMinutes: 15,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),

  /**
   * Generate a valid working hours document
   */
  workingHours: (dayOfWeek: number, overrides?: Partial<any>) => ({
    dayOfWeek,
    openTime: '09:00',
    closeTime: '17:00',
    isOpen: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),

  /**
   * Generate a valid user document
   */
  user: (uid: string, role: 'admin' | 'customer', overrides?: Partial<any>) => ({
    uid,
    email: `${uid}@test.com`,
    displayName: `Test User ${uid}`,
    role,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  }),
};
