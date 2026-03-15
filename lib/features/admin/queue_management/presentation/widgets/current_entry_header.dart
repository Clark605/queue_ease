import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import 'queue_action_button.dart';

/// Header section of [CurrentQueueCard] showing position badge,
/// customer name, duration, and the "Serving" chip.
class CurrentEntryHeader extends StatelessWidget {
  const CurrentEntryHeader({super.key, required this.entry});

  final QueueEntryView entry;

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
            ],
          ),
        ),
        const SizedBox(width: 8),
        const ServingChip(),
      ],
    );
  }
}
