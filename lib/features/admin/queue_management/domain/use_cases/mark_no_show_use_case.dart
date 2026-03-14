import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Marks the current queue entry as a no-show and promotes the next entry.
///
/// Transitions the appointment status to [AppointmentStatus.noShow] in an
/// atomic Firestore transaction.
@injectable
class MarkNoShowUseCase {
  const MarkNoShowUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    _logger.info('MarkNoShowUseCase', 'Marking no-show for $orgId on $date');
    return _repository.markNoShow(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }
}
