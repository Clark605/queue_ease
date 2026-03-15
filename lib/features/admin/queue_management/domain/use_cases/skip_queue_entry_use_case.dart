import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Moves the current queue entry to the end of the waiting list.
///
/// Transitions the appointment status from [AppointmentStatus.serving] back
/// to [AppointmentStatus.inQueue] in an atomic Firestore transaction.
@injectable
class SkipQueueEntryUseCase {
  const SkipQueueEntryUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    _logger.info('SkipQueueEntryUseCase', 'Skipping entry for $orgId on $date');
    return _repository.skip(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }
}
