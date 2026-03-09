import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/organization_entity.dart';
import '../models/organization_model.dart';

/// Reads and writes organization documents at `organizations/{orgId}`.
@lazySingleton
class FirestoreOrganizationDatasource {
  FirestoreOrganizationDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _orgs =>
      _firestore.collection('organizations');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Creates a new organization document and atomically links it to the
  /// admin's user profile via a [WriteBatch].
  ///
  /// The batch writes:
  /// 1. `organizations/{orgId}` — the new organization document.
  /// 2. `users/{adminUid}.organizationId` — links the admin to this org.
  Future<OrganizationEntity> create({
    required String adminUid,
    required String name,
  }) async {
    _logger.debug(
      'FirestoreOrganizationDatasource: create → adminUid=$adminUid name=$name',
    );
    try {
      final orgRef = _orgs.doc();
      final slug = _generateSlug(name);
      final now = DateTime.now();

      final model = OrganizationModel(
        id: orgRef.id,
        name: name.trim(),
        adminUid: adminUid,
        bookingLinkSlug: slug,
        isOpen: false,
        createdAt: now,
      );

      final batch = _firestore.batch();
      batch.set(orgRef, {
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(_users.doc(adminUid), {'organizationId': orgRef.id});

      await batch.commit();

      _logger.info(
        'FirestoreOrganizationDatasource: org created id=${orgRef.id} '
        'slug=$slug adminUid=$adminUid',
      );

      return OrganizationModel(
        id: orgRef.id,
        name: name.trim(),
        adminUid: adminUid,
        bookingLinkSlug: slug,
        isOpen: false,
        createdAt: now,
      ).toEntity();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: create failed adminUid=$adminUid',
        e,
        st,
      );
      throw DatabaseException('Failed to create organization.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: create unexpected error '
        'adminUid=$adminUid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while creating the organization.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns a real-time stream of the organization document for [orgId].
  Stream<OrganizationEntity> watchById(String orgId) {
    _logger.debug('FirestoreOrganizationDatasource: watchById → orgId=$orgId');
    return _orgs.doc(orgId).snapshots().map((snap) {
      if (!snap.exists) {
        throw DatabaseException('Organization not found: $orgId');
      }
      return OrganizationModel.fromDoc(snap).toEntity();
    });
  }

  /// Updates the mutable fields of an existing organization document.
  Future<void> update(OrganizationEntity organization) async {
    _logger.debug(
      'FirestoreOrganizationDatasource: update → orgId=${organization.id}',
    );
    try {
      await _orgs.doc(organization.id).update({
        'name': organization.name,
        'address': organization.address,
        'description': organization.description,
        'logoUrl': organization.logoUrl,
        'isOpen': organization.isOpen,
      });
      _logger.info(
        'FirestoreOrganizationDatasource: org updated id=${organization.id}',
      );
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: update failed '
        'orgId=${organization.id}',
        e,
        st,
      );
      throw DatabaseException('Failed to update organization.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: update unexpected error '
        'orgId=${organization.id}',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while updating the organization.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Returns the organization owned by [adminUid], or `null` if none exists.
  Future<OrganizationEntity?> getByAdminUid(String adminUid) async {
    _logger.debug(
      'FirestoreOrganizationDatasource: getByAdminUid → adminUid=$adminUid',
    );
    try {
      final query = await _orgs
          .where('adminUid', isEqualTo: adminUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _logger.debug(
          'FirestoreOrganizationDatasource: no org found for '
          'adminUid=$adminUid',
        );
        return null;
      }
      return OrganizationModel.fromDoc(query.docs.first).toEntity();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: getByAdminUid failed '
        'adminUid=$adminUid',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to retrieve organization.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'FirestoreOrganizationDatasource: getByAdminUid unexpected error '
        'adminUid=$adminUid',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while retrieving the organization.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Generates a URL-safe booking link slug from [name].
  ///
  /// Format: `{sanitized-name}-{6-char-random-alphanum}`
  /// Example: `"Sunrise Clinic & Spa"` → `"sunrise-clinic-spa-a3x9kp"`
  String _generateSlug(String name) {
    var sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50).replaceAll(RegExp(r'-$'), '');
    }

    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    final suffix = List.generate(
      6,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();

    return '$sanitized-$suffix';
  }
}
