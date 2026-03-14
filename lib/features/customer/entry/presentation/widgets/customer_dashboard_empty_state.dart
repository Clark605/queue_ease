import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Empty state shown on the customer dashboard when there are no active
/// queue entries or upcoming appointments for today.
class CustomerDashboardEmptyState extends StatelessWidget {
  const CustomerDashboardEmptyState({
    super.key,
    required this.onBookAppointment,
  });

  final VoidCallback onBookAppointment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            const Text(
              'No bookings today',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Scan a QR code or use a link to book your first appointment.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onBookAppointment,
              icon: const Icon(Icons.add),
              label: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
