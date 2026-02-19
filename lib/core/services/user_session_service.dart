import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/auth/domain/entities/user_role.dart';
import '../error/app_exception.dart';
import '../utils/app_logger.dart';

/// Persists the authenticated user's role across app restarts.
///
/// Mirrors the pattern used by [OnboardingService] — thin wrapper over
/// [SharedPreferences] with a dedicated key.
@lazySingleton
class UserSessionService {
  const UserSessionService(this._logger);

  final AppLogger _logger;
  static const _key = 'userRole';

  /// Persists [role] to local storage.
  Future<void> saveRole(UserRole role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, role.name);
    } on Exception catch (e, st) {
      _logger.warning(
        'Failed to persist user role — role will be fetched from Firestore on next cold start.',
        StorageException('SharedPreferences write failed: $e', stackTrace: st),
        st,
      );
    }
  }

  /// Returns the cached [UserRole], or `null` if none is stored.
  Future<UserRole?> getRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value == null) return null;
      return UserRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => UserRole.customer,
      );
    } on Exception catch (e, st) {
      _logger.warning(
        'Failed to read cached user role.',
        StorageException('SharedPreferences read failed: $e', stackTrace: st),
        st,
      );
      return null;
    }
  }

  /// Removes the cached role (called on sign-out).
  Future<void> clearRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } on Exception catch (e, st) {
      _logger.warning(
        'Failed to clear cached user role.',
        StorageException('SharedPreferences remove failed: $e', stackTrace: st),
        st,
      );
    }
  }
}
