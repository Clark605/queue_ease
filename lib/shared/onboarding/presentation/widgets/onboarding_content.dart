import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../domain/models/onboarding_content_model.dart';

/// Displays a single onboarding page with an illustration, title, and subtitle.
///
/// The layout adapts to available height by giving the illustration a flexible
/// share of the space and keeping the text content pinned at the bottom.
class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key, required this.model});

  final OnboardingContentModel model;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Give illustrations roughly half the screen but cap on very tall devices.
    final illustrationMaxHeight = screenHeight * 0.48;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration area – flexible to fill available space.
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: illustrationMaxHeight),
              child: model.illustrationBuilder(context),
            ),
          ),

          const SizedBox(height: 24),

          // Title.
          _buildTitle(context),

          const SizedBox(height: 12),

          // Subtitle.
          Text(
            model.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (model.highlightedTitle == null) {
      return Text(
        model.title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        text: model.title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        children: [
          TextSpan(
            text: model.highlightedTitle,
            style: const TextStyle(color: AppColors.primary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
