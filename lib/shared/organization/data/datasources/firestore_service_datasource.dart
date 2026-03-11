import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service_entity.dart';
import '../models/service_model.dart';

/// Reads service documents at `organizations/{orgId}/services/{serviceId}`.
///
/// Write operations are handled by [AdminServiceDatasource] in the admin layer.
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
}
