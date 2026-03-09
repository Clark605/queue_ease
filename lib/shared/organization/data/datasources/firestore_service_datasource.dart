import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service_entity.dart';
import '../models/service_model.dart';

/// Reads and writes service documents at
/// `organizations/{orgId}/services/{serviceId}`.
@lazySingleton
class FirestoreServiceDatasource {
  FirestoreServiceDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

  /// Returns a real-time stream of all services under [orgId], ordered
  /// by [createdAt] ascending.
  Stream<List<ServiceEntity>> watchServices(String orgId) {
    _logger.debug('FirestoreServiceDatasource: watchServices → orgId=$orgId');
    return _services(orgId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ServiceModel.fromDoc(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  orgId: orgId,
                ).toEntity(),
              )
              .toList(),
        );
  }

  /// Creates a new service document under [service.orgId].
  ///
  /// The Firestore document ID is auto-generated.
  /// [createdAt] is written as a server timestamp.
  Future<ServiceEntity> create(ServiceEntity service) async {
    _logger.debug('FirestoreServiceDatasource: create → name=${service.name}');
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

  /// Updates all mutable fields of an existing service document.
  ///
  /// Preserves [createdAt] and [orgId].
  Future<void> update(ServiceEntity service) async {
    _logger.debug(
      'FirestoreServiceDatasource: update → serviceId=${service.id}',
    );
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

  /// Permanently deletes the service document at
  /// `organizations/{orgId}/services/{serviceId}`.
  Future<void> delete({
    required String orgId,
    required String serviceId,
  }) async {
    _logger.debug(
      'FirestoreServiceDatasource: delete → orgId=$orgId serviceId=$serviceId',
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
