import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class BookingActionBar extends StatelessWidget {
  const BookingActionBar({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: enabled ? onTap : null,
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              label: const Text(
                'Book Appointment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
