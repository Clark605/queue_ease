import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/app/theme/app_colors.dart';
import 'package:queue_ease/core/app/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
    });

    test('light theme uses primary color', () {
      final theme = AppTheme.light;
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });

    test('light theme sets scaffold background', () {
      final theme = AppTheme.light;
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });
  });

  group('AppColors', () {
    test('primary color is correct', () {
      expect(AppColors.primary, equals(const Color(0xFF1E88E5)));
    });
  });
}
