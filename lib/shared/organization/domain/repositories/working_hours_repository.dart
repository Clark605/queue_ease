import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart';

abstract class WorkingHoursRepository {
  /// Returns a live stream of all 7 working hours documents for [orgId],
  /// sorted by [WorkingHoursEntity.dayOfWeek] ascending (Monday first).
  ///
  /// On first emission for a new organization the datasource initializes
  /// defaults and the stream emits them immediately.
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);

  /// Validates and persists all 7 working hours documents as an atomic
  /// batch write.
  ///
  /// Returns [Failure<ValidationException>] if any day fails validation.
  /// Returns [Failure<DatabaseException>] if the Firestore write fails.
  /// Returns [Success<void>] on success.
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
