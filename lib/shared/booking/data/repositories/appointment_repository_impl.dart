import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/firestore_appointment_datasource.dart';

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl(this._datasource);

  final FirestoreAppointmentDatasource _datasource;

  @override
  Future<Result<AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  ) => Result.guard(
    () => _datasource.createAppointmentTransactional(appointment),
  );

  @override
  Future<Result<List<AppointmentEntity>>> getAppointmentsForDateAndService({
    required String orgId,
    required String serviceId,
    required DateTime date,
  }) => Result.guard(
    () => _datasource.getAppointmentsForDateAndService(
      orgId: orgId,
      serviceId: serviceId,
      date: date,
    ),
  );
}
