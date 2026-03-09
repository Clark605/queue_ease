import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

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
  }) async {
    _logger.debug('FirestoreUserDatasource: createOrGet → uid=$uid');
    try {
      final doc = await _users.doc(uid).get();

      if (doc.exists) {
        _logger.debug('FirestoreUserDatasource: existing user found uid=$uid');
        return _fromDoc(doc);
      }

      final model = UserModel(
        uid: uid,
        email: email ?? '',
        role: role ?? UserRole.customer,
        displayName: displayName,
        phone: phone,
      );

      await _users.doc(uid).set(model.toJson());
      _logger.info(
        'FirestoreUserDatasource: new user profile created uid=$uid',
      );

      return model.toEntity();
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
      _logger.error('FirestoreUserDatasource: getUser failed uid=$uid', e, st);
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

  /// Updates the [organizationId] field on the user document for [uid].
  ///
  /// Called atomically inside [FirestoreOrganizationDatasource.create]'s
  /// [WriteBatch]; may also be called standalone during missing-org recovery.
  Future<void> updateOrganizationId(String uid, String organizationId) async {
    _logger.debug(
      'FirestoreUserDatasource: updateOrganizationId → uid=$uid '
      'orgId=$organizationId',
    );
    try {
      await _users.doc(uid).update({'organizationId': organizationId});
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: updateOrganizationId failed uid=$uid',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to link organization to user profile.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: updateOrganizationId unexpected error uid=$uid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while updating user profile.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Marks the first-time tutorial as completed for [uid].
  Future<void> markTutorialCompleted(String uid) async {
    _logger.debug('FirestoreUserDatasource: markTutorialCompleted → uid=$uid');
    try {
      await _users.doc(uid).update({'tutorialCompleted': true});
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: markTutorialCompleted failed uid=$uid',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to update tutorial status.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'FirestoreUserDatasource: markTutorialCompleted unexpected uid=$uid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while saving tutorial progress.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  UserEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromFirestore(doc).toEntity();
  }
}
