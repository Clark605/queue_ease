import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/error/app_exception.dart';

void main() {
  group('AppException subtypes', () {
    group('AuthException', () {
      test('stores message and optional code', () {
        const e = AuthException('Sign-in failed', code: 'wrong-password');
        expect(e.message, 'Sign-in failed');
        expect(e.code, 'wrong-password');
        expect(e.stackTrace, isNull);
      });

      test('fromFirebase maps known codes to readable messages', () {
        final known = {
          'user-not-found': 'No account found for this email address.',
          'wrong-password': 'Incorrect password. Please try again.',
          'email-already-in-use': 'An account with this email already exists.',
          'weak-password':
              'Password is too weak. Please choose a stronger one.',
          'invalid-email': 'The email address is not valid.',
          'user-disabled':
              'This account has been disabled. Please contact support.',
          'too-many-requests':
              'Too many attempts. Please wait a moment and try again.',
          'network-request-failed':
              'No internet connection. Please check your network.',
          'operation-not-allowed':
              'This sign-in method is not enabled. Please contact support.',
          'invalid-credential':
              'Invalid credentials. Please check your email and password.',
        };

        for (final entry in known.entries) {
          final e = AuthException.fromFirebase(entry.key);
          expect(e.message, entry.value, reason: 'code: ${entry.key}');
          expect(e.code, entry.key);
        }
      });

      test('fromFirebase falls back for unknown code', () {
        final e = AuthException.fromFirebase('some-unknown-code');
        expect(e.message, 'Authentication failed (some-unknown-code).');
        expect(e.code, 'some-unknown-code');
      });

      test('toString includes code and message', () {
        const e = AuthException('msg', code: 'bad-code');
        expect(e.toString(), contains('bad-code'));
        expect(e.toString(), contains('msg'));
      });
    });

    group('DatabaseException', () {
      test('stores message', () {
        const e = DatabaseException('Firestore read failed');
        expect(e.message, 'Firestore read failed');
      });
    });

    group('StorageException', () {
      test('stores message', () {
        const e = StorageException('SharedPrefs write failed');
        expect(e.message, 'SharedPrefs write failed');
      });
    });

    group('ValidationException', () {
      test('stores message and optional field', () {
        const e = ValidationException('Email is required', field: 'email');
        expect(e.message, 'Email is required');
        expect(e.field, 'email');
      });

      test('field is nullable', () {
        const e = ValidationException('Invalid input');
        expect(e.field, isNull);
      });

      test('toString includes field and message', () {
        const e = ValidationException('Required', field: 'phone');
        expect(e.toString(), contains('phone'));
        expect(e.toString(), contains('Required'));
      });
    });

    group('UnknownException', () {
      test('stores message and optional cause', () {
        final cause = Exception('original');
        final e = UnknownException('Unexpected error', cause: cause);
        expect(e.message, 'Unexpected error');
        expect(e.cause, cause);
      });

      test('toString includes cause and message', () {
        final e = UnknownException('boom', cause: 'root cause');
        expect(e.toString(), contains('root cause'));
        expect(e.toString(), contains('boom'));
      });
    });
  });
}
