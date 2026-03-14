import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

/// Contract: Admin queue repository operations for Sprint 5.
///
/// Purpose:
/// - Generate and watch daily queue
/// - Apply admin queue actions atomically
/// - Preserve idempotency on retries

abstract class AdminQueueRepository {
  /// Generates (or refreshes idempotently) today's queue from eligible appointments.
  Future<Result<void>> generateDailyQueue({
    required String orgId,
    required DateTime date,
  });

  /// Watches queue snapshot in real time for admin UI.
  Stream<Result<AdminQueueSnapshot>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  });

  /// Marks current entry as completed and promotes next entry.
  Future<Result<void>> next({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Moves current entry to end of waiting queue.
  Future<Result<void>> skip({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Marks current entry as no-show and promotes next entry.
  Future<Result<void>> markNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });

  /// Rejoins skipped appointment by appending to end of queue.
  Future<Result<void>> rejoinSkipped({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}

class AdminQueueSnapshot {
  const AdminQueueSnapshot({
    required this.queueDate,
    required this.current,
    required this.waiting,
  });

  final DateTime queueDate;
  final QueueEntryView? current;
  final List<QueueEntryView> waiting;
}

class QueueEntryView {
  const QueueEntryView({
    required this.appointmentId,
    required this.position,
    required this.customerName,
    required this.serviceDurationMinutes,
    required this.status,
  });

  final String appointmentId;
  final int position;
  final String customerName;
  final int serviceDurationMinutes;
  final AppointmentStatus status;
}
