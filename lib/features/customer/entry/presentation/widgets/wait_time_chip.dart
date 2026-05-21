import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';

/// Displays a concise estimated wait summary for the customer.
class WaitTimeChip extends StatelessWidget {
  const WaitTimeChip({super.key, required this.status});

  static const _shortWaitThresholdMinutes = 10;
  static const _mediumWaitThresholdMinutes = 30;

  final CustomerQueueStatusView status;

  @override
  Widget build(BuildContext context) {
    if (status.isNoShow || status.isCompleted) {
      return const SizedBox.shrink();
    }

    final (icon, text, foregroundColor, backgroundColor) = _chipStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withValues(alpha: 0.18),
            backgroundColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color, Color) _chipStyle() {
    if (status.isCurrentTurn) {
      return (
        Icons.notifications_active_outlined,
        'Your turn now',
        AppColors.waitShort,
        AppColors.waitShort,
      );
    }

    final wait = status.estimatedWaitMinutes;
    if (wait == null) {
      return (
        Icons.schedule_outlined,
        'Wait estimate unavailable',
        AppColors.onSurfaceVariant,
        AppColors.onSurfaceVariant,
      );
    }

    if (wait <= 0) {
      return (
        Icons.schedule_outlined,
        'Estimated wait: < 1 min',
        AppColors.waitShort,
        AppColors.waitShort,
      );
    }

    if (wait <= _shortWaitThresholdMinutes) {
      return (
        Icons.schedule_outlined,
        'Estimated wait: $wait min',
        AppColors.waitShort,
        AppColors.waitShort,
      );
    }

    if (wait <= _mediumWaitThresholdMinutes) {
      return (
        Icons.schedule_outlined,
        'Estimated wait: $wait min',
        AppColors.waitMedium,
        AppColors.waitMedium,
      );
    }

    return (
      Icons.schedule_outlined,
      'Estimated wait: $wait min',
      AppColors.waitLong,
      AppColors.waitLong,
    );
  }
}
