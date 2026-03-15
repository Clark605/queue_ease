import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../repositories/admin_appointment_repository.dart';

/// Generates (or idempotently refreshes) the daily queue from eligible
/// appointments (`status == booked`) ordered by `scheduledAt ASC`.
///
/// Running this multiple times for the same org/date is safe — only new
/// `booked` appointments are appended; existing queue order is preserved.
@injectable
class GenerateDailyQueueUseCase {
  const GenerateDailyQueueUseCase(this._repository, this._logger);

  final AdminAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({required String orgId, required DateTime date}) {
    _logger.info(
      'GenerateDailyQueueUseCase',
      'Generating daily queue for $orgId on $date',
    );
    return _repository.generateDailyQueue(orgId: orgId, date: date);
  }
}
