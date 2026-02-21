import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_entity.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_role.dart';
import 'package:queue_ease/shared/auth/domain/repositories/auth_repository.dart';
import 'package:queue_ease/shared/auth/presentation/cubit/auth_cubit.dart';
import 'package:queue_ease/shared/auth/presentation/cubit/auth_state.dart';

// ignore_for_file: discarded_futures

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockAuthRepository mockRepo;
  late MockAppLogger mockLogger;

  const tUser = UserEntity(
    uid: 'uid-1',
    email: 'test@example.com',
    role: UserRole.customer,
    displayName: 'Test User',
  );

  // Register fallback values for mocktail before all tests
  setUpAll(() {
    registerFallbackValue(UserRole.customer);
  });

  setUp(() {
    mockRepo = MockAuthRepository();
    mockLogger = MockAppLogger();

    // Stub all logger methods to be no-ops in tests.
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.warning(any(), any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  // ── checkAuthStatus ──────────────────────────────────────────────────────

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when a session exists',
      build: () {
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => tUser);
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthLoading(), Authenticated(tUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] when no session exists',
      build: () {
        when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] on error',
      build: () {
        when(
          () => mockRepo.getCurrentUser(),
        ).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );
  });

  // ── signInWithEmailPassword ───────────────────────────────────────────────

  group('signInWithEmailPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      build: () {
        when(
          () => mockRepo.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [const AuthLoading(), Authenticated(tUser)],
      verify: (_) {
        verify(
          () => mockRepo.signInWithEmailPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on wrong credentials',
      build: () {
        when(
          () => mockRepo.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('Incorrect email or password.'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'wrong',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Incorrect email or password.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on unexpected error',
      build: () {
        when(
          () => mockRepo.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Something went wrong. Please try again.'),
      ],
    );
  });

  // ── signUpWithEmailPassword ───────────────────────────────────────────────

  group('signUpWithEmailPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      build: () {
        when(
          () => mockRepo.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            displayName: any(named: 'displayName'),
            phone: any(named: 'phone'),
            orgName: any(named: 'orgName'),
          ),
        ).thenAnswer((_) async => tUser);
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signUpWithEmailPassword(
        email: 'new@example.com',
        password: 'password123',
        role: UserRole.customer,
        displayName: 'New User',
        phone: '+1234567890',
      ),
      expect: () => [const AuthLoading(), Authenticated(tUser)],
      verify: (_) {
        verify(
          () => mockRepo.signUpWithEmailPassword(
            email: 'new@example.com',
            password: 'password123',
            role: UserRole.customer,
            displayName: 'New User',
            phone: '+1234567890',
            orgName: null,
          ),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when email already in use',
      build: () {
        when(
          () => mockRepo.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            displayName: any(named: 'displayName'),
            phone: any(named: 'phone'),
            orgName: any(named: 'orgName'),
          ),
        ).thenThrow(
          const AuthException('An account with this email already exists.'),
        );
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signUpWithEmailPassword(
        email: 'taken@example.com',
        password: 'password123',
        role: UserRole.customer,
        displayName: 'User',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('An account with this email already exists.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on unexpected error',
      build: () {
        when(
          () => mockRepo.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            displayName: any(named: 'displayName'),
            phone: any(named: 'phone'),
            orgName: any(named: 'orgName'),
          ),
        ).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signUpWithEmailPassword(
        email: 'new@example.com',
        password: 'password123',
        role: UserRole.customer,
        displayName: 'User',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Something went wrong. Please try again.'),
      ],
    );
  });

  // ── signInWithGoogle ──────────────────────────────────────────────────────

  group('signInWithGoogle', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      build: () {
        when(() => mockRepo.signInWithGoogle()).thenAnswer((_) async => tUser);
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [const AuthLoading(), Authenticated(tUser)],
      verify: (_) => verify(() => mockRepo.signInWithGoogle()).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when cancelled',
      build: () {
        when(
          () => mockRepo.signInWithGoogle(),
        ).thenThrow(const AuthException('Sign-in was cancelled.'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Sign-in was cancelled.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on unexpected error',
      build: () {
        when(
          () => mockRepo.signInWithGoogle(),
        ).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Something went wrong. Please try again.'),
      ],
    );
  });

  // ── signOut ───────────────────────────────────────────────────────────────

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] on success',
      build: () {
        when(() => mockRepo.signOut()).thenAnswer((_) async {});
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [const AuthLoading(), const Unauthenticated()],
      verify: (_) => verify(() => mockRepo.signOut()).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on network error',
      build: () {
        when(() => mockRepo.signOut()).thenThrow(
          const AuthException(
            'No internet connection. Please check your network.',
          ),
        );
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('No internet connection. Please check your network.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on unexpected error',
      build: () {
        when(() => mockRepo.signOut()).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Something went wrong. Please try again.'),
      ],
    );
  });

  // ── sendPasswordResetEmail ────────────────────────────────────────────────

  group('sendPasswordResetEmail', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, PasswordResetEmailSent] on success',
      build: () {
        when(
          () => mockRepo.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenAnswer((_) async {});
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.sendPasswordResetEmail(email: 'test@example.com'),
      expect: () => [
        const AuthLoading(),
        const PasswordResetEmailSent('test@example.com'),
      ],
      verify: (_) {
        verify(
          () => mockRepo.sendPasswordResetEmail(email: 'test@example.com'),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when user not found',
      build: () {
        when(
          () => mockRepo.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(
          const AuthException('No account found for this email address.'),
        );
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) =>
          cubit.sendPasswordResetEmail(email: 'nonexistent@example.com'),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('No account found for this email address.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid email',
      build: () {
        when(
          () => mockRepo.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(const AuthException('The email address is not valid.'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.sendPasswordResetEmail(email: 'invalid-email'),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('The email address is not valid.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] on unexpected error',
      build: () {
        when(
          () => mockRepo.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(Exception('Unexpected error'));
        return AuthCubit(mockRepo, mockLogger);
      },
      act: (cubit) => cubit.sendPasswordResetEmail(email: 'test@example.com'),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Failed to send reset email. Please try again.'),
      ],
    );
  });
}
