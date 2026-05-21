import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class EmptyDashboardHeroCard extends StatelessWidget {
  const EmptyDashboardHeroCard({
    super.key,
    required this.hasActiveQueue,
    required this.hasUpcoming,
  });

  final bool hasActiveQueue;
  final bool hasUpcoming;

  @override
  Widget build(BuildContext context) {
    final chips = <_StatusChipData>[
      _StatusChipData(
        label: hasActiveQueue ? 'Active queue' : 'No active queue',
        color: hasActiveQueue ? AppColors.success : AppColors.onSurfaceVariant,
      ),
      _StatusChipData(
        label: hasUpcoming ? 'Upcoming booking' : 'No upcoming bookings',
        color: hasUpcoming ? AppColors.info : AppColors.onSurfaceVariant,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderRow(),
          const SizedBox(height: 16),
          const Text(
            'No bookings today',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are all set for today. Book a visit or join a queue when you are ready.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => _StatusChip(label: chip.label, color: chip.color),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.event_available, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Your day at a glance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChipData {
  const _StatusChipData({required this.label, required this.color});

  final String label;
  final Color color;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
