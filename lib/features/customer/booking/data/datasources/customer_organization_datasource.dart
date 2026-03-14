import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';
import '../../../../../features/shared_domain/models/organization_model.dart';

/// Read-only datasource for customer organization queries.
///
/// Customers only need to resolve booking link slugs. This datasource
/// contains no write operations or admin-specific queries.
@lazySingleton
class CustomerOrganizationDatasource {
  CustomerOrganizationDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _orgs =>
      _firestore.collection('organizations');

  /// Returns the organization matching [slug], or `null` if not found.
  Future<OrganizationEntity?> getBySlug(String slug) async {
    _logger.debug('CustomerOrganizationDatasource: getBySlug → slug=$slug');
    try {
      final query = await _orgs
          .where('bookingLinkSlug', isEqualTo: slug.toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _logger.debug(
          'CustomerOrganizationDatasource: no org found for slug=$slug',
        );
        return null;
      }
      return OrganizationModel.fromDoc(query.docs.first).toEntity();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'CustomerOrganizationDatasource: getBySlug failed slug=$slug',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to retrieve organization.',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'CustomerOrganizationDatasource: getBySlug unexpected error '
        'slug=$slug',
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
