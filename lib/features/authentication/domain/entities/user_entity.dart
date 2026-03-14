import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.phone,
    this.organizationId,
    this.tutorialCompleted = false,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  /// Optional phone number (collected during sign-up).
  final String? phone;

  /// Reference to the [Organization] document owned by this admin account.
  /// `null` for customer accounts or admins who have not yet completed setup.
  final String? organizationId;

  /// Whether this admin has completed (or skipped) the first-time tutorial.
  /// Always `false` for customer accounts.
  final bool tutorialCompleted;

  @override
  List<Object?> get props => [
    uid,
    email,
    role,
    displayName,
    phone,
    organizationId,
    tutorialCompleted,
  ];
}
