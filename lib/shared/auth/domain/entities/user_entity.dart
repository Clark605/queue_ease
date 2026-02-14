import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, role, displayName];
}
