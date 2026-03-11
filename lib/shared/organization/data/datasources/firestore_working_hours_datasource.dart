import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../models/working_hours_model.dart';

/// Reads working hours documents at `organizations/{orgId}/working_hours`.
///
/// Write operations are handled by [AdminWorkingHoursDatasource] in the admin layer.
@lazySingleton
class FirestoreWorkingHoursDatasource {
  FirestoreWorkingHoursDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _collection(String orgId) =>
      _firestore.collection('organizations/$orgId/working_hours');

  Stream<List<WorkingHoursEntity>> watchWorkingHours(
    String orgId,
  ) => _collection(orgId).orderBy(FieldPath.documentId).snapshots().asyncMap((
    snapshot,
  ) async {
    if (snapshot.docs.isEmpty) {
      _logger.info(
        'FirestoreWorkingHoursDatasource: initializing defaults → orgId=$orgId',
      );
      await _initializeDefaults(orgId);
      return _defaultEntities(orgId);
    }
    return snapshot.docs
        .map(
          (doc) => WorkingHoursModel.fromDoc(
            doc as DocumentSnapshot<Map<String, dynamic>>,
            orgId: orgId,
          ).toEntity(),
        )
        .toList();
  });

  Future<void> _initializeDefaults(String orgId) async {
    final batch = _firestore.batch();
    for (final entity in _defaultEntities(orgId)) {
      final docRef = _collection(orgId).doc(entity.dayOfWeek.toString());
      batch.set(docRef, {
        'orgId': entity.orgId,
        'dayOfWeek': entity.dayOfWeek,
        'isOpen': entity.isOpen,
        'openTime': entity.openTime,
        'closeTime': entity.closeTime,
        'breakStart': entity.breakStart,
        'breakEnd': entity.breakEnd,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  List<WorkingHoursEntity> _defaultEntities(String orgId) => List.generate(
    7,
    (i) => WorkingHoursEntity(
      orgId: orgId,
      dayOfWeek: i,
      isOpen: i < 5, // Mon–Fri open, Sat–Sun closed
      openTime: '09:00',
      closeTime: '17:00',
    ),
  );
}
