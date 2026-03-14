import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';
import '../../../../../features/shared_domain/models/service_model.dart';

/// Read-only datasource for customer service queries.
///
/// Customers only need to view active services. This datasource
/// contains no write operations or admin-specific queries.
@lazySingleton
class CustomerServiceDatasource {
  CustomerServiceDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

  /// Returns all active services for [orgId], ordered by name.
  Future<List<ServiceEntity>> getActiveServices(String orgId) async {
    _logger.debug(
      'CustomerServiceDatasource: getActiveServices → orgId=$orgId',
    );
    try {
      final snapshot = await _services(
        orgId,
      ).where('isActive', isEqualTo: true).orderBy('name').get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromDoc(doc, orgId: orgId).toEntity())
          .toList();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'CustomerServiceDatasource: getActiveServices failed orgId=$orgId',
        e,
        st,
      );
      throw DatabaseException('Failed to retrieve services.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'CustomerServiceDatasource: getActiveServices unexpected error '
        'orgId=$orgId',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while retrieving services.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
