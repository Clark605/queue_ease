import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/models/queue_automation_state.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import 'queue_action_button.dart';

/// Header section of [CurrentQueueCard] showing position badge,
/// customer name, duration, and the "Serving" chip.
class CurrentEntryHeader extends StatelessWidget {
  const CurrentEntryHeader({super.key, required this.entry});

  final QueueEntryView entry;
  static final _timeFormat = DateFormat('h:mm a');

  /// Formats [totalSeconds] as `m:ss` (e.g. 125 → "2:05").
  static String _formatCountdown(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _statusLabel => switch (entry.automationState) {
    QueueAutomationState.notDueYet => 'Not due yet',
    QueueAutomationState.awaitingArrival =>
      '${_formatCountdown(entry.remainingSeconds ?? 0)} remaining',
    QueueAutomationState.overdue => 'Overdue',
    QueueAutomationState.serving => 'Serving',
  };

  Color get _statusBackgroundColor => switch (entry.automationState) {
    QueueAutomationState.notDueYet => AppColors.warning.withValues(alpha: 0.12),
    QueueAutomationState.awaitingArrival => AppColors.primary.withValues(
      alpha: 0.12,
    ),
    QueueAutomationState.overdue => AppColors.error.withValues(alpha: 0.12),
    QueueAutomationState.serving => AppColors.success,
  };

  Color get _statusForegroundColor => switch (entry.automationState) {
    QueueAutomationState.notDueYet => AppColors.warning,
    QueueAutomationState.awaitingArrival => AppColors.primary,
    QueueAutomationState.overdue => AppColors.error,
    QueueAutomationState.serving => Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Now serving position ${entry.position}',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'NOW',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${entry.position}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.customerName,
                style: AppTextStyles.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${entry.serviceDurationMinutes} min',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Scheduled ${_timeFormat.format(entry.scheduledAt)} • Deadline ${_timeFormat.format(entry.noShowDeadline)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (entry.automationState == QueueAutomationState.serving)
          const ServingChip()
        else
          _buildAutomationChip(),
      ],
    );
  }

  Widget _buildAutomationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusBackgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusForegroundColor,
        ),
      ),
    );
  }
}
