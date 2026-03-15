import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../customer/booking/domain/repositories/customer_appointment_repository.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../../../shared_domain/entities/queue_entity.dart';
import 'calculate_wait_time_use_case.dart';

/// Live view model for a customer's queue position.
///
/// Produced by [WatchCustomerQueueStatusUseCase] from the combined
/// appointment + queue document streams.
class CustomerQueueStatusView {
  const CustomerQueueStatusView({
    required this.position,
    required this.estimatedWaitMinutes,
    required this.isCurrentTurn,
    required this.isNoShow,
    required this.currentServingIndicator,
  });

  /// 1-based position of this customer in the ordered queue, or null.
  final int? position;

  /// Estimated wait in minutes
  final int? estimatedWaitMinutes;

  /// True when it is this customer's turn (appointment.status == serving).
  final bool isCurrentTurn;

  /// True when the customer has been marked as no-show.
  final bool isNoShow;

  /// 1-based position currently being served, or null if no queue yet.
  final int? currentServingIndicator;
}

/// Combines the customer's appointment stream and the daily queue stream
/// into a unified [CustomerQueueStatusView] stream.
///
/// Emits `Success(null)` when the customer has no active queue entry today.
@injectable
class WatchCustomerQueueStatusUseCase {
  const WatchCustomerQueueStatusUseCase(
    this._repository,
    this._calculateWaitTime,
    this._logger,
  );

  final CustomerAppointmentRepository _repository;
  final CalculateWaitTimeUseCase _calculateWaitTime;
  final AppLogger _logger;

  /// Emits [CustomerQueueStatusView?] as either stream updates.
  ///
  /// Emits `Success(null)` when the customer has no active queue entry today.
  Stream<Result<CustomerQueueStatusView?>> call({
    required String orgId,
    required String customerId,
    required DateTime date,
  }) {
    _logger.info(
      'WatchCustomerQueueStatusUseCase',
      'Watching queue status customerId=${customerId.substring(0, 4)}*** orgId=${orgId.substring(0, 4)}***',
    );
    return _combineLatest(
      _repository.watchCustomerQueueAppointment(
        orgId: orgId,
        customerId: customerId,
        date: date,
      ),
      _repository.watchDailyQueue(orgId: orgId, date: date),
      _repository.watchQueueAppointmentsForDate(orgId: orgId, date: date),
    );
  }

  Stream<Result<CustomerQueueStatusView?>> _combineLatest(
    Stream<Result<AppointmentEntity?>> appointmentStream,
    Stream<Result<QueueEntity?>> queueStream,
    Stream<Result<List<QueueAppointmentWaitEntry>>> queueAppointmentsStream,
  ) {
    StreamSubscription<Result<AppointmentEntity?>>? apptSub;
    StreamSubscription<Result<QueueEntity?>>? queueSub;
    StreamSubscription<Result<List<QueueAppointmentWaitEntry>>>?
    queueAppointmentsSub;
    Result<AppointmentEntity?>? latestAppt;
    Result<QueueEntity?>? latestQueue;
    Result<List<QueueAppointmentWaitEntry>>? latestQueueAppointments;
    late StreamController<Result<CustomerQueueStatusView?>> controller;

    void tryEmit() {
      final appt = latestAppt;
      final queue = latestQueue;
      final queueAppointments = latestQueueAppointments;
      if (appt == null || queue == null || queueAppointments == null) return;

      if (appt case Failure(:final exception)) {
        controller.add(Failure(exception));
        return;
      }
      if (queue case Failure(:final exception)) {
        controller.add(Failure(exception));
        return;
      }
      if (queueAppointments case Failure(:final exception)) {
        controller.add(Failure(exception));
        return;
      }

      final appointment = (appt as Success<AppointmentEntity?>).data;
      final queueEntity = (queue as Success<QueueEntity?>).data;
      final queueWaitEntries =
          (queueAppointments as Success<List<QueueAppointmentWaitEntry>>).data;

      if (appointment == null) {
        controller.add(const Success(null));
        return;
      }

      int? position;
      int? currentServingIndicator;
      int? estimatedWaitMinutes;

      if (queueEntity != null) {
        final idx = queueEntity.orderedAppointmentIds.indexOf(appointment.id);
        if (idx >= 0) position = idx + 1;
        if (queueEntity.orderedAppointmentIds.isNotEmpty) {
          currentServingIndicator = queueEntity.currentServingIndex + 1;
        }

        final currentIndex = queueEntity.currentServingIndex;
        if (idx > currentIndex) {
          final waitEntryById = {
            for (final item in queueWaitEntries) item.appointmentId: item,
          };

          final durationsAhead = <int>[];
          for (var i = currentIndex; i < idx; i++) {
            final aheadId = queueEntity.orderedAppointmentIds[i];
            final waitEntry = waitEntryById[aheadId];
            if (waitEntry == null) continue;
            if (waitEntry.status == AppointmentStatus.noShow ||
                waitEntry.status == AppointmentStatus.completed) {
              continue;
            }
            durationsAhead.add(waitEntry.serviceDurationMinutes);
          }
          estimatedWaitMinutes = _calculateWaitTime(durationsAhead);
        } else if (idx >= 0) {
          estimatedWaitMinutes = 0;
        }
      }

      controller.add(
        Success(
          CustomerQueueStatusView(
            position: position,
            estimatedWaitMinutes: estimatedWaitMinutes,
            isCurrentTurn: appointment.status == AppointmentStatus.serving,
            isNoShow: appointment.status == AppointmentStatus.noShow,
            currentServingIndicator: currentServingIndicator,
          ),
        ),
      );
    }

    controller = StreamController<Result<CustomerQueueStatusView?>>(
      onListen: () {
        apptSub = appointmentStream.listen(
          (r) {
            latestAppt = r;
            tryEmit();
          },
          onError: (Object e, StackTrace st) {
            controller.add(
              Failure(
                UnknownException(
                  'Queue appointment watch failed.',
                  cause: e,
                  stackTrace: st,
                ),
              ),
            );
          },
        );
        queueSub = queueStream.listen(
          (r) {
            latestQueue = r;
            tryEmit();
          },
          onError: (Object e, StackTrace st) {
            controller.add(
              Failure(
                UnknownException(
                  'Queue document watch failed.',
                  cause: e,
                  stackTrace: st,
                ),
              ),
            );
          },
        );
        queueAppointmentsSub = queueAppointmentsStream.listen(
          (r) {
            latestQueueAppointments = r;
            tryEmit();
          },
          onError: (Object e, StackTrace st) {
            controller.add(
              Failure(
                UnknownException(
                  'Queue appointments watch failed.',
                  cause: e,
                  stackTrace: st,
                ),
              ),
            );
          },
        );
      },
      onCancel: () {
        apptSub?.cancel();
        queueSub?.cancel();
        queueAppointmentsSub?.cancel();
      },
    );

    return controller.stream;
  }
}
