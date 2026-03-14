import 'package:injectable/injectable.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

import '../../domain/repositories/customer_working_hours_repository.dart';
import '../datasources/customer_working_hours_datasource.dart';

@LazySingleton(as: CustomerWorkingHoursRepository)
class CustomerWorkingHoursRepositoryImpl
    implements CustomerWorkingHoursRepository {
  CustomerWorkingHoursRepositoryImpl(this._datasource);

  final CustomerWorkingHoursDatasource _datasource;

  @override
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) =>
      _datasource.watchWorkingHours(orgId);
}
