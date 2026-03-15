import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Re-admits a previously skipped appointment by appending it to the queue end.
///
/// This is an explicit admin action to give a skipped customer another turn.
/// Executes an atomic Firestore transaction.
@injectable
class RejoinSkippedUseCase {
  const RejoinSkippedUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    _logger.info(
      'RejoinSkippedUseCase',
      'Rejoining skipped entry for $orgId on $date',
    );
    return _repository.rejoinSkipped(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }
}
