import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/organization_entity.dart';
import '../models/organization_model.dart';

/// Reads organization documents at `organizations/{orgId}`.
///
/// Write operations are handled by [AdminOrganizationDatasource] in the admin layer.
@lazySingleton
class FirestoreOrganizationDatasource {
  FirestoreOrganizationDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _orgs =>
      _firestore.collection('organizations');

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
}
