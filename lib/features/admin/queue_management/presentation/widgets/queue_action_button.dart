import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

enum QueueActionButtonVariant { filled, outlinedWarning, outlinedError }

/// A single action button for the queue management card.
///
/// Renders filled primary for "Next" and outlined variants for "Skip" and
/// "No-Show". While [isLoading] is true the icon/label are replaced with a
/// [CircularProgressIndicator].
class QueueActionButton extends StatelessWidget {
  const QueueActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    required this.isLoading,
    required this.variant,
  });

  final String label;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final QueueActionButtonVariant variant;

  Color get _foregroundColor => switch (variant) {
    QueueActionButtonVariant.filled => Colors.white,
    QueueActionButtonVariant.outlinedWarning => AppColors.warning,
    QueueActionButtonVariant.outlinedError => AppColors.error,
  };

  Color get _backgroundColor => switch (variant) {
    QueueActionButtonVariant.filled => AppColors.primary,
    QueueActionButtonVariant.outlinedWarning => Colors.transparent,
    QueueActionButtonVariant.outlinedError => Colors.transparent,
  };

  Color get _borderColor => switch (variant) {
    QueueActionButtonVariant.filled => AppColors.primary,
    QueueActionButtonVariant.outlinedWarning => AppColors.warning,
    QueueActionButtonVariant.outlinedError => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      enabled: onPressed != null,
      child: SizedBox(
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _foregroundColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: _foregroundColor),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _foregroundColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green "Serving" pill chip shown in [CurrentEntryHeader].
class ServingChip extends StatelessWidget {
  const ServingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Serving',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
