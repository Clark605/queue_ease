import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

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
  Timer? _timer;
  int _remainingMinutes = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(milliseconds: 30000), (_) {
      _updateTime();
    });
  }

  @override
  void didUpdateWidget(WaitTimerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expectedServiceTime != widget.expectedServiceTime ||
        oldWidget.fallbackWaitMinutes != widget.fallbackWaitMinutes) {
      _updateTime();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (widget.expectedServiceTime != null) {
      final diff = widget.expectedServiceTime!.difference(DateTime.now());
      final mins = diff.inMinutes;
      setState(() {
        _remainingMinutes = mins > 0 ? mins : 0;
      });
    } else {
      setState(() {
        _remainingMinutes = widget.fallbackWaitMinutes ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expectedServiceTime == null && widget.fallbackWaitMinutes == null) {
      return const Text(
        '—',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      );
    }
    
    return Text(
      '$_remainingMinutes min',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }
}
