import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_entity.dart';

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

  // -- Queue status streams (Phase 4, T021/T022) ----------------------------

  @override
  Stream<Result<AppointmentEntity?>> watchCustomerQueueAppointment({
    required String orgId,
    required String customerId,
    required DateTime date,
  }) {
    // TODO(T021): Implement customer active-appointment watch in Phase 4 (US2).
    throw UnimplementedError('T021: Implement in Phase 4 (US2)');
  }

  @override
  Stream<Result<QueueEntity?>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    // TODO(T021): Implement daily queue document watch in Phase 4 (US2).
    throw UnimplementedError('T021: Implement in Phase 4 (US2)');
  }
}
