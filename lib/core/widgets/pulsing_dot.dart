import 'package:flutter/material.dart';

/// A unified PulsingDot widget that provides a consistent animated pulsing dot
/// across the entire Queue Ease application.
///
/// This widget replaces multiple PulsingDot implementations found in various
/// features with a single, reusable component.
class PulsingDot extends StatefulWidget {
  /// The color of the dot. Defaults to Theme.of(context).primaryColor.
  final Color? color;

  /// The size of the dot (both width and height). Defaults to 12.0.
  final double size;

  /// The duration of one pulse cycle. Defaults to 1500ms.
  final Duration duration;

  /// Creates a [PulsingDot] widget.
  const PulsingDot({
    super.key,
    this.color,
    this.size = 12.0,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color ?? Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
