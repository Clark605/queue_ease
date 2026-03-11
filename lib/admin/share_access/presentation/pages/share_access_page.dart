import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../organization/presentation/cubit/organization_cubit.dart';
import '../../../organization/presentation/cubit/organization_state.dart';
import '../cubit/share_access_cubit.dart';
import '../cubit/share_access_state.dart';
import '../widgets/qr_code_display.dart';
import '../widgets/share_action_buttons.dart';

/// Share Access page — QR code display, link sharing, and copy-link actions.
///
/// Reads [bookingLinkSlug] from the ambient [OrganizationCubit] (provided by
/// the router) and derives the full booking URL. Shows an error prompt when
/// the slug is missing or the org data cannot be loaded.
class ShareAccessPage extends StatelessWidget {
  const ShareAccessPage({super.key});

  static const String _baseUrl = 'https://queueease.app/org/';

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareAccessCubit, ShareAccessState>(
      listener: _handleShareState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Share Access'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<OrganizationCubit, OrganizationState>(
          builder: (context, orgState) {
            if (orgState is OrganizationInitial ||
                orgState is OrganizationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (orgState is OrganizationError) {
              return _MissingSlugError(message: orgState.message);
            }

            if (orgState is OrganizationLoaded) {
              final slug = orgState.organization.bookingLinkSlug;
              if (slug.isEmpty) {
                return const _MissingSlugError(
                  message:
                      'Booking link not found. Please contact support to set up your organization link.',
                );
              }
              return _ShareAccessBody(bookingUrl: '$_baseUrl$slug');
            }

            return const _MissingSlugError();
          },
        ),
      ),
    );
  }

  void _handleShareState(BuildContext context, ShareAccessState state) {
    switch (state) {
      case ShareAccessLinkCopied():
        _showSnackBar(context, 'Link copied to clipboard', AppColors.success);
      case ShareAccessDownloaded():
        _showSnackBar(context, 'QR code saved to gallery', AppColors.success);
      case ShareAccessError(:final message):
        _showSnackBar(context, message, AppColors.error);
      case _:
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ShareAccessBody extends StatefulWidget {
  const _ShareAccessBody({required this.bookingUrl});

  final String bookingUrl;

  @override
  State<_ShareAccessBody> createState() => _ShareAccessBodyState();
}

class _ShareAccessBodyState extends State<_ShareAccessBody> {
  final GlobalKey _qrKey = GlobalKey();

  Future<Uint8List?> _captureQrBytes() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShareAccessCubit>();
    return BlocBuilder<ShareAccessCubit, ShareAccessState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQrCard(),
                    const SizedBox(height: 20),
                    _buildUrlChip(),
                    const SizedBox(height: 32),
                    _buildSectionDivider(),
                    const SizedBox(height: 24),
                    ShareActionButtons(
                      state: state,
                      onShare: () async {
                        final bytes = await _captureQrBytes();
                        await cubit.shareContent(
                          url: widget.bookingUrl,
                          qrBytes: bytes,
                        );
                      },
                      onCopyLink: () => cubit.copyLink(widget.bookingUrl),
                      onDownload: () async {
                        final bytes = await _captureQrBytes();
                        if (bytes != null) await cubit.downloadQrCode(bytes);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Booking QR Code',
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Let customers scan this to join your queue instantly.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: QrCodeDisplay(url: widget.bookingUrl),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text('Secure · Queue Ease', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.bookingUrl,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('Actions', style: AppTextStyles.labelSmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _MissingSlugError extends StatelessWidget {
  const _MissingSlugError({
    this.message = 'Unable to load organization data. Please contact support.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Setup Required',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
