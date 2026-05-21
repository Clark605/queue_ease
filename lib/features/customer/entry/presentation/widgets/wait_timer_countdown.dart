import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class WaitTimerCountdown extends StatelessWidget {
  const WaitTimerCountdown({
    super.key,
    required this.expectedServiceTime,
    this.fallbackWaitMinutes,
  });

  /// The absolute time when the customer is expected to be served.
  final DateTime? expectedServiceTime;

  /// The static fallback wait time in minutes if [expectedServiceTime] is null.
  final int? fallbackWaitMinutes;

  static const _shortWaitThresholdMinutes = 10;
  static const _mediumWaitThresholdMinutes = 30;

  int _remainingMinutes() {
    if (expectedServiceTime != null) {
      final mins = expectedServiceTime!.difference(DateTime.now()).inMinutes;
      return mins > 0 ? mins : 0;
    }
    return fallbackWaitMinutes ?? 0;
  }

  Color _urgencyColor(int remainingMinutes) {
    if (remainingMinutes <= _shortWaitThresholdMinutes) {
      return AppColors.waitShort;
    }
    if (remainingMinutes <= _mediumWaitThresholdMinutes) {
      return AppColors.waitMedium;
    }
    return AppColors.waitLong;
  }

  @override
  Widget build(BuildContext context) {
    if (expectedServiceTime == null && fallbackWaitMinutes == null) {
      return const Text(
        '—',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      );
    }

    final remainingMinutes = _remainingMinutes();
    final urgencyColor = _urgencyColor(remainingMinutes);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Text(
        key: ValueKey<int>(remainingMinutes),
        '$remainingMinutes min',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: urgencyColor,
        ),
      ),
    );
  }
}
