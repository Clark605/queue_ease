import 'app_exception.dart';

/// Sealed type that represents either a successful value (`Success<T>`) or a
/// structured failure (`Failure<T>`).
///
/// Use [Result.guard] to wrap async calls that might throw [AppException]:
///
/// ```dart
/// final result = await Result.guard(() => _repo.fetchUser(uid));
/// return switch (result) {
///   Success(:final data) => data,
///   Failure(:final exception) => throw exception,
/// };
/// ```
///
/// Use [when] for exhaustive handling without a `switch` expression:
///
/// ```dart
/// result.when(
///   success: (user) => emit(AuthState.authenticated(user)),
///   failure: (e) => emit(AuthState.error(e.message)),
/// );
/// ```
sealed class Result<T> {
  const Result();

  // ---------------------------------------------------------------------------
  // Factory helpers
  // ---------------------------------------------------------------------------

  /// Wraps [body] and converts any thrown [AppException] into a [Failure].
  /// Any other exception is wrapped in an [UnknownException].
  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Success(await body());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e, st) {
      return Failure(
        UnknownException(
          'An unexpected error occurred.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Type checks
  // ---------------------------------------------------------------------------

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  // ---------------------------------------------------------------------------
  // Unwrapping
  // ---------------------------------------------------------------------------

  /// Returns the success value, or `null` if this is a [Failure].
  T? getOrNull() => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Returns the success value, or [fallback] if this is a [Failure].
  T getOrElse(T fallback) => switch (this) {
    Success(:final data) => data,
    Failure() => fallback,
  };

  // ---------------------------------------------------------------------------
  // Transformations
  // ---------------------------------------------------------------------------

  /// Transforms the success value without affecting failures.
  Result<U> map<U>(U Function(T data) transform) => switch (this) {
    Success(:final data) => Success(transform(data)),
    Failure(:final exception) => Failure(exception),
  };

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  /// Calls [success] with the value or [failure] with the exception and returns
  /// the result. Both branches must return the same type [R].
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) => switch (this) {
    Success(:final data) => success(data),
    Failure(:final exception) => failure(exception),
  };
}

// ---------------------------------------------------------------------------
// Concrete variants
// ---------------------------------------------------------------------------

/// Represents a successful [Result] holding a value of type [T].
final class Success<T> extends Result<T> {
  const Success(this.data);

  /// The successfully returned value.
  final T data;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed [Result] holding a structured [AppException].
final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  /// The structured exception describing why the operation failed.
  final AppException exception;

  @override
  String toString() => 'Failure(${exception.toString()})';
}
