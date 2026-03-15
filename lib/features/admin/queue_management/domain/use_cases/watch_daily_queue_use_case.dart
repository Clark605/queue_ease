import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Watches the daily queue snapshot in real time for the admin UI.
///
/// Streams an [AdminQueueSnapshot] as the queue document and appointment
/// statuses change.
@injectable
class WatchDailyQueueUseCase {
  const WatchDailyQueueUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Stream<Result<AdminQueueSnapshot>> call({
    required String orgId,
    required DateTime date,
  }) {
    _logger.info(
      'WatchDailyQueueUseCase',
      'Watching daily queue for $orgId on $date',
    );
    return _repository.watchDailyQueue(orgId: orgId, date: date);
  }
}
