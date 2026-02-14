import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has completed the onboarding flow.
@lazySingleton
class OnboardingService {
  static const _key = 'hasCompletedOnboarding';

  /// Returns `true` if onboarding was already completed.
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as completed so it is not shown again.
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
