import '../entities/user_entity.dart';
import '../entities/user_role.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Returns the currently signed-in [UserEntity], or `null` if no session
  /// exists. Used on app startup to restore a prior session.
  Future<UserEntity?> getCurrentUser();

  /// Signs in with email and password and returns the authenticated
  /// [UserEntity].
  Future<UserEntity> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Creates a new account, persists the profile to Firestore, and returns
  /// the new [UserEntity].
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
    String? phone,
    String? orgName,
  });

  /// Signs in via Google OAuth and returns the authenticated [UserEntity].
  ///
  /// New Google users are created with [UserRole.customer].
  Future<UserEntity> signInWithGoogle();

  /// Signs out from Firebase and clears the cached role.
  Future<void> signOut();

  /// Sends a password reset email to the provided email address.
  Future<void> sendPasswordResetEmail({required String email});
}
