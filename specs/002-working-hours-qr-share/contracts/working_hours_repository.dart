// ignore: dangling_library_doc_comments
/// Contract: WorkingHoursRepository
///
/// Abstract repository interface for working hours data operations.
/// Defined in the domain layer — zero external dependencies.
/// Implemented by WorkingHoursRepositoryImpl in the data layer.
///
/// FILE: lib/shared/organization/domain/repositories/working_hours_repository.dart

import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

abstract class WorkingHoursRepository {
  /// Returns a live stream of all 7 working hours documents for the given
  /// organization, sorted by [WorkingHoursEntity.dayOfWeek] (Monday first).
  ///
  /// On first emission for a new organization (no documents exist), the
  /// datasource initializes default working hours and the stream emits
  /// the defaults immediately.
  ///
  /// Errors are propagated via [onError] on the stream — the caller is
  /// responsible for handling via StreamSubscription.onError.
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);

  /// Validates and persists all 7 working hours documents as an atomic
  /// batch write.
  ///
  /// Validation rules (enforced before any write):
  /// - For each open day: closeTime must be strictly after openTime
  /// - If breakStart/breakEnd set: both must be present, break must fall
  ///   within open window, and breakEnd must be after breakStart
  ///
  /// Returns [Failure<ValidationException>] if any day fails validation.
  /// Returns [Failure<DatabaseException>] if the Firestore write fails.
  /// Returns [Success<void>] if all 7 documents are written successfully.
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
