import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';
import 'package:queue_ease/features/shared_domain/models/working_hours_model.dart';

@lazySingleton
class AdminWorkingHoursDatasource {
  AdminWorkingHoursDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _collection(String orgId) =>
      _firestore.collection('organizations/$orgId/working_hours');

  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) {
    _logger.debug(
      'AdminWorkingHoursDatasource: watchWorkingHours → orgId=$orgId',
    );
    return _collection(orgId).snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) =>
                    WorkingHoursModel.fromDoc(doc, orgId: orgId).toEntity(),
              )
              .toList()
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek)),
    );
  }

  Future<void> saveAll(String orgId, List<WorkingHoursEntity> days) async {
    _logger.debug(
      'AdminWorkingHoursDatasource: saveAll → orgId=$orgId, days=${days.length}',
    );
    try {
      final batch = _firestore.batch();
      for (final entity in days) {
        final docRef = _collection(orgId).doc(entity.dayOfWeek.toString());
        batch.set(
          docRef,
          {
            ...WorkingHoursModel(
              orgId: entity.orgId,
              dayOfWeek: entity.dayOfWeek,
              isOpen: entity.isOpen,
              openTime: entity.openTime,
              closeTime: entity.closeTime,
              breakStart: entity.breakStart,
              breakEnd: entity.breakEnd,
            ).toMap(),
            'dayOfWeek': entity.dayOfWeek,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } on FirebaseException catch (e, st) {
      _logger.error('AdminWorkingHoursDatasource: saveAll failed', e, st);
      throw DatabaseException('Failed to save working hours.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'AdminWorkingHoursDatasource: saveAll unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'Unexpected error saving working hours.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
