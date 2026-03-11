import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/share_access_state.dart';

/// Action buttons for the Share Access page.
///
/// Renders Share, Copy Link, and Download QR buttons wired to the provided
/// callbacks. All buttons are disabled while a download is in progress, and
/// the Download button shows a loading spinner during [ShareAccessDownloading].
class ShareActionButtons extends StatelessWidget {
  const ShareActionButtons({
    super.key,
    required this.onShare,
    required this.onCopyLink,
    required this.onDownload,
    required this.state,
  });

  final VoidCallback onShare;
  final VoidCallback onCopyLink;
  final VoidCallback onDownload;
  final ShareAccessState state;

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static const _buttonPadding = EdgeInsets.symmetric(vertical: 14);

  @override
  Widget build(BuildContext context) {
    final isDownloading = state is ShareAccessDownloading;
    final isCopied = state is ShareAccessLinkCopied;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isDownloading ? null : onShare,
          icon: const Icon(Icons.share_rounded),
          label: const Text('Share via...'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: _buttonPadding,
            shape: _buttonShape,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isDownloading ? null : onCopyLink,
          icon: Icon(
            isCopied ? Icons.check_circle_outline_rounded : Icons.copy_rounded,
            color: isCopied ? AppColors.success : AppColors.primary,
          ),
          label: Text(
            isCopied ? 'Copied!' : 'Copy Link',
            style: TextStyle(
              color: isCopied ? AppColors.success : AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isCopied ? AppColors.success : AppColors.primary,
            ),
            padding: _buttonPadding,
            shape: _buttonShape,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isDownloading ? null : onDownload,
          icon: isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.download_rounded, color: AppColors.primary),
          label: Text(
            isDownloading ? 'Saving...' : 'Download QR',
            style: const TextStyle(color: AppColors.primary),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDownloading ? AppColors.outline : AppColors.primary,
            ),
            padding: _buttonPadding,
            shape: _buttonShape,
          ),
        ),
      ],
    );
  }
}
