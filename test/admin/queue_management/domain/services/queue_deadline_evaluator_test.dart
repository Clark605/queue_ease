import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/utils/time_utils.dart';
import 'package:queue_ease/features/admin/queue_management/domain/services/queue_deadline_evaluator.dart';
import 'package:queue_ease/features/admin/queue_management/domain/models/queue_automation_state.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

void main() {
  group('QueueDeadlineEvaluator', () {
    late QueueDeadlineEvaluator evaluator;

    setUp(() {
      evaluator = const QueueDeadlineEvaluator();
    });

    group('evaluate', () {
      final now = DateTime.utc(2026, 3, 23, 10, 0, 0); // Fixed UTC time for testing
      final scheduledAt = DateTime.utc(2026, 3, 23, 9, 30, 0); // 30 minutes ago UTC
      final effectiveMargin = 15; // 15-minute margin

      test('returns notDueYet when current time is before scheduled time', () {
        final futureScheduled = DateTime.utc(2026, 3, 23, 10, 30, 0); // 30 minutes in future

        final result = evaluator.evaluate(
          now: now,
          scheduledAt: futureScheduled,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.inQueue,
        );

        expect(result.state, equals(QueueAutomationState.notDueYet));
        expect(result.scheduledAt, equals(futureScheduled.toUtc()));
        expect(result.effectiveTimeMarginMinutes, equals(effectiveMargin));
        expect(result.allowedActions.canStartServing, isFalse);
        expect(result.allowedActions.canComplete, isFalse);
        expect(result.allowedActions.canSkip, isFalse);
        expect(result.allowedActions.canMarkNoShow, isFalse);
        expect(result.remainingSeconds, isNull);
      });

      test('returns serving when status is serving', () {
        final result = evaluator.evaluate(
          now: now,
          scheduledAt: scheduledAt,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.serving,
        );

        expect(result.state, equals(QueueAutomationState.serving));
        expect(result.allowedActions.canStartServing, isFalse);
        expect(result.allowedActions.canComplete, isTrue);
        expect(result.allowedActions.canSkip, isTrue);
        expect(result.allowedActions.canMarkNoShow, isFalse);
      });

      test('returns overdue when past no-show deadline', () {
        final pastScheduled = DateTime.utc(2026, 3, 23, 9, 0, 0); // 60 minutes ago
        // With 15-minute margin, deadline was 45 minutes ago

        final result = evaluator.evaluate(
          now: now,
          scheduledAt: pastScheduled,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.inQueue,
        );

        expect(result.state, equals(QueueAutomationState.overdue));
        expect(result.allowedActions.canStartServing, isFalse);
        expect(result.allowedActions.canComplete, isFalse);
        expect(result.allowedActions.canSkip, isFalse);
        expect(result.allowedActions.canMarkNoShow, isTrue);
        expect(result.isAutoNoShowEligible, isTrue);
      });

      test('returns awaitingArrival when between scheduled time and deadline', () {
        final scheduledAt = DateTime.utc(2026, 3, 23, 9, 50, 0); // 10 minutes ago
        // With 15-minute margin, 5 minutes remaining until deadline

        final result = evaluator.evaluate(
          now: now,
          scheduledAt: scheduledAt,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.inQueue,
        );

        expect(result.state, equals(QueueAutomationState.awaitingArrival));
        expect(result.allowedActions.canStartServing, isTrue);
        expect(result.allowedActions.canComplete, isFalse);
        expect(result.allowedActions.canSkip, isTrue);
        expect(result.allowedActions.canMarkNoShow, isTrue);
        expect(result.remainingSeconds, equals(5 * 60)); // 5 minutes = 300 seconds
      });

      test('calculates correct no-show deadline', () {
        final result = evaluator.evaluate(
          now: now,
          scheduledAt: scheduledAt,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.inQueue,
        );

        final expectedDeadline = scheduledAt.add(Duration(minutes: effectiveMargin));
        expect(result.noShowDeadline, equals(expectedDeadline));
      });

      test('handles zero-minute margin correctly', () {
        final result = evaluator.evaluate(
          now: now,
          scheduledAt: scheduledAt, // 30 minutes ago
          effectiveTimeMarginMinutes: 0, // No grace period
          status: AppointmentStatus.inQueue,
        );

        expect(result.state, equals(QueueAutomationState.overdue));
        expect(result.effectiveTimeMarginMinutes, equals(0));
        expect(result.noShowDeadline, equals(scheduledAt)); // Deadline = scheduled time
      });

      test('handles edge case: exactly at deadline', () {
        final exactScheduled = DateTime.utc(2026, 3, 23, 9, 45, 0); // 15 minutes ago
        // With 15-minute margin, deadline is exactly now

        final result = evaluator.evaluate(
          now: now,
          scheduledAt: exactScheduled,
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.inQueue,
        );

        expect(result.state, equals(QueueAutomationState.overdue));
        expect(result.isAutoNoShowEligible, isTrue);
      });

      test('isAutoNoShowEligible returns false when serving', () {
        final result = evaluator.evaluate(
          now: now,
          scheduledAt: DateTime.utc(2026, 3, 23, 9, 0, 0), // Past deadline
          effectiveTimeMarginMinutes: effectiveMargin,
          status: AppointmentStatus.serving,
        );

        expect(result.state, equals(QueueAutomationState.serving));
        expect(result.isAutoNoShowEligible, isFalse);
      });
    });

    group('evaluateNow', () {
      test('uses current UTC time for evaluation', () {
        final scheduledAt = TimeUtils.nowUtc().add(const Duration(minutes: 30));
        const effectiveTimeMarginMinutes = 15;

        final result = evaluator.evaluateNow(
          scheduledAt: scheduledAt,
          effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
          status: AppointmentStatus.booked,
        );

        expect(result.state, QueueAutomationState.notDueYet);
        expect(result.noShowDeadline.isAfter(TimeUtils.nowUtc()), isTrue);
      });
    });
  });
}