import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Animated "LIVE" indicator pill with a pulsing blue dot.
///
/// Uses an [AnimationController] that repeats with reverse to produce a
/// continuous 0.25→1.0 opacity fade on the dot at 900ms per cycle.
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _opacity,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'LIVE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
