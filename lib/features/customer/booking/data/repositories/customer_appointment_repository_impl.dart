import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';

import '../../domain/repositories/customer_appointment_repository.dart';
import '../datasources/customer_appointment_datasource.dart';

@LazySingleton(as: CustomerAppointmentRepository)
class CustomerAppointmentRepositoryImpl
    implements CustomerAppointmentRepository {
  const CustomerAppointmentRepositoryImpl(this._datasource);

  final CustomerAppointmentDatasource _datasource;

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
