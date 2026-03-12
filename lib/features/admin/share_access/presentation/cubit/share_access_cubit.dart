import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/utils/app_logger.dart';
import 'share_access_state.dart';

/// Manages share access actions: copy link and share via native share sheet.
///
/// No repository dependency — all operations use platform services directly.
@injectable
class ShareAccessCubit extends Cubit<ShareAccessState> {
  ShareAccessCubit(this._logger) : super(const ShareAccessInitial());

  final AppLogger _logger;

  /// Copies [url] to the clipboard, emits [ShareAccessLinkCopied], then
  /// resets to [ShareAccessInitial] after a 2-second confirmation window.
  Future<void> copyLink(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      emit(const ShareAccessLinkCopied());
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!isClosed) emit(const ShareAccessInitial());
    } catch (e, st) {
      _logger.error('ShareAccessCubit: copyLink failed', e, st);
      emit(const ShareAccessError('Failed to copy link. Please try again.'));
    }
  }

  /// Opens the native share sheet.
  ///
  /// When [qrBytes] is provided (Phase 6), shares the PNG file alongside the
  /// URL. Falls back to URL-only sharing when bytes are absent.
  Future<void> shareContent({required String url, Uint8List? qrBytes}) async {
    try {
      if (qrBytes != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                qrBytes,
                mimeType: 'image/png',
                name: 'qr_code.png',
              ),
            ],
            text: url,
          ),
        );
      } else {
        await SharePlus.instance.share(ShareParams(text: url));
      }
    } catch (e, st) {
      _logger.error('ShareAccessCubit: shareContent failed', e, st);
      emit(const ShareAccessError('Failed to share. Please try again.'));
    }
  }

  /// Saves [pngBytes] to the device gallery.
  ///
  /// Emits [ShareAccessDownloading] while saving, [ShareAccessDownloaded] on
  /// success, or [ShareAccessError] with a permission hint on [GalException].
  Future<void> downloadQrCode(Uint8List pngBytes) async {
    emit(const ShareAccessDownloading());
    try {
      await Gal.putImageBytes(pngBytes);
      emit(const ShareAccessDownloaded());
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!isClosed) emit(const ShareAccessInitial());
    } on GalException catch (e, st) {
      _logger.error('ShareAccessCubit: downloadQrCode failed', e, st);
      emit(
        const ShareAccessError(
          'Could not save image. Please grant photo library permission and try again.',
        ),
      );
    } catch (e, st) {
      _logger.error('ShareAccessCubit: downloadQrCode unexpected error', e, st);
      emit(
        const ShareAccessError('Failed to download QR code. Please try again.'),
      );
    }
  }
}
