import '../../../../shared_domain/entities/appointment_status.dart';
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
    final noShowDeadline = scheduledAt.add(
      Duration(minutes: effectiveTimeMarginMinutes),
    );

    return QueueAutomationEvaluation.fromTimeWindow(
      now: now,
      scheduledAt: scheduledAt,
      noShowDeadline: noShowDeadline,
      effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      status: status,
    );
  }
}
