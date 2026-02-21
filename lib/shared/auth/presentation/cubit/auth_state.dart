import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// Initial state — emitted before [AuthCubit.initialize] is called.
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while an async auth operation is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted when a user successfully authenticates.
final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Emitted when no user session is active (sign-out or no stored session).
final class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

/// Emitted when a sign-in / sign-up / sign-out operation fails.
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when a password reset email was successfully sent.
final class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
