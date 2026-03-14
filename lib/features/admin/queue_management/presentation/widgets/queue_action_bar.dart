import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A compact horizontal status bar summarising the current queue state.
///
/// Displays a "Queue is empty for today" message when [queueEmpty] is true,
/// or a waiting-count summary with a people icon when customers are present.
///
/// The main queue actions (Next / Skip / No-Show) live in [CurrentQueueCard];
/// this widget provides a lightweight at-a-glance summary row.
class QueueActionBar extends StatelessWidget {
  const QueueActionBar({
    super.key,
    required this.waitingCount,
    required this.queueEmpty,
  });

  /// Number of customers currently waiting in the queue.
  final int waitingCount;

  /// When true, the bar shows an "empty queue" message instead of the count.
  final bool queueEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: queueEmpty ? _buildEmptyContent() : _buildWaitingContent(),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Text(
        'Queue is empty for today',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildWaitingContent() {
    final customerLabel =
        '$waitingCount customer${waitingCount == 1 ? '' : 's'} waiting';
    return Row(
      children: [
        const Icon(Icons.people_outline, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '\u2193 $customerLabel',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
