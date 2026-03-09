import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';

/// A labelled stepper row with an icon, title, subtitle, and +/− controls.
///
/// Used for Duration and Time Margin fields in the service form.
class ServiceStepperRow extends StatelessWidget {
  const ServiceStepperRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int value;
  final String unit;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _iconContainer(),
          const SizedBox(width: 12),
          Expanded(child: _label()),
          _stepper(),
        ],
      ),
    );
  }

  Widget _iconContainer() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _label() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _stepper() {
    return Row(
      children: [
        _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          child: Column(
            children: [
              Text(
                '$value',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                unit.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StepperButton(icon: Icons.add_rounded, onTap: onIncrement),
      ],
    );
  }
}

/// Circular +/− button with a primary-coloured border.
class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    final color = active ? AppColors.primary : AppColors.outline;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
