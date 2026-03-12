import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';
import '../../../../../features/shared_domain/models/service_model.dart';

/// Unified datasource for ALL admin service Firestore operations.
///
/// Merges previous read-only queries with write operations into a single
/// cohesive datasource for the admin role.
@lazySingleton
class AdminServiceDatasource {
  AdminServiceDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

  // ---------------------------------------------------------------------------
  // Read Operations
  // ---------------------------------------------------------------------------

  /// Returns a real-time stream of all services for [orgId].
  Stream<List<ServiceEntity>> watchServices(String orgId) {
    _logger.debug('AdminServiceDatasource: watchServices → orgId=$orgId');
    return _services(orgId).orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromDoc(doc, orgId: orgId).toEntity())
          .toList();
    });
  }

  /// Returns all services for [orgId] as a snapshot.
  Future<List<ServiceEntity>> getServices(String orgId) async {
    _logger.debug('AdminServiceDatasource: getServices → orgId=$orgId');
    try {
      final snapshot = await _services(orgId).orderBy('name').get();
      return snapshot.docs
          .map((doc) => ServiceModel.fromDoc(doc, orgId: orgId).toEntity())
          .toList();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: getServices failed orgId=$orgId',
        e,
        st,
      );
      throw DatabaseException('Failed to retrieve services.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: getServices unexpected error orgId=$orgId',
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

  // ---------------------------------------------------------------------------
  // Write Operations
  // ---------------------------------------------------------------------------

  /// Creates a new service under [orgId].
  Future<ServiceEntity> create(ServiceEntity service) async {
    _logger.debug('AdminServiceDatasource: create → name=${service.name}');
    try {
      final ref = _services(service.orgId).doc();
      final model = ServiceModel(
        id: ref.id,
        orgId: service.orgId,
        name: service.name.trim(),
        durationMinutes: service.durationMinutes,
        timeMarginMinutes: service.timeMarginMinutes,
        isActive: service.isActive,
        createdAt: DateTime.now(),
        price: service.price,
        queueType: service.queueType,
        description: service.description,
      );
      await ref.set({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return model.toEntity();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: create failed orgId=${service.orgId}',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to create service: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: create unexpected error orgId=${service.orgId}',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while creating the service.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Updates an existing service.
  Future<void> update(ServiceEntity service) async {
    _logger.debug('AdminServiceDatasource: update → serviceId=${service.id}');
    try {
      await _services(service.orgId).doc(service.id).update({
        'name': service.name.trim(),
        'durationMinutes': service.durationMinutes,
        'timeMarginMinutes': service.timeMarginMinutes,
        'isActive': service.isActive,
        'price': service.price,
        'queueType': service.queueType,
        'description': service.description,
      });
    } on FirebaseException catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: update failed orgId=${service.orgId}',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to update service: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: update unexpected error orgId=${service.orgId}',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while updating the service.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Deletes a service by [serviceId].
  Future<void> delete({
    required String orgId,
    required String serviceId,
  }) async {
    _logger.debug(
      'AdminServiceDatasource: delete → orgId=$orgId serviceId=$serviceId',
    );
    try {
      await _services(orgId).doc(serviceId).delete();
    } on FirebaseException catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: delete failed orgId=$orgId serviceId=$serviceId',
        e,
        st,
      );
      throw DatabaseException(
        'Failed to delete service: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      _logger.error(
        'AdminServiceDatasource: delete unexpected error orgId=$orgId'
        ' serviceId=$serviceId',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while deleting the service.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
