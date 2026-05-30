import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/utils/app_snack_bar.dart';
import '../cubit/access_portal_cubit.dart';
import '../cubit/access_portal_state.dart';
import '../widgets/qr_scanner_view.dart';
import '../widgets/url_entry_bottom_sheet.dart';

class AccessPortalPage extends StatefulWidget {
  const AccessPortalPage({super.key});

  @override
  State<AccessPortalPage> createState() => _AccessPortalPageState();
}

class _AccessPortalPageState extends State<AccessPortalPage> {
  late final MobileScannerController _controller;
  bool _isTorchOn = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onQrDetected(String raw) {
    if (_hasScanned) return;
    _hasScanned = true;
    context.read<AccessPortalCubit>().submitQrCode(raw);
  }

  Future<void> _onGalleryTap() async {
    try {
      final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (xFile == null || !mounted) {
        return;
      }

      final capture = await _controller.analyzeImage(xFile.path);
      final rawValue = capture?.barcodes.firstOrNull?.rawValue;

      if (!mounted) {
        return;
      }

      if (rawValue == null || rawValue.isEmpty) {
        AppSnackBar.showWarning(
          context,
          'No booking QR code was found in that image.',
        );
        return;
      }

      _onQrDetected(rawValue);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackBar.showError(
        context,
        'Could not scan that image. Try another screenshot or paste the link instead.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessPortalCubit, AccessPortalState>(
      listener: (context, state) {
        if (state is AccessPortalSuccess) {
          HapticFeedback.mediumImpact();
          context.push('/c/org/${state.slug}');
          _hasScanned = false;
        } else if (state is AccessPortalError) {
          AppSnackBar.showError(context, state.message);
          context.read<AccessPortalCubit>().reset();
          _hasScanned = false;
        }
      },
      builder: (context, state) {
        final isResolving = state is AccessPortalResolving;
        return Scaffold(
          backgroundColor: const Color(0xFF101822),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              QrScannerView(controller: _controller, onDetect: _onQrDetected),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: UrlEntryBottomSheet(
                  isResolving: isResolving,
                  onConnect: (url) =>
                      context.read<AccessPortalCubit>().submitUrl(url),
                  onGallery: _onGalleryTap,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _GlassButton(
                          icon: Icons.close,
                          onTap: () => context.pop(),
                        ),
                        _GlassButton(
                          icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          onTap: () {
                            _controller.toggleTorch();
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
