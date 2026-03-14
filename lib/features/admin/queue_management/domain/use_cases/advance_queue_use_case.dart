import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Marks the current queue entry as completed and promotes the next entry.
///
/// Executes an atomic Firestore transaction for safe, idempotent advancement.
/// Implementation is added in Phase 3 (T015).
@injectable
class AdvanceQueueUseCase {
  const AdvanceQueueUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  // TODO(T015): Implement call() — returns Future<Result<void>>.
}
