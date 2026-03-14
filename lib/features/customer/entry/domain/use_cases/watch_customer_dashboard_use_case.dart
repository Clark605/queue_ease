import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../customer/booking/domain/repositories/customer_appointment_repository.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import 'watch_customer_queue_status_use_case.dart';

/// Aggregated snapshot of the customer's dashboard for today.
///
/// Produced by [WatchCustomerDashboardUseCase] by combining two streams:
/// the cross-org active-appointment stream and the per-org queue-status stream.
class CustomerDashboardView {
  const CustomerDashboardView({
    required this.activeAppointment,
    required this.upcomingAppointment,
    required this.queueStatus,
  });

  /// The customer's active appointment today (status `inQueue` or `serving`).
  ///
  /// Null when the customer is not currently in any queue.
  final AppointmentEntity? activeAppointment;

  /// The customer's next upcoming appointment today (status `booked`).
  ///
  /// Null when there are no booked appointments remaining for today.
  final AppointmentEntity? upcomingAppointment;

  /// Full live queue status for [activeAppointment]'s org.
  ///
  /// Null until the queue-status inner stream emits, or when
  /// [activeAppointment] is null.
  final CustomerQueueStatusView? queueStatus;

  bool get hasActiveQueue => activeAppointment != null;
  bool get hasUpcoming => upcomingAppointment != null;
  bool get isEmpty => !hasActiveQueue && !hasUpcoming;
}

/// Combines the cross-org active-appointment stream with the
/// per-org live queue-status stream into a [CustomerDashboardView] stream.
///
/// - Emits eagerly whenever appointments change, even before queue status
///   resolves (in which case [CustomerDashboardView.queueStatus] is null).
/// - Dynamically re-subscribes to the queue-status stream whenever the
///   active appointment's org changes.
@injectable
class WatchCustomerDashboardUseCase {
  const WatchCustomerDashboardUseCase(
    this._repository,
    this._watchQueueStatus,
    this._logger,
  );

  final CustomerAppointmentRepository _repository;
  final WatchCustomerQueueStatusUseCase _watchQueueStatus;
  final AppLogger _logger;

  Stream<Result<CustomerDashboardView>> call({
    required String customerId,
    required DateTime date,
  }) {
    _logger.info(
      'WatchCustomerDashboardUseCase',
      'Watching dashboard customerId=${customerId.substring(0, 4)}…',
    );
    return _combineStreams(customerId: customerId, date: date);
  }

  Stream<Result<CustomerDashboardView>> _combineStreams({
    required String customerId,
    required DateTime date,
  }) {
    late StreamController<Result<CustomerDashboardView>> controller;
    StreamSubscription<Result<List<AppointmentEntity>>>? apptSub;
    StreamSubscription<Result<CustomerQueueStatusView?>>? queueStatusSub;

    List<AppointmentEntity>? latestAppointments;
    CustomerQueueStatusView? latestQueueStatus;
    String? activeOrgId;

    void emitCurrent() {
      final appointments = latestAppointments;
      if (appointments == null) return;

      final active = appointments.firstWhereOrNull(
        (a) =>
            a.status == AppointmentStatus.inQueue ||
            a.status == AppointmentStatus.serving,
      );
      final upcoming = appointments.firstWhereOrNull(
        (a) => a.status == AppointmentStatus.booked,
      );

      // If the active appointment's org changed, restart the inner stream.
      if (active?.orgId != activeOrgId) {
        activeOrgId = active?.orgId;
        queueStatusSub?.cancel();
        queueStatusSub = null;
        latestQueueStatus = null;

        if (active != null) {
          queueStatusSub =
              _watchQueueStatus(
                orgId: active.orgId,
                customerId: customerId,
                date: date,
              ).listen(
                (result) {
                  latestQueueStatus =
                      result is Success<CustomerQueueStatusView?>
                      ? result.data
                      : null;
                  emitCurrent();
                },
                onError: (Object e, StackTrace st) {
                  // Non-fatal: dashboard renders without queue metadata.
                  _logger.warning(
                    'WatchCustomerDashboardUseCase: queue status inner error',
                    e,
                    st,
                  );
                  latestQueueStatus = null;
                  emitCurrent();
                },
              );
          // Emit immediately with queueStatus=null so the UI doesn't block.
        }
      }

      controller.add(
        Success(
          CustomerDashboardView(
            activeAppointment: active,
            upcomingAppointment: upcoming,
            queueStatus: active != null ? latestQueueStatus : null,
          ),
        ),
      );
    }

    controller = StreamController<Result<CustomerDashboardView>>(
      onListen: () {
        apptSub = _repository
            .watchTodayActiveAppointments(customerId: customerId, date: date)
            .listen(
              (result) {
                switch (result) {
                  case Success(:final data):
                    latestAppointments = data;
                    emitCurrent();
                  case Failure(:final exception):
                    _logger.error(
                      'WatchCustomerDashboardUseCase: appointment stream error',
                      exception,
                    );
                    controller.add(Failure(exception));
                }
              },
              onError: (Object e, StackTrace st) {
                _logger.error(
                  'WatchCustomerDashboardUseCase: unexpected stream error',
                  e,
                  st,
                );
                controller.add(
                  Failure(
                    UnknownException(
                      'Failed to load dashboard data.',
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
        queueStatusSub?.cancel();
      },
    );

    return controller.stream;
  }
}

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}
