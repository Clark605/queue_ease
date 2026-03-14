import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';

/// Domain contract for customer appointment operations.
///
/// Covers the customer booking flow: creating appointments
/// and querying existing ones to calculate available slots.
abstract class CustomerAppointmentRepository {
  /// Creates a new appointment with a pre-conflict-check.
  ///
  /// Returns the created [AppointmentEntity] with its generated ID.
  /// Throws [ValidationException] if the slot is already taken.
  Future<Result<AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  );

  /// Returns all active appointments for [orgId] + [serviceId] on [date].
  ///
  /// Used by [CalculateAvailableSlotsUseCase] to determine occupied slots.
  Future<Result<List<AppointmentEntity>>> getAppointmentsForDateAndService({
    required String orgId,
    required String serviceId,
    required DateTime date,
  });
}
