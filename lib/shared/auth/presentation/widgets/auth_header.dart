import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';

/// Branding header shared by Login and Sign-Up screens.
///
/// Displays the app icon, name, and a short tagline.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: AppColors.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'QueueEase',
          style: AppTextStyles.headlineMedium.copyWith(letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage appointments seamlessly',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
