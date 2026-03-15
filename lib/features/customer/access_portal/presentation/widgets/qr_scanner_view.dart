import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/theme/app_colors.dart';

/// Full-screen camera view with a scanner frame overlay.
///
/// Wraps [MobileScanner] and draws the scrim, frame, corner markers and
/// animated scan line on top. Calls [onDetect] with the raw barcode string.
class QrScannerView extends StatelessWidget {
  const QrScannerView({
    super.key,
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final ValueChanged<String> onDetect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null) onDetect(value);
          },
        ),
        _ScannerOverlay(),
      ],
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semi-transparent scrim with hole in the center
        _ScannerScrim(),
        // Frame sits exactly over the hole
        const _ScannerFrame(),
        // Title / subtitle below the frame
        Positioned(
          top: MediaQuery.sizeOf(context).height / 2 + 128 + 24,
          left: 32,
          right: 32,
          child: const Column(
            children: [
              Text(
                'Point your camera at a QR code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFFD1D5DB)),
              ),
            ],
          ),
        ),
        // Title above frame
        Positioned(
          bottom: MediaQuery.sizeOf(context).height / 2 + 128 + 24,
          left: 32,
          right: 32,
          child: const Text(
            'Scan QR Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerScrim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _ScrimPainter());
  }
}

class _ScrimPainter extends CustomPainter {
  static const _frameSize = 256.0;
  static const _frameRadius = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: _frameSize,
      height: _frameSize,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_frameRadius),
    );

    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  static const _frameSize = 256.0;
  static const _frameRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_frameRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          width: _frameSize,
          height: _frameSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_frameRadius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Stack(
            children: [
              Positioned(
                top: -2,
                left: -2,
                child: _CornerMarker(corner: _Corner.topLeft),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: _CornerMarker(corner: _Corner.topRight),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: _CornerMarker(corner: _Corner.bottomLeft),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: _CornerMarker(corner: _Corner.bottomRight),
              ),
              _AnimatedScanLine(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerMarker extends StatelessWidget {
  const _CornerMarker({required this.corner});

  final _Corner corner;

  static const _size = 24.0;
  static const _thickness = 4.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(_size, _size),
      painter: _CornerPainter(corner: corner),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.corner});

  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = _CornerMarker._thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final s = size.width;
    const t = _CornerMarker._thickness / 2;
    // Arm length — half the marker size
    const arm = _CornerMarker._size / 2;

    switch (corner) {
      case _Corner.topLeft:
        canvas.drawLine(const Offset(t, t), const Offset(arm, t), paint);
        canvas.drawLine(const Offset(t, t), const Offset(t, arm), paint);
      case _Corner.topRight:
        canvas.drawLine(Offset(s - t, t), Offset(s - arm, t), paint);
        canvas.drawLine(Offset(s - t, t), Offset(s - t, arm), paint);
      case _Corner.bottomLeft:
        canvas.drawLine(Offset(t, s - t), Offset(arm, s - t), paint);
        canvas.drawLine(Offset(t, s - t), Offset(t, s - arm), paint);
      case _Corner.bottomRight:
        canvas.drawLine(Offset(s - t, s - t), Offset(s - arm, s - t), paint);
        canvas.drawLine(Offset(s - t, s - t), Offset(s - t, s - arm), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.corner != corner;
}

class _AnimatedScanLine extends StatefulWidget {
  const _AnimatedScanLine();

  @override
  State<_AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<_AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = _controller;
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
        // Line travels in the inner area (16px inset from frame edges)
        const inset = 16.0;
        const frameSize = 256.0;
        const travel = frameSize - inset * 2;
        return Positioned(
          top: inset + _animation.value * travel,
          left: inset,
          right: inset,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
