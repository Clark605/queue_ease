import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/admin_appointment_repository.dart';

/// Trailing area for a [WaitingEntryCard]: shows time chips for `inQueue`
/// entries, or a Rejoin button for `noShow` entries.
class WaitingEntryTrailing extends StatelessWidget {
  const WaitingEntryTrailing({
    super.key,
    required this.entry,
    required this.isNoShow,
    required this.isActionInFlight,
    required this.onRejoin,
  });

  final QueueEntryView entry;
  final bool isNoShow;
  final bool isActionInFlight;
  final void Function(String appointmentId) onRejoin;

  @override
  Widget build(BuildContext context) {
    if (isNoShow) {
      return WaitingEntryRejoinButton(
        onPressed: isActionInFlight
            ? null
            : () => onRejoin(entry.appointmentId),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entry.estimatedWaitMinutes != null) ...[
          WaitingEntryMetadataChip(
            icon: Icons.timelapse_outlined,
            label: '≈ ${entry.estimatedWaitMinutes} min',
          ),
          const SizedBox(width: 6),
        ],
        WaitingEntryMetadataChip(
          icon: Icons.schedule_outlined,
          label: '${entry.serviceDurationMinutes} min',
        ),
      ],
    );
  }
}

/// Pill chip showing a small icon and a short text label.
class WaitingEntryMetadataChip extends StatelessWidget {
  const WaitingEntryMetadataChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

/// Small outlined "Rejoin" button shown on no-show queue entries.
class WaitingEntryRejoinButton extends StatelessWidget {
  const WaitingEntryRejoinButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.replay_outlined, size: 14),
        label: const Text(
          'Rejoin',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
