import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../../domain/repositories/working_hours_repository.dart';
import '../datasources/firestore_working_hours_datasource.dart';

@LazySingleton(as: WorkingHoursRepository)
class WorkingHoursRepositoryImpl implements WorkingHoursRepository {
  WorkingHoursRepositoryImpl(this._datasource, this._logger);

  final FirestoreWorkingHoursDatasource _datasource;
  final AppLogger _logger;

  @override
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) {
    _logger.debug('WorkingHoursRepository: watchWorkingHours → orgId=$orgId');
    return _datasource.watchWorkingHours(orgId);
  }
}
