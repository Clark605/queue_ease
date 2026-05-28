import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';

/// Extracts an organization slug from a raw QR/URL value.
///
/// Accepts three forms in priority order:
///   1. Full URL with `/org/:slug` or `/c/org/:slug` path
///   2. Full URL with `/check-in/:slug` path
///   3. Plain slug matching `^[a-zA-Z0-9_-]+$`
@lazySingleton
class ParseAccessUrlUseCase {
  static final _plainSlugPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  Result<String> call(String rawValue) {
    final trimmed = rawValue.trim();

    final parsedSlug = _parseSlugFromUrl(trimmed);
    if (parsedSlug != null) return Success(parsedSlug);

    final normalizedSlug = trimmed.toLowerCase();
    if (_plainSlugPattern.hasMatch(normalizedSlug))
      return Success(normalizedSlug);

    return const Failure(
      ValidationException('Could not find a valid booking URL or code.'),
    );
  }

  String? _parseSlugFromUrl(String rawValue) {
    final uri = Uri.tryParse(rawValue);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'org') {
      return _extractSlug(segments[1]);
    }

    if (segments.length >= 3 && segments[0] == 'c' && segments[1] == 'org') {
      return _extractSlug(segments[2]);
    }

    if (segments.length >= 2 && segments[0] == 'check-in') {
      return _extractSlug(segments[1]);
    }

    return null;
  }

  String? _extractSlug(String rawSlug) {
    final normalizedSlug = rawSlug.trim().toLowerCase();
    if (_plainSlugPattern.hasMatch(normalizedSlug)) {
      return normalizedSlug;
    }

    return null;
  }
}
