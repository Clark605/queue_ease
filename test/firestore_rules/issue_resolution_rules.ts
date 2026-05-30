import { TestData } from './setup.ts';

export function buildAppointmentStatusFixture(overrides: Record<string, unknown> = {}) {
  return TestData.appointment('customer1', 'service1', {
    orgId: 'org1',
    ...overrides,
  });
}

export function buildBookingWindowFixture(
  daysAhead: number = 31,
  overrides: Record<string, unknown> = {},
) {
  return TestData.appointment('customer1', 'service1', {
    orgId: 'org1',
    scheduledAt: new Date(Date.now() + daysAhead * 24 * 60 * 60 * 1000),
    ...overrides,
  });
}

export function buildCancelledAppointmentFixture(
  overrides: Record<string, unknown> = {},
) {
  return TestData.appointment('customer1', 'service1', {
    orgId: 'org1',
    status: 'cancelled',
    ...overrides,
  });
}
