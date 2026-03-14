import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Moves the current queue entry to the end of the waiting list.
///
/// Transitions the appointment status from [AppointmentStatus.serving] back
/// to [AppointmentStatus.inQueue] in an atomic Firestore transaction.
/// Implementation is added in Phase 3 (T015).
@injectable
class SkipQueueEntryUseCase {
  const SkipQueueEntryUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  // TODO(T015): Implement call() — returns Future<Result<void>>.
}
