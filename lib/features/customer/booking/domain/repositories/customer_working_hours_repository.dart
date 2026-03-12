import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

/// Domain contract for customer read-only access to working hours.
abstract class CustomerWorkingHoursRepository {
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);
}
