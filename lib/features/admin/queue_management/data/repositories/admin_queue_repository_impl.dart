import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import '../datasources/admin_queue_datasource.dart';

/// Firestore-backed implementation of [AdminAppointmentRepository].
///
/// Bridges [AdminQueueDatasource] with the domain layer.
/// Method implementations are added per phase:
/// - Phase 2 (T010): Declares interface binding and stub overrides.
/// - Phase 3 (T014): Implements all queue action methods.
@LazySingleton(as: AdminAppointmentRepository)
class AdminQueueRepositoryImpl implements AdminAppointmentRepository {
  AdminQueueRepositoryImpl(this._datasource, this._logger);

  final AdminQueueDatasource _datasource;
  final AppLogger _logger;

  // ---------------------------------------------------------------------------
  // Appointment watch — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  @override
  Stream<List<AppointmentEntity>> watchAppointmentsByDate({
    required String orgId,
    required DateTime date,
  }) {
    // TODO(T013): Implement real-time appointment watch for admin queue.
    throw UnimplementedError('T013: Implement in Phase 3 (US1)');
  }

  @override
  Future<Result<void>> updateAppointmentStatus({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus status,
  }) {
    // TODO(T014): Implement via datasource transaction in Phase 3 (US1).
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }

  // ---------------------------------------------------------------------------
  // Queue generation — T030 (Phase 3 / US3)
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> generateDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    // TODO(T030): Implement idempotent daily queue generation.
    throw UnimplementedError('T030: Implement in Phase 3 (US3)');
  }

  // ---------------------------------------------------------------------------
  // Queue watch — T014 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  @override
  Stream<Result<AdminQueueSnapshot>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    // TODO(T014): Implement AdminQueueSnapshot stream from queue doc.
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }

  // ---------------------------------------------------------------------------
  // Queue action transactions — T014 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> next({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    // TODO(T014): Implement serving→completed transition + promote next.
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }

  @override
  Future<Result<void>> skip({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    // TODO(T014): Implement serving→inQueue reinsert at end.
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }

  @override
  Future<Result<void>> markNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    // TODO(T014): Implement serving→noShow transition + promote next.
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }

  @override
  Future<Result<void>> rejoinSkipped({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    // TODO(T014): Implement noShow→inQueue append to end.
    throw UnimplementedError('T014: Implement in Phase 3 (US1)');
  }
}
