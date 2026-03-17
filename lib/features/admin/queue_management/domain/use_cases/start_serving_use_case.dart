import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Explicitly marks the current front queue entry as serving.
@injectable
class StartServingUseCase {
  const StartServingUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    _logger.info('StartServingUseCase', 'Starting service for $orgId on $date');
    return _repository.startServing(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }
}
