import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/config/flavor_config.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';

/// Wraps Firebase Auth and Google Sign-In primitives.
///
/// All credential-level operations live here; business logic stays in the
/// repository implementation.
///
/// [FirebaseAuthException] and other platform errors are mapped to
/// [AuthException] or [UnknownException] so callers only deal with
/// [AppException] subtypes.
@lazySingleton
class FirebaseAuthDatasource {
  FirebaseAuthDatasource(this._firebaseAuth, this._googleSignIn, this._logger);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final AppLogger _logger;

  /// Returns the currently signed-in [User], or `null` if no session exists.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _logger.debug('FirebaseAuthDatasource: signInWithEmailPassword → $email');
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, st) {
      _logger.warning(
        'FirebaseAuthDatasource: signInWithEmailPassword failed',
        e,
        st,
      );
      throw AuthException.fromFirebase(e.code, stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirebaseAuthDatasource: signInWithEmailPassword unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred during sign-in.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Creates a new Firebase account with email and password.
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _logger.debug('FirebaseAuthDatasource: signUpWithEmailPassword → $email');
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, st) {
      _logger.warning(
        'FirebaseAuthDatasource: signUpWithEmailPassword failed',
        e,
        st,
      );
      throw AuthException.fromFirebase(e.code, stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirebaseAuthDatasource: signUpWithEmailPassword unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred during sign-up.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Completes the Google OAuth flow and signs into Firebase.
  Future<UserCredential> signInWithGoogle() async {
    _logger.debug('FirebaseAuthDatasource: signInWithGoogle');
    try {
      _googleSignIn.initialize(
        serverClientId: FlavorConfig.instance.isDev
            ? '811891961988-id1hlr77r12pa9gbmfasq1giur2hfksc.apps.googleusercontent.com'
            : '836631105553-t6hclvu509p9vkst17klo6or6al91msv.apps.googleusercontent.com',
      );
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, st) {
      _logger.warning(
        'FirebaseAuthDatasource: signInWithGoogle Firebase failed',
        e,
        st,
      );
      throw AuthException.fromFirebase(e.code, stackTrace: st);
    } catch (e, st) {
      // Covers GoogleSignIn cancellation and other non-Firebase errors.
      final isCancelled = e.toString().toLowerCase().contains('cancel');
      if (isCancelled) {
        _logger.info('FirebaseAuthDatasource: Google sign-in cancelled');
        throw const AuthException('Sign-in was cancelled.');
      }
      _logger.error(
        'FirebaseAuthDatasource: signInWithGoogle unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred during Google sign-in.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Signs out from both Firebase and Google Sign-In.
  Future<void> signOut() async {
    _logger.debug('FirebaseAuthDatasource: signOut');
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e, st) {
      _logger.error('FirebaseAuthDatasource: signOut failed', e, st);
      throw UnknownException(
        'An unexpected error occurred during sign-out.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
