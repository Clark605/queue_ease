import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has completed the onboarding flow.
@lazySingleton
class OnboardingService {
  static const _key = 'hasCompletedOnboarding';

  /// Returns `true` if onboarding was already completed.
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (e) {
      // If reading from SharedPreferences fails, assume onboarding is not completed.
      return false;
    }
  }

  /// Marks onboarding as completed so it is not shown again.
  Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (e) {
      // If writing to SharedPreferences fails, ignore the error to avoid crashing.
      // The user will see onboarding again on next launch.
    }
  }
}
