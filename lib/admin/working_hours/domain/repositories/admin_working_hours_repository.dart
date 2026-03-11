import '../../../../core/error/result.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';

/// Domain contract for admin-only working hours write operations.
///
/// Read operations (watchWorkingHours) remain on the shared [WorkingHoursRepository].
abstract class AdminWorkingHoursRepository {
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
