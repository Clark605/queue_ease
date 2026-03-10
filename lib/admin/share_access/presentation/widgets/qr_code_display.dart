import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Renders a QR code for the given [url].
///
/// Uses error correction level M (≈15% data recovery) and a fixed 220px size.
/// RepaintBoundary wrapping for download capture is handled at the page level.
class QrCodeDisplay extends StatelessWidget {
  const QrCodeDisplay({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: url,
      version: QrVersions.auto,
      size: 220,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}
