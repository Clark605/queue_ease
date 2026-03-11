import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/data/models/working_hours_model.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';

@lazySingleton
class AdminWorkingHoursDatasource {
  AdminWorkingHoursDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _collection(String orgId) =>
      _firestore.collection('organizations/$orgId/working_hours');

  Future<void> saveAll(String orgId, List<WorkingHoursEntity> days) async {
    _logger.debug(
      'AdminWorkingHoursDatasource: saveAll → orgId=$orgId, days=${days.length}',
    );
    try {
      final batch = _firestore.batch();
      for (final entity in days) {
        final docRef = _collection(orgId).doc(entity.dayOfWeek.toString());
        batch.update(docRef, {
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
        });
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
