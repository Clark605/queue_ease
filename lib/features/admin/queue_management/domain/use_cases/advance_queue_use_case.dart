import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Marks the current queue entry as completed and promotes the next entry.
///
/// Executes an atomic Firestore transaction for safe, idempotent advancement.
@injectable
class AdvanceQueueUseCase {
  const AdvanceQueueUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    _logger.info('AdvanceQueueUseCase', 'Advancing queue for $orgId on $date');
    return _repository.next(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }
}
