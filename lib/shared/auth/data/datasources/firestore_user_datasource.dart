import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// Reads and writes user profile documents at `users/{uid}`.
@lazySingleton
class FirestoreUserDatasource {
  FirestoreUserDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Returns the existing profile for [uid], or creates one from the supplied
  /// fields if the document does not yet exist.
  ///
  /// Safe to call after every sign-in — no-ops for returning users.
  Future<UserEntity> createOrGet(
    String uid, {
    String? email,
    UserRole? role,
    String? displayName,
    String? phone,
    String? orgName,
  }) async {
    _logger.debug('FirestoreUserDatasource: createOrGet → uid=$uid');
    try {
      final doc = await _users.doc(uid).get();

      if (doc.exists) {
        _logger.debug('FirestoreUserDatasource: existing user found uid=$uid');
        return _fromDoc(doc);
      }

      final data = {
        'uid': uid,
        'email': email ?? '',
        'role': (role ?? UserRole.customer).name,
        if (displayName != null) 'displayName': displayName,
        if (phone != null) 'phone': phone,
        if (orgName != null) 'orgName': orgName,
      };
      await _users.doc(uid).set(data);
      _logger.info('FirestoreUserDatasource: new user profile created uid=$uid');

      return UserEntity(
        uid: uid,
        email: email ?? '',
        role: role ?? UserRole.customer,
        displayName: displayName,
        phone: phone,
        orgName: orgName,
      );
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: createOrGet failed uid=$uid',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to create or retrieve user profile.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: createOrGet unexpected error uid=$uid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while accessing user data.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Fetches a user profile by [uid]. Returns `null` if no document exists.
  Future<UserEntity?> getUser(String uid) async {
    _logger.debug('FirestoreUserDatasource: getUser → uid=$uid');
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) {
        _logger.debug('FirestoreUserDatasource: no profile found uid=$uid');
        return null;
      }
      return _fromDoc(doc);
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: getUser failed uid=$uid',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to retrieve user profile.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: getUser unexpected error uid=$uid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while fetching user data.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  UserEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final roleValue = data['role'] as String? ?? UserRole.customer.name;
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleValue,
      orElse: () => UserRole.customer,
    );
    return UserEntity(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: role,
      displayName: data['displayName'] as String?,
      phone: data['phone'] as String?,
      orgName: data['orgName'] as String?,
    );
  }
}
