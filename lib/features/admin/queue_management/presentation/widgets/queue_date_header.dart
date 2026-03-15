import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Compact row showing today's full date alongside a live indicator dot.
class QueueDateHeader extends StatelessWidget {
  const QueueDateHeader({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          DateFormat('EEEE, d MMMM y').format(date),
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Live',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
