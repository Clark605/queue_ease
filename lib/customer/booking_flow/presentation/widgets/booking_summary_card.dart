import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

/// Read-only card summarising the customer's pending booking.
///
/// Displays the organisation name, service name, appointment date/time,
/// and service duration. All fields are required; pass them from the
/// route [extra] args so the card can be `const`-constructable.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.orgName,
    required this.serviceName,
    required this.scheduledAt,
    required this.durationMinutes,
  });

  final String orgName;
  final String serviceName;
  final DateTime scheduledAt;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(icon: Icons.business_outlined, value: orgName),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.medical_services_outlined,
            value: serviceName,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.event_outlined,
            value: DateFormat('EEEE, MMMM d, yyyy').format(scheduledAt),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.access_time_outlined,
            value: DateFormat('h:mm a').format(scheduledAt),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.timer_outlined,
            value: '$durationMinutes min',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
