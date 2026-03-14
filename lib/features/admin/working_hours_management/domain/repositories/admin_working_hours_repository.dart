import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

/// Domain contract for admin working hours — real-time watch and write.
abstract class AdminWorkingHoursRepository {
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);

  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
