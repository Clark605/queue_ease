import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/data/models/organization_model.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';

@lazySingleton
class AdminOrganizationDatasource {
  AdminOrganizationDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _orgs =>
      _firestore.collection('organizations');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<OrganizationEntity> create({
    required String adminUid,
    required String name,
  }) async {
    _logger.debug(
      'AdminOrganizationDatasource: create → adminUid=$adminUid name=$name',
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
        'AdminOrganizationDatasource: org created id=${orgRef.id} '
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
        'AdminOrganizationDatasource: create failed adminUid=$adminUid',
        e,
        st,
      );
      throw DatabaseException('Failed to create organization.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'AdminOrganizationDatasource: create unexpected error adminUid=$adminUid',
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

  Future<void> update(OrganizationEntity organization) async {
    _logger.debug(
      'AdminOrganizationDatasource: update → orgId=${organization.id}',
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
        'AdminOrganizationDatasource: org updated id=${organization.id}',
      );
    } on FirebaseException catch (e, st) {
      _logger.error(
        'AdminOrganizationDatasource: update failed orgId=${organization.id}',
        e,
        st,
      );
      throw DatabaseException('Failed to update organization.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'AdminOrganizationDatasource: update unexpected error '
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

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
