import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/service_entity.dart';
import '../widgets/confirmation/confirmation_bottom_actions.dart';
import '../widgets/confirmation/confirmation_card.dart';

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
                    ConfirmationCard(
                      orgName: args.orgName,
                      orgAddress: args.orgAddress,
                      service: args.service,
                      appointment: args.appointment,
                    ),
                  ],
                ),
              ),
            ),
            ConfirmationBottomActions(
              orgId: args.appointment.orgId,
              onHomeTap: () => context.go('/c/home'),
            ),
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
