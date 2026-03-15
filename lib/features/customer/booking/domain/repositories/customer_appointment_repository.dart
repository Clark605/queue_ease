import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_entity.dart';

/// Minimal queue appointment projection used for wait-time computation.
class QueueAppointmentWaitEntry {
  const QueueAppointmentWaitEntry({
    required this.appointmentId,
    required this.status,
    required this.serviceDurationMinutes,
  });

  final String appointmentId;
  final AppointmentStatus status;
  final int serviceDurationMinutes;
}

/// Domain contract for customer appointment operations.
///
/// Covers the customer booking flow (create + slot availability) and,
/// from Sprint 5 onwards, the live queue status streams required by
/// [WatchCustomerQueueStatusUseCase].
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

  // -- Queue status streams (Phase 4, T021/T022) ----------------------------

  /// Watches the customer's active appointment for [orgId] on [date].
  ///
  /// Returns the single appointment whose `customerId == [customerId]`
  /// and whose `status` is in `{booked, inQueue, serving, noShow}`, or `null` when none exists.
  /// Used by [WatchCustomerQueueStatusUseCase] to derive queue position and status.
  ///
  /// Note: "Active" includes appointments with status `booked`, `inQueue`, `serving`, or `noShow`
  /// for the given day. This matches the underlying data source behavior.
  Stream<Result<AppointmentEntity?>> watchCustomerQueueAppointment({
    required String orgId,
    required String customerId,
    required DateTime date,
  });

  /// Watches the daily queue document for [orgId] on [date].
  ///
  /// Returns the [QueueEntity] (containing `orderedAppointmentIds` and
  /// `currentServingIndex`), or `null` if no queue has been generated yet.
  /// Used by [WatchCustomerQueueStatusUseCase] to compute position.
  Stream<Result<QueueEntity?>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  });

  /// Watches queue-day appointments enriched with service durations.
  ///
  /// Used by customer queue status to compute deterministic wait estimates
  /// from entries ahead in the ordered queue.
  Stream<Result<List<QueueAppointmentWaitEntry>>>
  watchQueueAppointmentsForDate({
    required String orgId,
    required DateTime date,
  });

  // -- Dashboard streams (Phase 8, T045) ------------------------------------

  /// Watches the customer's dashboard appointments across orgs.
  ///
  /// Returns appointments with status in `{booked, inQueue, serving}`,
  /// ordered by [scheduledAt] ascending. `inQueue`/`serving` are today-only
  /// in practice; `booked` covers a 30-day horizon to include upcoming
  /// future appointments. Used by [WatchCustomerDashboardUseCase] to derive
  /// the active queue entry and the next upcoming booking.
  Stream<Result<List<AppointmentEntity>>> watchTodayActiveAppointments({
    required String customerId,
    required DateTime date,
  });
}
