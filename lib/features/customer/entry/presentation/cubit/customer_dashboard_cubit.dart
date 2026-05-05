import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../../booking/domain/use_cases/cancel_appointment_use_case.dart';
import '../../domain/use_cases/watch_customer_dashboard_use_case.dart';
import 'customer_dashboard_state.dart';

/// Manages the customer dashboard screen state.
///
/// Subscribes to [WatchCustomerDashboardUseCase] and emits states that cover
/// all three content scenarios: active queue, upcoming appointment only, and
/// fully empty.
@injectable
class CustomerDashboardCubit extends Cubit<CustomerDashboardState> {
  CustomerDashboardCubit(
    this._watchDashboard,
    this._cancelUseCase,
    this._logger,
  ) : super(const CustomerDashboardInitial());
  final CancelAppointmentUseCase _cancelUseCase;
  final WatchCustomerDashboardUseCase _watchDashboard;
  final AppLogger _logger;

  static const _fallbackMessage =
      'Unable to load your dashboard right now. Please try again.';

  StreamSubscription<Result<CustomerDashboardView>>? _sub;

  /// Starts watching the live dashboard for [customerId] on [date].
  ///
  /// Cancels any prior subscription first. Emits [CustomerDashboardLoading]
  /// immediately, then transitions to [CustomerDashboardLoaded] or
  /// [CustomerDashboardError].
  void watchDashboard({required String customerId, required DateTime date}) {
    _lastCustomerId = customerId;
    _lastDate = date;
    emit(const CustomerDashboardLoading());
    _sub?.cancel();
    _logger.info(
      'CustomerDashboardCubit',
      'watchDashboard customerId=${customerId.substring(0, 4)}…',
    );
    _sub = _watchDashboard(customerId: customerId, date: date).listen(
      (result) {
        switch (result) {
          case Success(:final data):
            emit(CustomerDashboardLoaded(dashboard: data));
          case Failure(:final exception):
            _logger.error('CustomerDashboardCubit: stream error', exception);
            final msg = exception.message.trim().isEmpty
                ? _fallbackMessage
                : exception.message;
            emit(CustomerDashboardError(message: msg));
        }
      },
      onError: (Object e, StackTrace st) {
        _logger.error('CustomerDashboardCubit: unexpected error', e, st);
        emit(const CustomerDashboardError(message: _fallbackMessage));
      },
    );
  }

  /// Cancels the given appointment and emits updated dashboard on success.
  Future<void> cancelAppointment({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus currentStatus,
  }) async {
    emit(const CustomerDashboardLoading());
    final result = await _cancelUseCase(
      orgId: orgId,
      appointmentId: appointmentId,
      currentStatus: currentStatus,
    );
    switch (result) {
      case Success():
        _logger.info('CustomerDashboardCubit: appointment cancelled');
      case Failure(:final exception):
        _logger.error('CustomerDashboardCubit: cancel failed', exception);
        emit(CustomerDashboardError(message: exception.message));
        return;
    }
    // Refresh dashboard after successful cancellation
    if (_lastCustomerId != null && _lastDate != null) {
      watchDashboard(customerId: _lastCustomerId!, date: _lastDate!);
    }
  }

  String? _lastCustomerId;
  DateTime? _lastDate;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
