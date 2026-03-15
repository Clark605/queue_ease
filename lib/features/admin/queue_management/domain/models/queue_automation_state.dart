import '../../../../shared_domain/entities/appointment_status.dart';

/// Operational state for the current queue entry in admin queue management.
enum QueueAutomationState { notDueYet, awaitingArrival, overdue, serving }

/// Allowed admin actions for the current queue entry.
class QueueAllowedActions {
  const QueueAllowedActions({
    required this.canStartServing,
    required this.canComplete,
    required this.canSkip,
    required this.canMarkNoShow,
  });

  const QueueAllowedActions.none()
    : canStartServing = false,
      canComplete = false,
      canSkip = false,
      canMarkNoShow = false;

  final bool canStartServing;
  final bool canComplete;
  final bool canSkip;
  final bool canMarkNoShow;
}

/// Derived automation evaluation for the current queue entry.
class QueueAutomationEvaluation {
  const QueueAutomationEvaluation({
    required this.state,
    required this.scheduledAt,
    required this.noShowDeadline,
    required this.effectiveTimeMarginMinutes,
    required this.allowedActions,
    this.remainingSeconds,
  });

  final QueueAutomationState state;
  final DateTime scheduledAt;
  final DateTime noShowDeadline;
  final int effectiveTimeMarginMinutes;
  final QueueAllowedActions allowedActions;
  final int? remainingSeconds;

  bool get isAutoNoShowEligible =>
      state == QueueAutomationState.overdue &&
      !allowedActions.canComplete &&
      !allowedActions.canStartServing;

  static QueueAutomationEvaluation forServing({
    required DateTime scheduledAt,
    required DateTime noShowDeadline,
    required int effectiveTimeMarginMinutes,
  }) {
    return QueueAutomationEvaluation(
      state: QueueAutomationState.serving,
      scheduledAt: scheduledAt,
      noShowDeadline: noShowDeadline,
      effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      allowedActions: const QueueAllowedActions(
        canStartServing: false,
        canComplete: true,
        canSkip: true,
        canMarkNoShow: false,
      ),
    );
  }

  static QueueAutomationEvaluation fromTimeWindow({
    required DateTime now,
    required DateTime scheduledAt,
    required DateTime noShowDeadline,
    required int effectiveTimeMarginMinutes,
    required AppointmentStatus status,
  }) {
    if (status == AppointmentStatus.serving) {
      return QueueAutomationEvaluation.forServing(
        scheduledAt: scheduledAt,
        noShowDeadline: noShowDeadline,
        effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      );
    }

    if (now.isBefore(scheduledAt)) {
      return QueueAutomationEvaluation(
        state: QueueAutomationState.notDueYet,
        scheduledAt: scheduledAt,
        noShowDeadline: noShowDeadline,
        effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
        allowedActions: const QueueAllowedActions.none(),
      );
    }

    if (!now.isBefore(noShowDeadline)) {
      return QueueAutomationEvaluation(
        state: QueueAutomationState.overdue,
        scheduledAt: scheduledAt,
        noShowDeadline: noShowDeadline,
        effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
        allowedActions: const QueueAllowedActions(
          canStartServing: false,
          canComplete: false,
          canSkip: false,
          canMarkNoShow: true,
        ),
      );
    }

    return QueueAutomationEvaluation(
      state: QueueAutomationState.awaitingArrival,
      scheduledAt: scheduledAt,
      noShowDeadline: noShowDeadline,
      effectiveTimeMarginMinutes: effectiveTimeMarginMinutes,
      remainingSeconds: noShowDeadline.difference(now).inSeconds,
      allowedActions: const QueueAllowedActions(
        canStartServing: true,
        canComplete: false,
        canSkip: true,
        canMarkNoShow: true,
      ),
    );
  }
}
