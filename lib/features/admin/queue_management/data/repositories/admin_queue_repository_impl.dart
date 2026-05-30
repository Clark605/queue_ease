import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import '../../domain/services/effective_time_margin_resolver.dart';
import '../../domain/services/queue_deadline_evaluator.dart';
import '../datasources/admin_queue_datasource.dart';

/// Firestore-backed implementation of [AdminAppointmentRepository].
///
/// Bridges [AdminQueueDatasource] with the domain layer.
/// Method implementations added per phase:
/// - Phase 2 (T010): Declares interface binding and stub overrides.
/// - Phase 3 (T014): Implements all queue action methods.
@LazySingleton(as: AdminAppointmentRepository)
class AdminQueueRepositoryImpl implements AdminAppointmentRepository {
  AdminQueueRepositoryImpl(this._datasource, this._logger);

  final AdminQueueDatasource _datasource;
  final AppLogger _logger;
  final _timeMarginResolver = const EffectiveTimeMarginResolver();
  final _deadlineEvaluator = const QueueDeadlineEvaluator();

  static final _dateFormatter = DateFormat('yyyy-MM-dd');
  static const _minimumServiceDurationMinutes = 5;

  String _maskId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 4) return '***$value';
    return '***${value.substring(value.length - 4)}';
  }

  String _sanitizeMessage(String message) {
    return message
        .replaceAll(
          RegExp(
            r'customer(Name|Phone)?\s*[:=]\s*[^,\s]+',
            caseSensitive: false,
          ),
          'customer=***',
        )
        .replaceAll(
          RegExp(r'phone\s*[:=]\s*[^,\s]+', caseSensitive: false),
          'phone=***',
        );
  }

  Map<String, Object?> _queueLogContext({
    required String operation,
    required String orgId,
    String? appointmentId,
    String? date,
  }) {
    return {
      'operation': operation,
      'orgId': _maskId(orgId),
      ...?(appointmentId == null
          ? null
          : {'appointmentId': _maskId(appointmentId)}),
      ...?(date == null ? null : {'date': date}),
    };
  }

  // ---------------------------------------------------------------------------
  // Appointment watch — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  @override
  Stream<List<AppointmentEntity>> watchAppointmentsByDate({
    required String orgId,
    required DateTime date,
  }) {
    _logger.debug(
      'AdminQueueRepositoryImpl.watchAppointmentsByDate',
      _queueLogContext(
        operation: 'watchAppointmentsByDate',
        orgId: orgId,
        date: _dateFormatter.format(date),
      ),
    );
    return _datasource
        .watchAppointmentsByDate(orgId, date)
        .map(
          (docs) => docs.map((doc) {
            final data = doc.data();
            return AppointmentEntity(
              id: doc.id,
              orgId: orgId,
              serviceId: data['serviceId'] as String,
              customerId: data['customerId'] as String,
              customerName: data['customerName'] as String,
              customerPhone: data['customerPhone'] as String?,
              scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
              status: AppointmentStatus.values.byName(data['status'] as String),
              queuePosition: data['queuePosition'] as int?,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList(),
        );
  }

  @override
  Future<Result<void>> updateAppointmentStatus({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus status,
  }) {
    return Result.guard(() async {
      final context = _queueLogContext(
        operation: 'updateAppointmentStatus',
        orgId: orgId,
        appointmentId: appointmentId,
      );
      try {
        _logger.info('Admin queue status update requested', {
          ...context,
          'status': status.name,
        });
        await _datasource.appointments(orgId).doc(appointmentId).update({
          'status': status.name,
        });
      } on FirebaseException catch (e, st) {
        _logger.error('Admin queue status update failed', context, st);
        throw DatabaseException(
          'Failed to update appointment status: ${e.message}',
          stackTrace: st,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Queue generation — T030 (Phase 3 / US3)
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> generateDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info(
      'Admin queue generation requested',
      _queueLogContext(
        operation: 'generateDailyQueue',
        orgId: orgId,
        date: dateStr,
      ),
    );
    return Result.guard(
      () => _datasource.generateDailyQueue(orgId: orgId, date: dateStr),
    );
  }

  // ---------------------------------------------------------------------------
  // Queue watch — T014 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  @override
  Stream<Result<AdminQueueSnapshot>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.debug(
      'AdminQueueRepositoryImpl.watchDailyQueue',
      _queueLogContext(
        operation: 'watchDailyQueue',
        orgId: orgId,
        date: dateStr,
      ),
    );
    return _datasource.watchDailyQueue(orgId, dateStr).asyncMap((
      queueData,
    ) async {
      return Result.guard(() async {
        if (queueData == null) {
          return AdminQueueSnapshot(
            queueDate: date,
            current: null,
            waiting: [],
          );
        }

        final orderedIdsRaw = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final orderedIds = <String>[];
        final seenIds = <String>{};
        for (final id in orderedIdsRaw) {
          if (seenIds.add(id)) {
            orderedIds.add(id);
          }
        }
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;

        if (orderedIds.isEmpty) {
          return AdminQueueSnapshot(
            queueDate: date,
            current: null,
            waiting: [],
          );
        }

        final apptChunks = _chunks(orderedIds, 30).toList();
        final apptSnapshots = await Future.wait(
          apptChunks.map(
            (chunk) => _datasource
                .appointments(orgId)
                .where(FieldPath.documentId, whereIn: chunk)
                .get(),
          ),
        );

        final apptMap = <String, Map<String, dynamic>>{};
        for (final apptSnap in apptSnapshots) {
          for (final doc in apptSnap.docs) {
            apptMap[doc.id] = doc.data();
          }
        }

        final serviceIds = apptMap.values
            .map((data) => data['serviceId'] as String?)
            .whereType<String>()
            .toSet()
            .toList();
        final serviceDurationById = <String, int>{};
        final serviceMarginById = <String, int?>{};

        for (final serviceIdChunk in _chunks(serviceIds, 30)) {
          final serviceSnap = await _datasource
              .services(orgId)
              .where(FieldPath.documentId, whereIn: serviceIdChunk)
              .get();
          for (final serviceDoc in serviceSnap.docs) {
            final data = serviceDoc.data();
            final duration = data['durationMinutes'] as int?;
            serviceDurationById[serviceDoc.id] =
                duration == null || duration < _minimumServiceDurationMinutes
                ? _minimumServiceDurationMinutes
                : duration;
            serviceMarginById[serviceDoc.id] =
                data['timeMarginMinutes'] as int?;
          }
        }

        final durationByAppointmentId = <String, int>{};
        for (final entry in apptMap.entries) {
          final serviceId = entry.value['serviceId'] as String?;
          durationByAppointmentId[entry.key] = serviceId == null
              ? _minimumServiceDurationMinutes
              : serviceDurationById[serviceId] ??
                    _minimumServiceDurationMinutes;
        }

        QueueEntryView? current;
        final waiting = <QueueEntryView>[];
        var runningWaitMinutes = 0;

        for (var i = 0; i < orderedIds.length; i++) {
          final id = orderedIds[i];
          final data = apptMap[id];
          if (data == null) continue;

          final status = AppointmentStatus.values.byName(
            data['status'] as String? ?? AppointmentStatus.inQueue.name,
          );
          final scheduledAt = (data['scheduledAt'] as Timestamp?)?.toDate();
          if (scheduledAt == null) continue;
          final duration = durationByAppointmentId[id] ?? 0;
          final serviceId = data['serviceId'] as String?;
          final effectiveMarginMinutes = _timeMarginResolver.resolve(
            timeMarginMinutes: serviceId == null
                ? null
                : serviceMarginById[serviceId],
          );
          final automationEvaluation = _deadlineEvaluator.evaluate(
            now: TimeUtils.nowUtc(),
            scheduledAt: scheduledAt,
            effectiveTimeMarginMinutes: effectiveMarginMinutes,
            status: status,
          );

          final estimatedWaitMinutes = i > currentIndex
              ? (status == AppointmentStatus.noShow ? null : runningWaitMinutes)
              : null;

          final entry = QueueEntryView(
            appointmentId: id,
            position: i + 1,
            customerName: data['customerName'] as String? ?? 'Unknown',
            scheduledAt: scheduledAt,
            serviceDurationMinutes: duration,
            effectiveTimeMarginMinutes: effectiveMarginMinutes,
            noShowDeadline: automationEvaluation.noShowDeadline,
            automationState: automationEvaluation.state,
            allowedActions: automationEvaluation.allowedActions,
            status: status,
            remainingSeconds: automationEvaluation.remainingSeconds,
            estimatedWaitMinutes: estimatedWaitMinutes,
          );

          if (i == currentIndex) {
            current = entry;
          } else if (i > currentIndex) {
            waiting.add(entry);
          }

          if (i >= currentIndex &&
              status != AppointmentStatus.noShow &&
              status != AppointmentStatus.completed) {
            runningWaitMinutes += duration;
          }
        }

        if (current == null && waiting.isNotEmpty) {
          final nextIndex = waiting.indexWhere(
            (entry) =>
                entry.status != AppointmentStatus.noShow &&
                entry.status != AppointmentStatus.completed,
          );

          if (nextIndex != -1) {
            current = waiting[nextIndex].copyWith(estimatedWaitMinutes: null);
            waiting.removeAt(nextIndex);
          }
        }

        return AdminQueueSnapshot(
          queueDate: date,
          current: current,
          waiting: waiting,
        );
      });
    });
  }

  Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
    if (values.isEmpty) return;
    for (var index = 0; index < values.length; index += size) {
      final end = index + size > values.length ? values.length : index + size;
      yield values.sublist(index, end);
    }
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
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'next',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'next',
    });
    return Result.guard(
      () => _datasource.transactionNext(
        orgId: orgId,
        date: dateStr,
        appointmentId: appointmentId,
      ),
    );
  }

  @override
  Future<Result<void>> startServing({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'startServing',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'startServing',
    });
    return Result.guard(
      () => _datasource.transactionStartServing(
        orgId: orgId,
        date: dateStr,
        appointmentId: appointmentId,
      ),
    );
  }

  @override
  Future<Result<void>> skip({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'skip',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'skip',
    });
    return Result.guard(
      () => _datasource.transactionSkip(
        orgId: orgId,
        date: dateStr,
        appointmentId: appointmentId,
      ),
    );
  }

  @override
  Future<Result<void>> markNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'markNoShow',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'markNoShow',
    });
    return _datasource.transactionMarkNoShow(
      orgId: orgId,
      date: dateStr,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<Result<void>> markOverdueNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'markOverdueNoShow',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'markOverdueNoShow',
    });
    return _datasource.transactionMarkOverdueNoShow(
      orgId: orgId,
      date: dateStr,
      appointmentId: appointmentId,
    );
  }

  @override
  Future<Result<void>> rejoinSkipped({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) {
    final dateStr = _dateFormatter.format(date);
    _logger.info('Admin queue action requested', {
      ..._queueLogContext(
        operation: 'rejoinSkipped',
        orgId: orgId,
        appointmentId: appointmentId,
        date: dateStr,
      ),
      'action': 'rejoin',
    });
    return Result.guard(
      () => _datasource.transactionRejoin(
        orgId: orgId,
        date: dateStr,
        appointmentId: appointmentId,
      ),
    ).then(
      (result) => switch (result) {
        Success() => () {
          _logger.info('Admin queue action succeeded', {
            ..._queueLogContext(
              operation: 'rejoinSkipped',
              orgId: orgId,
              appointmentId: appointmentId,
              date: dateStr,
            ),
            'note': 'Rejoin completed and automation timing refreshed',
          });
          return result;
        }(),
        Failure(:final exception) => () {
          _logger.error('Admin queue action failed', {
            ..._queueLogContext(
              operation: 'rejoinSkipped',
              orgId: orgId,
              appointmentId: appointmentId,
              date: dateStr,
            ),
            'message': _sanitizeMessage(exception.message),
          });
          return result;
        }(),
      },
    );
  }
}
