import '../../../../core/error/result.dart';
import '../entities/appointment_entity.dart';

/// Domain contract for appointment data operations.
///
/// Defined in the domain layer. Implemented in the data layer by
/// `AppointmentRepositoryImpl` backed by Firestore.
///
/// This contract covers the customer booking flow (Sprint 4).
/// Queue-related methods will be added in Sprint 5.
abstract class AppointmentRepository {
  /// Creates a new appointment using a Firestore transaction.
  ///
  /// The transaction re-checks for scheduling conflicts before committing.
  /// Returns the created [AppointmentEntity] with its generated ID.
  /// Throws [ValidationException] if a conflicting appointment exists.
  Future<Result<AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  );

  /// Returns all appointments for [orgId] + [serviceId] on [date].
  ///
  /// Used by the slot calculation use case to determine which time slots
  /// are already taken. Excludes appointments with status `noShow`.
  Future<Result<List<AppointmentEntity>>> getAppointmentsForDateAndService({
    required String orgId,
    required String serviceId,
    required DateTime date,
  });
}
