import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Marks the current queue entry as a no-show and promotes the next entry.
///
/// Transitions the appointment status to [AppointmentStatus.noShow] in an
/// atomic Firestore transaction. Implementation is added in Phase 3 (T015).
@injectable
class MarkNoShowUseCase {
  const MarkNoShowUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  // TODO(T015): Implement call() — returns Future<Result<void>>.
}
