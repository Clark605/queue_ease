import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';
import 'package:queue_ease/features/shared_domain/models/working_hours_model.dart';

@lazySingleton
class CustomerWorkingHoursDatasource {
  CustomerWorkingHoursDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) {
    _logger.debug(
      'CustomerWorkingHoursDatasource: watchWorkingHours → orgId=$orgId',
    );
    return _firestore
        .collection('organizations/$orgId/working_hours')
        .snapshots()
        .map(
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
}
