/// Sealed base class for all application-level exceptions.
///
/// Every feature layer should map platform/third-party exceptions into one
/// of these subtypes so that the presentation layer only ever deals with a
/// single, structured hierarchy.
///
/// Example:
/// ```dart
/// try {
///   await _auth.signIn(email, password);
/// } on FirebaseAuthException catch (e, st) {
///   throw AuthException.fromFirebase(e.code, stackTrace: st);
/// }
/// ```
sealed class AppException implements Exception {
  const AppException({required this.message, this.stackTrace});

  /// Human-readable description of the error.
  final String message;

  /// Optional stack trace captured at the throw site.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

// ---------------------------------------------------------------------------
// Concrete subtypes
// ---------------------------------------------------------------------------

/// Thrown when a Firebase Authentication operation fails.
final class AuthException extends AppException {
  const AuthException(String message, {this.code, super.stackTrace})
    : super(message: message);

  /// Optional Firebase Auth error code (e.g. `"user-not-found"`).
  final String? code;

  /// Maps common Firebase Auth error codes to user-friendly messages.
  factory AuthException.fromFirebase(String code, {StackTrace? stackTrace}) {
    final message = switch (code) {
      'user-not-found' => 'No account found for this email address.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password is too weak. Please choose a stronger one.',
      'invalid-email' => 'The email address is not valid.',
      'user-disabled' =>
        'This account has been disabled. Please contact support.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Please check your network.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled. Please contact support.',
      'invalid-credential' =>
        'Invalid credentials. Please check your email and password.',
      _ => 'Authentication failed ($code).',
    };
    return AuthException(message, code: code, stackTrace: stackTrace);
  }

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

/// Thrown when a Firestore or other remote data operation fails.
final class DatabaseException extends AppException {
  const DatabaseException(String message, {super.stackTrace})
    : super(message: message);
}

/// Thrown when a [SharedPreferences] or other local storage operation fails.
final class StorageException extends AppException {
  const StorageException(String message, {super.stackTrace})
    : super(message: message);
}

/// Thrown when user-supplied input fails business-rule validation before
/// being sent to a backend.
final class ValidationException extends AppException {
  const ValidationException(String message, {this.field, super.stackTrace})
    : super(message: message);

  /// The specific field that failed validation, if applicable.
  final String? field;

  @override
  String toString() => 'ValidationException(field: $field, message: $message)';
}

/// Catch-all for unexpected errors that don't fit any other category.
final class UnknownException extends AppException {
  const UnknownException(String message, {this.cause, super.stackTrace})
    : super(message: message);

  /// The original exception that caused this unknown error.
  final Object? cause;

  @override
  String toString() => 'UnknownException(cause: $cause, message: $message)';
}
