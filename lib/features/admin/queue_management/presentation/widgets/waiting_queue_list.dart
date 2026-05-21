import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/pulsing_dot.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import 'waiting_entry_card.dart';

/// A section widget listing all customers currently waiting in the queue.
///
/// The section header shows the waiting count and an animated live indicator.
/// Each [QueueEntryView] is rendered as a [_WaitingEntryCard]:
/// - `inQueue` entries show a blue position badge and a duration chip.
/// - `noShow` entries show a red position badge, a "(No-Show)" badge, and a
///   "Rejoin" button.
///
/// When [entries] is empty, a centred empty-state is displayed instead.
class WaitingQueueList extends StatelessWidget {
  const WaitingQueueList({
    super.key,
    required this.entries,
    required this.onRejoin,
    required this.isActionInFlight,
  });

  /// Waiting queue entries to display. May contain `inQueue` and `noShow`
  /// statuses.
  final List<QueueEntryView> entries;

  /// Called with the appointment ID when the admin taps "Rejoin".
  final void Function(String appointmentId) onRejoin;

  /// When true, all "Rejoin" buttons are disabled.
  final bool isActionInFlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          _buildEmptyState()
        else
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WaitingEntryCard(
                key: ValueKey(entry.appointmentId),
                entry: entry,
                onRejoin: onRejoin,
                isActionInFlight: isActionInFlight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Waiting',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 15),
        ),
        const SizedBox(width: 6),
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${entries.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        // Live indicator
        const PulsingDot(),
        const SizedBox(width: 4),
        Text(
          'Live',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No more customers waiting',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
