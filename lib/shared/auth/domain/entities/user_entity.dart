import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.phone,
    this.orgName,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  /// Optional phone number (collected during sign-up).
  final String? phone;

  /// Optional organisation name for admin accounts.
  final String? orgName;

  @override
  List<Object?> get props => [uid, email, role, displayName, phone, orgName];
}
