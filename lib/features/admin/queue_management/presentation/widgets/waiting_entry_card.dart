import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import 'waiting_entry_actions.dart';

/// A single card row representing one waiting queue entry.
///
/// `inQueue` entries show a blue position badge and duration chips.
/// `noShow` entries show a red position badge, a "No-Show" badge inline
/// with the name, and a "Rejoin" button in the trailing area.
class WaitingEntryCard extends StatelessWidget {
  const WaitingEntryCard({
    super.key,
    required this.entry,
    required this.onRejoin,
    required this.isActionInFlight,
  });

  final QueueEntryView entry;
  final void Function(String appointmentId) onRejoin;
  final bool isActionInFlight;

  bool get _isNoShow => entry.status == AppointmentStatus.noShow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: _isNoShow
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _PositionBadge(position: entry.position, isNoShow: _isNoShow),
            const SizedBox(width: 12),
            Expanded(
              child: _CustomerInfo(entry: entry, isNoShow: _isNoShow),
            ),
            const SizedBox(width: 8),
            WaitingEntryTrailing(
              entry: entry,
              isNoShow: _isNoShow,
              isActionInFlight: isActionInFlight,
              onRejoin: onRejoin,
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position, required this.isNoShow});

  final int position;
  final bool isNoShow;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isNoShow ? AppColors.error : AppColors.primary;
    return Semantics(
      label: 'Queue position $position',
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 1,
                height: 1,
              ),
            ),
            Text(
              '$position',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: badgeColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  const _CustomerInfo({required this.entry, required this.isNoShow});

  final QueueEntryView entry;
  final bool isNoShow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                entry.customerName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isNoShow) ...[const SizedBox(width: 6), const _NoShowBadge()],
          ],
        ),
      ],
    );
  }
}

class _NoShowBadge extends StatelessWidget {
  const _NoShowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Text(
        'No-Show',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
