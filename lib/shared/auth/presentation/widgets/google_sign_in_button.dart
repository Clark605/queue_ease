import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';

/// Outlined button for Google OAuth sign-in / sign-up.
///
/// The label is customisable so the same widget works on both the Login
/// screen ("Continue with Google") and the Sign-Up screen.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" mark – placeholder until an SVG asset is added.
            const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
