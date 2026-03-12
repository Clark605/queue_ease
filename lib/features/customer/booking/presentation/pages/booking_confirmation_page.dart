import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/service_entity.dart';

/// Arguments passed via GoRouter [extra] to [BookingConfirmationPage].
typedef BookingConfirmationArgs = ({
  String orgName,
  String? orgAddress,
  ServiceEntity service,
  AppointmentEntity appointment,
});

/// Terminal screen confirming a successful booking.
///
/// Receives all display data via [args]; no async loading occurs here.
/// The "Back to Home" button clears the booking stack via [context.go].
class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key, required this.args});

  final BookingConfirmationArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SuccessIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'Booking Confirmed!',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your appointment has been successfully booked.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _ConfirmationCard(args: args),
                  ],
                ),
              ),
            ),
            _HomeButton(onTap: () => context.go('/c/home')),
          ],
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline_rounded,
        color: AppColors.success,
        size: 52,
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({required this.args});

  final BookingConfirmationArgs args;

  @override
  Widget build(BuildContext context) {
    final scheduledAt = args.appointment.scheduledAt;
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
          _DetailRow(
            icon: Icons.business_outlined,
            label: 'Organisation',
            value: args.orgName,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.medical_services_outlined,
            label: 'Service',
            value: args.service.name,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.event_outlined,
            label: 'Date',
            value: DateFormat('EEEE, MMMM d, yyyy').format(scheduledAt),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: DateFormat('h:mm a').format(scheduledAt),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '${args.service.durationMinutes} min',
          ),
          if (args.orgAddress != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: args.orgAddress!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
