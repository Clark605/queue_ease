import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../../shared_domain/entities/service_entity.dart';

class ConfirmationCard extends StatelessWidget {
  const ConfirmationCard({
    super.key,
    required this.orgName,
    required this.orgAddress,
    required this.service,
    required this.appointment,
  });

  final String orgName;
  final String? orgAddress;
  final ServiceEntity service;
  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final scheduledAt = appointment.scheduledAt;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ConfirmationDetailRow(
            icon: Icons.business_outlined,
            label: 'Organisation',
            value: orgName,
          ),
          const SizedBox(height: 12),
          ConfirmationDetailRow(
            icon: Icons.medical_services_outlined,
            label: 'Service',
            value: service.name,
          ),
          const SizedBox(height: 12),
          ConfirmationDetailRow(
            icon: Icons.event_outlined,
            label: 'Date',
            value: DateFormat('EEEE, MMMM d, yyyy').format(scheduledAt),
          ),
          const SizedBox(height: 12),
          ConfirmationDetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: DateFormat('h:mm a').format(scheduledAt),
          ),
          const SizedBox(height: 12),
          ConfirmationDetailRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '${service.durationMinutes} min',
          ),
          if (orgAddress != null) ...[
            const SizedBox(height: 12),
            ConfirmationDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: orgAddress!,
            ),
          ],
        ],
      ),
    );
  }
}

class ConfirmationDetailRow extends StatelessWidget {
  const ConfirmationDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
