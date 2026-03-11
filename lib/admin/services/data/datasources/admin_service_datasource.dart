import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/data/models/service_model.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';

@lazySingleton
class AdminServiceDatasource {
  AdminServiceDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

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
      throw DatabaseException(
        'Failed to create service: ${e.message}',
        stackTrace: st,
      );
    }
  }

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
      throw DatabaseException(
        'Failed to update service: ${e.message}',
        stackTrace: st,
      );
    }
  }

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
      throw DatabaseException(
        'Failed to delete service: ${e.message}',
        stackTrace: st,
      );
    }
  }
}
