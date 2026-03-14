import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Watches the daily queue snapshot in real time for the admin UI.
///
/// Streams an [AdminQueueSnapshot] as the queue document and appointment
/// statuses change. Implementation is added in Phase 3 (T015).
@injectable
class WatchDailyQueueUseCase {
  const WatchDailyQueueUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  // TODO(T015): Implement call() — returns Stream<Result<AdminQueueSnapshot>>.
}
