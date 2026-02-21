import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages authentication state for the entire application.
///
/// [checkAuthStatus] must be called once from `main()` after
/// [configureDependencies] to restore any existing session on startup.
/// Action methods emit [AuthLoading] on start, then [Authenticated],
/// [Unauthenticated], or [AuthFailure] directly upon completion.
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository, this._logger) : super(const AuthInitial());

  final AuthRepository _authRepository;
  final AppLogger _logger;

  /// Checks for an existing Firebase session and emits the appropriate state.
  ///
  /// Called once from `main()` before [runApp]. Not called from the widget tree.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _logger.info('AuthCubit: restored session uid=${user.uid}');
        emit(Authenticated(user));
      } else {
        _logger.info('AuthCubit: no active session');
        emit(const Unauthenticated());
      }
    } catch (e, st) {
      _logger.error('AuthCubit: checkAuthStatus error', e, st);
      emit(const Unauthenticated());
    }
  }

  /// Signs in with email and password.
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _logger.info('AuthCubit: signInWithEmailPassword → $email');
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } on AppException catch (e, st) {
      _logger.warning('AuthCubit: signInWithEmailPassword failed', e, st);
      emit(AuthFailure(e.message));
    } catch (e, st) {
      _logger.error(
        'AuthCubit: signInWithEmailPassword unexpected error',
        e,
        st,
      );
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  /// Creates a new account and writes the profile to Firestore.
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
    String? phone,
    String? orgName,
  }) async {
    _logger.info(
      'AuthCubit: signUpWithEmailPassword → $email role=${role.name}',
    );
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email: email,
        password: password,
        role: role,
        displayName: displayName,
        phone: phone,
        orgName: orgName,
      );
      emit(Authenticated(user));
    } on AppException catch (e, st) {
      _logger.warning('AuthCubit: signUpWithEmailPassword failed', e, st);
      emit(AuthFailure(e.message));
    } catch (e, st) {
      _logger.error(
        'AuthCubit: signUpWithEmailPassword unexpected error',
        e,
        st,
      );
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  /// Signs in via Google OAuth.
  Future<void> signInWithGoogle() async {
    _logger.info('AuthCubit: signInWithGoogle');
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(Authenticated(user));
    } on AppException catch (e, st) {
      _logger.warning('AuthCubit: signInWithGoogle failed', e, st);
      emit(AuthFailure(e.message));
    } catch (e, st) {
      _logger.error('AuthCubit: signInWithGoogle unexpected error', e, st);
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  /// Signs out and clears the cached role.
  Future<void> signOut() async {
    _logger.info('AuthCubit: signOut');
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } on AppException catch (e, st) {
      _logger.warning('AuthCubit: signOut failed', e, st);
      emit(AuthFailure(e.message));
    } catch (e, st) {
      _logger.error('AuthCubit: signOut unexpected error', e, st);
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail({required String email}) async {
    _logger.info('AuthCubit: sendPasswordResetEmail → $email');
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      emit(PasswordResetEmailSent(email));
    } on AppException catch (e, st) {
      _logger.warning('AuthCubit: sendPasswordResetEmail failed', e, st);
      emit(AuthFailure(e.message));
    } catch (e, st) {
      _logger.error(
        'AuthCubit: sendPasswordResetEmail unexpected error',
        e,
        st,
      );
      emit(const AuthFailure('Failed to send reset email. Please try again.'));
    }
  }
}
