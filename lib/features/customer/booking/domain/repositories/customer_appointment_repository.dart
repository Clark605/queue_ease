import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_entity.dart';

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
  /// and `status` is in `{inQueue, serving}`, or `null` when none exists.
  /// Used by [WatchCustomerQueueStatusUseCase] to derive queue position.
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
}
