import 'package:flutter/material.dart';

/// Data class representing a single onboarding page.
class OnboardingContentModel {
  const OnboardingContentModel({
    required this.title,
    this.highlightedTitle,
    required this.subtitle,
    required this.illustrationBuilder,
  });

  /// Plain title text. If [highlightedTitle] is set, this is the prefix.
  final String title;

  /// Part of the title rendered in the primary colour.
  final String? highlightedTitle;

  /// Supporting description below the title.
  final String subtitle;

  /// Builds the illustration widget shown above the text.
  final WidgetBuilder illustrationBuilder;
}
