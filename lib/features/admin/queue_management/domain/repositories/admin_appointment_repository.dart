import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

// ---------------------------------------------------------------------------
// View models
// ---------------------------------------------------------------------------

/// A snapshot of the daily queue for the admin UI.
class AdminQueueSnapshot {
  const AdminQueueSnapshot({
    required this.queueDate,
    required this.current,
    required this.waiting,
  });

  final DateTime queueDate;

  /// The entry currently being served, or null when the queue is empty.
  final QueueEntryView? current;

  /// Entries waiting after the current serving index, in queue order.
  final List<QueueEntryView> waiting;
}

/// Display-safe projection of a single queued appointment (no raw PII keys).
class QueueEntryView {
  const QueueEntryView({
    required this.appointmentId,
    required this.position,
    required this.customerName,
    required this.serviceDurationMinutes,
    required this.status,
    this.estimatedWaitMinutes,
  });

  final String appointmentId;
  final int position;
  final String customerName;
  final int serviceDurationMinutes;
  final AppointmentStatus status;
  final int? estimatedWaitMinutes;
}

// ---------------------------------------------------------------------------
// Domain contract
// ---------------------------------------------------------------------------

/// Domain contract for admin appointment and queue operations.
///
/// Covers real-time queue display, status updates, and queue lifecycle
/// actions (generate, advance, skip, no-show, rejoin).
abstract class AdminAppointmentRepository {
  // -- Appointment watch ----------------------------------------------------

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

  // -- Queue lifecycle (implemented in Phase 3) -----------------------------

  /// Generates (or idempotently refreshes) today's queue from eligible
  /// appointments (`status == booked`), ordered by `scheduledAt ASC`.
  Future<Result<void>> generateDailyQueue({
    required String orgId,
    required DateTime date,
  });

  /// Watches the daily queue snapshot in real time.
  ///
  /// Emits an [AdminQueueSnapshot] whenever the queue document or any
  /// referenced appointment document changes.
  Stream<Result<AdminQueueSnapshot>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  });

  /// Marks the current entry as completed and promotes the next entry.
  /// Atomic Firestore transaction; safe to retry.
  Future<Result<void>> next({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Moves the current entry to the end of the waiting queue.
  /// Status transition: `serving → inQueue`.
  Future<Result<void>> skip({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Marks the current entry as no-show and promotes the next entry.
  /// Status transition: `serving → noShow`.
  Future<Result<void>> markNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Rejoins a no-show/skipped appointment by appending it to the end of
  /// the waiting queue. Status transition: `noShow → inQueue`.
  Future<Result<void>> rejoinSkipped({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}
