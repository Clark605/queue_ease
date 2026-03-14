import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';

/// Displays a concise estimated wait summary for the customer.
class WaitTimeChip extends StatelessWidget {
  const WaitTimeChip({super.key, required this.status});

  final CustomerQueueStatusView status;

  @override
  Widget build(BuildContext context) {
    if (status.isNoShow) {
      return const SizedBox.shrink();
    }

    final (icon, text) = _labelAndIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _labelAndIcon() {
    if (status.isCurrentTurn) {
      return (Icons.notifications_active_outlined, 'Your turn now');
    }

    final wait = status.estimatedWaitMinutes;
    if (wait == null) {
      return (Icons.schedule_outlined, 'Wait estimate unavailable');
    }

    if (wait <= 0) {
      return (Icons.schedule_outlined, 'Estimated wait: < 1 min');
    }

    return (Icons.schedule_outlined, 'Estimated wait: $wait min');
  }
}
