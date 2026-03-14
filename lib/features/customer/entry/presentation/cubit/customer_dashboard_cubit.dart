import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/use_cases/watch_customer_dashboard_use_case.dart';
import 'customer_dashboard_state.dart';

/// Manages the customer dashboard screen state.
///
/// Subscribes to [WatchCustomerDashboardUseCase] and emits states that cover
/// all three content scenarios: active queue, upcoming appointment only, and
/// fully empty.
@injectable
class CustomerDashboardCubit extends Cubit<CustomerDashboardState> {
  CustomerDashboardCubit(this._watchDashboard, this._logger)
    : super(const CustomerDashboardInitial());

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

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
