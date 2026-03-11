import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart';

/// Domain contract for shared (read-only) working hours data operations.
///
/// Write operations are handled by [AdminWorkingHoursRepository] in the admin layer.
abstract class WorkingHoursRepository {
  /// Returns a live stream of all 7 working hours documents for [orgId],
  /// sorted by [WorkingHoursEntity.dayOfWeek] ascending (Monday first).
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);
}
