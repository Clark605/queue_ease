import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NowServingCard extends StatelessWidget {
  const NowServingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NOW SERVING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: Color(0xFF0D9488),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '8 MIN REMAINING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 32,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahmed Al-Mansouri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D131B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'General Consultation',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: _QueueActionButton(
                    label: 'Next',
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _QueueActionButton(
                    label: 'No-show',
                    backgroundColor: Color(0xFFFEF2F2),
                    textColor: Color(0xFFDC2626),
                    borderColor: Color(0xFFFECACA),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _QueueActionButton(
                    label: 'Skip',
                    backgroundColor: Color(0xFFF8FAFC),
                    textColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueActionButton extends StatelessWidget {
  const _QueueActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
