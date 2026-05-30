import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/utils/time_utils.dart';

import '../../shared/issue_resolution_fixtures.dart';

void main() {
  group('TimeUtils', () {
    group('nowUtc', () {
      test('returns current time in UTC', () {
        final result = TimeUtils.nowUtc();
        expect(result.isUtc, isTrue);

        // Should be very close to current time
        final now = DateTime.now().toUtc();
        final diff = result.difference(now).inMilliseconds.abs();
        expect(diff, lessThan(1000)); // Within 1 second
      });
    });

    group('normalizeToUtc', () {
      test('converts local time to UTC', () {
        final localTime = DateTime(2026, 3, 23, 10, 30, 0); // Local time
        final result = TimeUtils.normalizeToUtc(localTime);

        expect(result.isUtc, isTrue);
        expect(result.year, equals(2026));
        expect(result.month, equals(3));
        expect(result.day, equals(23));
      });

      test('leaves UTC time unchanged', () {
        final utcTime = DateTime.utc(2026, 3, 23, 10, 30, 0);
        final result = TimeUtils.normalizeToUtc(utcTime);

        expect(result, equals(utcTime));
        expect(result.isUtc, isTrue);
      });
    });

    test('supports issue resolution UTC reference fixtures', () {
      final reference = issueResolutionReferenceDate;
      final result = TimeUtils.calculateDeadline(reference, 30);

      expect(reference.isUtc, isTrue);
      expect(result, equals(reference.add(const Duration(minutes: 30))));
    });

    group('calculateDeadline', () {
      test('calculates correct deadline with UTC normalization', () {
        final scheduledAt = DateTime(2026, 3, 23, 10, 0, 0); // Local time
        const marginMinutes = 15;

        final result = TimeUtils.calculateDeadline(scheduledAt, marginMinutes);

        expect(result.isUtc, isTrue);
        expect(
          result,
          equals(scheduledAt.toUtc().add(const Duration(minutes: 15))),
        );
      });

      test('handles zero margin correctly', () {
        final scheduledAt = DateTime.utc(2026, 3, 23, 10, 0, 0);
        const marginMinutes = 0;

        final result = TimeUtils.calculateDeadline(scheduledAt, marginMinutes);

        expect(result, equals(scheduledAt));
      });

      test('handles large margins correctly', () {
        final scheduledAt = DateTime.utc(2026, 3, 23, 10, 0, 0);
        const marginMinutes = 120; // 2 hours

        final result = TimeUtils.calculateDeadline(scheduledAt, marginMinutes);

        expect(result, equals(scheduledAt.add(const Duration(hours: 2))));
      });
    });

    group('calculateRemainingSeconds', () {
      test('returns correct seconds when deadline is in future', () {
        final now = TimeUtils.nowUtc();
        final deadline = now.add(
          const Duration(minutes: 5),
        ); // 5 minutes from now

        final result = TimeUtils.calculateRemainingSeconds(deadline);

        expect(result, isNotNull);
        expect(result, greaterThan(290)); // At least 4m 50s
        expect(result, lessThan(310)); // At most 5m 10s
      });

      test('returns null when deadline has passed', () {
        final now = TimeUtils.nowUtc();
        final deadline = now.subtract(
          const Duration(minutes: 5),
        ); // 5 minutes ago

        final result = TimeUtils.calculateRemainingSeconds(deadline);

        expect(result, isNull);
      });

      test('handles non-UTC deadline correctly', () {
        final localDeadline = DateTime.now().add(const Duration(minutes: 3));

        final result = TimeUtils.calculateRemainingSeconds(localDeadline);

        expect(result, isNotNull);
        expect(result, greaterThan(170)); // At least 2m 50s
        expect(result, lessThan(190)); // At most 3m 10s
      });
    });

    group('isOverdue', () {
      test('returns false when appointment is not yet due', () {
        final futureTime = TimeUtils.nowUtc().add(const Duration(hours: 1));
        const marginMinutes = 15;

        final result = TimeUtils.isOverdue(futureTime, marginMinutes);

        expect(result, isFalse);
      });

      test('returns false when within grace period', () {
        final pastTime = TimeUtils.nowUtc().subtract(
          const Duration(minutes: 10),
        );
        const marginMinutes = 15; // Still 5 minutes of grace left

        final result = TimeUtils.isOverdue(pastTime, marginMinutes);

        expect(result, isFalse);
      });

      test('returns true when past deadline', () {
        final pastTime = TimeUtils.nowUtc().subtract(
          const Duration(minutes: 20),
        );
        const marginMinutes = 15; // 5 minutes overdue

        final result = TimeUtils.isOverdue(pastTime, marginMinutes);

        expect(result, isTrue);
      });

      test('handles zero margin correctly', () {
        final pastTime = TimeUtils.nowUtc().subtract(
          const Duration(seconds: 1),
        );
        const marginMinutes = 0; // No grace period

        final result = TimeUtils.isOverdue(pastTime, marginMinutes);

        expect(result, isTrue);
      });
    });

    group('isNotDueYet', () {
      test('returns true when scheduled time is in future', () {
        final futureTime = TimeUtils.nowUtc().add(const Duration(minutes: 30));

        final result = TimeUtils.isNotDueYet(futureTime);

        expect(result, isTrue);
      });

      test('returns false when scheduled time has passed', () {
        final pastTime = TimeUtils.nowUtc().subtract(
          const Duration(minutes: 30),
        );

        final result = TimeUtils.isNotDueYet(pastTime);

        expect(result, isFalse);
      });

      test('handles edge case at exactly scheduled time', () {
        // This test might be flaky due to execution time, but tests the boundary
        final nowTime = TimeUtils.nowUtc();

        final result = TimeUtils.isNotDueYet(nowTime);

        // Should be false or very close to false
        expect(result, isFalse);
      });
    });

    group('toUtcIsoString', () {
      test('formats UTC time correctly', () {
        final dateTime = DateTime.utc(2026, 3, 23, 14, 30, 45);

        final result = TimeUtils.toUtcIsoString(dateTime);

        expect(result, equals('2026-03-23T14:30:45.000Z'));
      });

      test('normalizes local time to UTC before formatting', () {
        final localTime = DateTime(2026, 3, 23, 10, 30, 45);

        final result = TimeUtils.toUtcIsoString(localTime);

        expect(result, contains('2026-03-23T'));
        expect(result, endsWith('Z'));
      });
    });

    group('formatDuration', () {
      test('formats hours and minutes', () {
        const duration = Duration(hours: 2, minutes: 30, seconds: 45);

        final result = TimeUtils.formatDuration(duration);

        expect(result, equals('2h 30m'));
      });

      test('formats minutes and seconds', () {
        const duration = Duration(minutes: 5, seconds: 30);

        final result = TimeUtils.formatDuration(duration);

        expect(result, equals('5m 30s'));
      });

      test('formats seconds only', () {
        const duration = Duration(seconds: 45);

        final result = TimeUtils.formatDuration(duration);

        expect(result, equals('45s'));
      });

      test('handles zero duration', () {
        const duration = Duration.zero;

        final result = TimeUtils.formatDuration(duration);

        expect(result, equals('0s'));
      });

      test('handles negative duration as zero', () {
        const duration = Duration(seconds: -30);

        final result = TimeUtils.formatDuration(duration);

        expect(result, equals('0s'));
      });
    });

    group('formatCountdown', () {
      test('formats minutes and seconds correctly', () {
        const remainingSeconds = 330; // 5 minutes 30 seconds

        final result = TimeUtils.formatCountdown(remainingSeconds);

        expect(result, equals('05:30'));
      });

      test('formats zero-padded single digits', () {
        const remainingSeconds = 65; // 1 minute 5 seconds

        final result = TimeUtils.formatCountdown(remainingSeconds);

        expect(result, equals('01:05'));
      });

      test('handles large minutes correctly', () {
        const remainingSeconds = 3665; // 61 minutes 5 seconds

        final result = TimeUtils.formatCountdown(remainingSeconds);

        expect(result, equals('61:05'));
      });

      test('returns "Overdue" for null input', () {
        final result = TimeUtils.formatCountdown(null);

        expect(result, equals('Overdue'));
      });

      test('returns "Overdue" for zero or negative seconds', () {
        expect(TimeUtils.formatCountdown(0), equals('Overdue'));
        expect(TimeUtils.formatCountdown(-30), equals('Overdue'));
      });
    });

    group('isReasonableQueueTime', () {
      test('returns true for current time', () {
        final now = TimeUtils.nowUtc();

        final result = TimeUtils.isReasonableQueueTime(now);

        expect(result, isTrue);
      });

      test('returns true for time within allowed past range', () {
        final fiveDaysAgo = TimeUtils.nowUtc().subtract(
          const Duration(days: 5),
        );

        final result = TimeUtils.isReasonableQueueTime(fiveDaysAgo);

        expect(result, isTrue);
      });

      test('returns true for time within allowed future range', () {
        final fifteenDaysLater = TimeUtils.nowUtc().add(
          const Duration(days: 15),
        );

        final result = TimeUtils.isReasonableQueueTime(fifteenDaysLater);

        expect(result, isTrue);
      });

      test('returns false for time too far in past', () {
        final tenDaysAgo = TimeUtils.nowUtc().subtract(
          const Duration(days: 10),
        );

        final result = TimeUtils.isReasonableQueueTime(tenDaysAgo);

        expect(result, isFalse);
      });

      test('returns false for time too far in future', () {
        final fortyDaysLater = TimeUtils.nowUtc().add(const Duration(days: 40));

        final result = TimeUtils.isReasonableQueueTime(fortyDaysLater);

        expect(result, isFalse);
      });

      test('handles local time input correctly', () {
        final localTime = DateTime.now().add(const Duration(days: 2));

        final result = TimeUtils.isReasonableQueueTime(localTime);

        expect(result, isTrue);
      });
    });
  });
}
