import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

/// Domain contract for admin appointment operations in the queue.
///
/// Covers real-time queue display, status updates, and position management.
abstract class AdminAppointmentRepository {
  /// Watches all appointments for [orgId] on [date] in real time.
  Stream<List<AppointmentEntity>> watchAppointmentsByDate({
    required String orgId,
    required DateTime date,
  });

  /// Updates the status of a single appointment.
  Future<Result<void>> updateAppointmentStatus({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus status,
  });
}
