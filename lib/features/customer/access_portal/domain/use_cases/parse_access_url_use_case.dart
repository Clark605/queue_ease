import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';

/// Extracts an organization slug from a raw QR/URL value.
///
/// Accepts three forms in priority order:
///   1. Full URL with `/c/org/:slug` path
///   2. Full URL with `/check-in/:slug` path
///   3. Plain slug matching `^[a-zA-Z0-9_-]+$`
@lazySingleton
class ParseAccessUrlUseCase {
  static final _orgPathPattern = RegExp(r'/c/org/([a-zA-Z0-9_-]+)');
  static final _checkInPattern = RegExp(r'/check-in/([a-zA-Z0-9_-]+)');
  static final _plainSlugPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  Result<String> call(String rawValue) {
    final trimmed = rawValue.trim();

    final orgMatch = _orgPathPattern.firstMatch(trimmed);
    if (orgMatch != null) return Success(orgMatch.group(1)!);

    final checkInMatch = _checkInPattern.firstMatch(trimmed);
    if (checkInMatch != null) return Success(checkInMatch.group(1)!);

    if (_plainSlugPattern.hasMatch(trimmed)) return Success(trimmed);

    return const Failure(
      ValidationException('Could not find a valid organization code.'),
    );
  }
}
