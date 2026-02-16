import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';

/// Illustration for the "Skip the Wait" onboarding page.
///
/// Displays a stylised hero card with a gradient background and a
/// "You're next in line" status badge at the bottom.
class SkipTheWaitIllustration extends StatelessWidget {
  const SkipTheWaitIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Gradient background.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.2,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.06),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ),

              // Placeholder image area.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/onboarding.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Bottom badge.
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'STATUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "You're next in line",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
