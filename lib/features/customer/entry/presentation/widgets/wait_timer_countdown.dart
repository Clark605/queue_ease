import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/time_utils.dart';

class WaitTimerCountdown extends StatefulWidget {
  const WaitTimerCountdown({
    super.key,
    required this.expectedServiceTime,
    this.fallbackWaitMinutes,
  });

  /// The absolute time when the customer is expected to be served.
  final DateTime? expectedServiceTime;

  /// The static fallback wait time in minutes if [expectedServiceTime] is null.
  final int? fallbackWaitMinutes;

  @override
  State<WaitTimerCountdown> createState() => _WaitTimerCountdownState();
}

class _WaitTimerCountdownState extends State<WaitTimerCountdown> {
  static const _shortWaitThresholdMinutes = 10;
  static const _mediumWaitThresholdMinutes = 30;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every 15 seconds to keep the UI responsive; this is a tradeoff
    // between accuracy and battery/network usage. Display is in minutes.
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant WaitTimerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the expected time changed, trigger a rebuild immediately.
    if (oldWidget.expectedServiceTime != widget.expectedServiceTime) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _remainingMinutes() {
    if (widget.expectedServiceTime != null) {
      final mins = widget.expectedServiceTime!
          .difference(TimeUtils.nowUtc())
          .inMinutes;
      return mins > 0 ? mins : 0;
    }
    return widget.fallbackWaitMinutes ?? 0;
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
    if (widget.expectedServiceTime == null &&
        widget.fallbackWaitMinutes == null) {
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
