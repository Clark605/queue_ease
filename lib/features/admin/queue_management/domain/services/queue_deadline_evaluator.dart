import 'package:queue_ease/core/utils/time_utils.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import '../models/queue_automation_state.dart';

/// Evaluates queue automation state and action availability for one entry.
class QueueDeadlineEvaluator {
  const QueueDeadlineEvaluator();

  QueueAutomationEvaluation evaluate({
    required DateTime now,
    required DateTime scheduledAt,
    required int effectiveTimeMarginMinutes,
    required AppointmentStatus status,
  }) {
    // Use TimeUtils for consistent UTC-normalized deadline calculation
    final noShowDeadline = TimeUtils.calculateDeadline(
      scheduledAt,
      effectiveTimeMarginMinutes,
    );

    // Normalize input times to UTC for consistent comparison
    final normalizedNow = TimeUtils.normalizeToUtc(now);
    final normalizedScheduled = TimeUtils.normalizeToUtc(scheduledAt);

    return QueueAutomationEvaluation.fromTimeWindow(
      now: normalizedNow,
      scheduledAt: normalizedScheduled,
      noShowDeadline: noShowDeadline,
      effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      status: status,
    );
  }

  /// Convenience method that evaluates using current UTC time.
  ///
  /// Preferred over the manual now parameter for live queue evaluation.
  QueueAutomationEvaluation evaluateNow({
    required DateTime scheduledAt,
    required int effectiveTimeMarginMinutes,
    required AppointmentStatus status,
  }) {
    return evaluate(
      now: TimeUtils.nowUtc(),
      scheduledAt: scheduledAt,
      effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      status: status,
    );
  }
}
