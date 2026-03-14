import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Re-admits a previously skipped appointment by appending it to the queue end.
///
/// This is an explicit admin action to give a skipped customer another turn.
/// Executes an atomic Firestore transaction.
/// Implementation is added in Phase 3 (T015).
@injectable
class RejoinSkippedUseCase {
  const RejoinSkippedUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  // TODO(T015): Implement call() — returns Future<Result<void>>.
}
