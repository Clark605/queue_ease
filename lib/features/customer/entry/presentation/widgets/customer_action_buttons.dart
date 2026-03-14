import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Full-width stacked action buttons for booking and queue tracking.
class CustomerActionButtons extends StatelessWidget {
  const CustomerActionButtons({
    super.key,
    required this.onBook,
    required this.showViewQueue,
    this.onViewQueue,
  });

  final VoidCallback onBook;
  final bool showViewQueue;
  final VoidCallback? onViewQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onBook,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.event_outlined),
            label: const Text(
              'Book Appointment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          if (showViewQueue) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onViewQueue,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              icon: const Icon(
                Icons.visibility_outlined,
                color: AppColors.primary,
              ),
              label: const Text(
                'View My Queue',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
