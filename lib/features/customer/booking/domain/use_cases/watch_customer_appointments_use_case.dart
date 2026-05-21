import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../repositories/customer_appointment_repository.dart';

@injectable
class WatchCustomerAppointmentsUseCase {
  const WatchCustomerAppointmentsUseCase(this._repository, this._logger);

  final CustomerAppointmentRepository _repository;
  final AppLogger _logger;

  Stream<Result<List<AppointmentEntity>>> call({
    required String customerId,
    required DateTime date,
  }) {
    _logger.info(
      'WatchCustomerAppointmentsUseCase',
      'watching appointments customerId=${customerId.substring(0, 4)}...',
    );
    return _repository.watchCustomerAppointments(
      customerId: customerId,
      date: date,
    );
  }
}
