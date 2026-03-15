import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import 'current_entry_header.dart';
import 'queue_action_button.dart';

/// A card displaying the customer currently being served.
///
/// Shows a green left accent border, position badge, customer name,
/// service duration, a "Serving" chip, and three action buttons
/// (Next, Skip, No-Show). All buttons are disabled while [isActionInFlight]
/// is true and each displays a [CircularProgressIndicator].
class CurrentQueueCard extends StatelessWidget {
  const CurrentQueueCard({
    super.key,
    required this.entry,
    this.onNext,
    this.onSkip,
    this.onNoShow,
    required this.isActionInFlight,
  });

  /// The queue entry currently being served.
  final QueueEntryView entry;

  /// Called when the admin taps "Next" to advance the queue.
  final VoidCallback? onNext;

  /// Called when the admin taps "Skip" to move the customer to the end.
  final VoidCallback? onSkip;

  /// Called when the admin taps "No-Show" to mark the customer absent.
  final VoidCallback? onNoShow;

  /// When true, all action buttons are disabled and show a loading indicator.
  final bool isActionInFlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Clip so the left accent bar respects the card's border radius.
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Green left accent bar ──────────────────────────────────────
            Container(width: 4, color: AppColors.success),
            // ── Card content ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentEntryHeader(entry: entry),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.outline.withValues(alpha: 0.4),
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: QueueActionButton(
            label: 'Next',
            icon: Icons.check_circle_outline,
            semanticsLabel: 'Mark as done and serve next customer',
            onPressed: isActionInFlight || !entry.allowedActions.canComplete
                ? null
                : onNext,
            isLoading: isActionInFlight,
            variant: QueueActionButtonVariant.filled,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QueueActionButton(
            label: 'Skip',
            icon: Icons.skip_next,
            semanticsLabel: 'Skip current customer to end of queue',
            onPressed: isActionInFlight || !entry.allowedActions.canSkip
                ? null
                : onSkip,
            isLoading: isActionInFlight,
            variant: QueueActionButtonVariant.outlinedWarning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QueueActionButton(
            label: 'No-Show',
            icon: Icons.person_off_outlined,
            semanticsLabel: 'Mark current customer as no-show',
            onPressed: isActionInFlight || !entry.allowedActions.canMarkNoShow
                ? null
                : onNoShow,
            isLoading: isActionInFlight,
            variant: QueueActionButtonVariant.outlinedError,
          ),
        ),
      ],
    );
  }
}
