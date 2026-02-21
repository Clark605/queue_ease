import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/app_exception.dart';
import '../utils/app_logger.dart';

/// Tracks whether the user has completed the onboarding flow.
@lazySingleton
class OnboardingService {
  const OnboardingService(this._logger);

  final AppLogger _logger;
  static const _key = 'hasCompletedOnboarding';

  /// Returns `true` if onboarding was already completed.
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } on Exception catch (e, st) {
      _logger.warning(
        'Failed to read onboarding state — defaulting to incomplete.',
        StorageException('SharedPreferences read failed: $e', stackTrace: st),
        st,
      );
      // If reading from SharedPreferences fails, assume onboarding is not completed.
      return false;
    }
  }

  /// Marks onboarding as completed so it is not shown again.
  Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } on Exception catch (e, st) {
      _logger.warning(
        'Failed to persist onboarding completion — user may see onboarding again on next launch.',
        StorageException('SharedPreferences write failed: $e', stackTrace: st),
        st,
      );
    }
  }
}
