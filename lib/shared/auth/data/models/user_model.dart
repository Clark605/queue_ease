import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// Data layer representation of a user with JSON serialization capabilities.
///
/// This is separate from [UserEntity] to maintain clear separation between
/// data and domain layers. Use [toEntity] to convert to domain entity.
class UserModel extends Equatable {
  const UserModel({
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
  final String? phone;
  final String? organizationId;
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

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Document data is null for uid: ${doc.id}');
    }

    return UserModel.fromJson(data, uid: doc.id);
  }

  /// Creates a [UserModel] from a JSON map.
  ///
  /// Optional [uid] parameter allows overriding the uid from the document ID
  /// (useful when the uid is stored as the document key rather than a field).
  factory UserModel.fromJson(Map<String, dynamic> json, {String? uid}) {
    // Parse role from string, default to customer if invalid
    final roleValue = json['role'] as String?;
    final role = roleValue != null
        ? UserRole.values.firstWhere(
            (r) => r.name == roleValue,
            orElse: () => UserRole.customer,
          )
        : UserRole.customer;

    return UserModel(
      uid: uid ?? json['uid'] as String,
      email: json['email'] as String? ?? '',
      role: role,
      displayName: json['displayName'] as String?,
      phone: json['phone'] as String?,
      organizationId: json['organizationId'] as String?,
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
    );
  }

  /// Creates a [UserModel] from a Firebase Auth [User].
  ///
  /// This is useful for initial user creation before Firestore profile exists.
  /// Defaults to [UserRole.customer] and does not include extended profile data.
  factory UserModel.fromFirebaseUser(
    User firebaseUser, {
    UserRole? role,
    String? phone,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: role ?? UserRole.customer,
      displayName: firebaseUser.displayName,
      phone: phone,
    );
  }

  /// Converts this model to a JSON map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role.name,
      'displayName': displayName,
      'phone': phone,
      'organizationId': organizationId,
      'tutorialCompleted': tutorialCompleted,
    };
  }

  /// Creates a copy of this model with updated fields.
  UserModel copyWith({
    String? uid,
    String? email,
    UserRole? role,
    String? displayName,
    String? phone,
    String? organizationId,
    bool? tutorialCompleted,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      organizationId: organizationId ?? this.organizationId,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
    );
  }

  /// Converts this model to a domain [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName,
      phone: phone,
      organizationId: organizationId,
      tutorialCompleted: tutorialCompleted,
    );
  }

  /// Creates a [UserModel] from a domain [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      role: entity.role,
      displayName: entity.displayName,
      phone: entity.phone,
      organizationId: entity.organizationId,
      tutorialCompleted: entity.tutorialCompleted,
    );
  }
}
