import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/use_cases/watch_customer_queue_status_use_case.dart';
import 'customer_queue_status_state.dart';

/// Manages live queue status for the customer queue status screen.
///
/// Subscribes to [WatchCustomerQueueStatusUseCase] and emits states based
/// on the combined appointment + queue document stream.
@injectable
class CustomerQueueStatusCubit extends Cubit<CustomerQueueStatusState> {
  CustomerQueueStatusCubit(this._watchStatus, this._logger)
    : super(const CustomerQueueStatusInitial());

  final WatchCustomerQueueStatusUseCase _watchStatus;
  final AppLogger _logger;

  static const _loadQueueFallbackMessage =
      'Unable to load queue data right now. Please try again.';

  String _resolveLoadMessage(String message) {
    final trimmed = message.trim();
    return trimmed.isEmpty ? _loadQueueFallbackMessage : trimmed;
  }

  StreamSubscription<Result<CustomerQueueStatusView?>>? _sub;
  String? _currentOrgId;
  String? _currentCustomerId;
  DateTime? _currentDate;

  /// Starts watching live queue status for [customerId] in [orgId] on [date].
  ///
  /// Cancels any prior subscription first. Emits [CustomerQueueStatusLoading]
  /// immediately, then transitions to [CustomerQueueStatusLoaded],
  /// [CustomerQueueStatusEmpty], or [CustomerQueueStatusError].
  void watchStatus({
    required String orgId,
    required String customerId,
    required DateTime date,
  }) {
    // Store current parameters for refresh
    _currentOrgId = orgId;
    _currentCustomerId = customerId;
    _currentDate = date;

    emit(const CustomerQueueStatusLoading());
    _sub?.cancel();
    _logger.info(
      'CustomerQueueStatusCubit',
      'watchStatus orgId=${orgId.substring(0, 4)}*** customerId=${customerId.substring(0, 4)}***',
    );
    _sub = _watchStatus(orgId: orgId, customerId: customerId, date: date)
        .listen(
          (result) {
            switch (result) {
              case Success(:final data):
                if (data == null) {
                  emit(const CustomerQueueStatusEmpty());
                } else {
                  emit(
                    CustomerQueueStatusLoaded(
                      status: _toPresentationStatus(data),
                    ),
                  );
                }
              case Failure(:final exception):
                _logger.error(
                  'CustomerQueueStatusCubit: stream error',
                  exception,
                );
                emit(
                  CustomerQueueStatusError(
                    message: _resolveLoadMessage(exception.message),
                  ),
                );
            }
          },
          onError: (Object e, StackTrace st) {
            _logger.error('CustomerQueueStatusCubit: unexpected error', e, st);
            emit(
              const CustomerQueueStatusError(
                message: _loadQueueFallbackMessage,
              ),
            );
          },
        );
  }

  /// Refreshes the current queue status by restarting the subscription.
  ///
  /// Uses the last parameters from [watchStatus]. If no previous call was made,
  /// this method does nothing.
  void refreshStatus() {
    if (_currentOrgId != null &&
        _currentCustomerId != null &&
        _currentDate != null) {
      watchStatus(
        orgId: _currentOrgId!,
        customerId: _currentCustomerId!,
        date: _currentDate!,
      );
    }
  }

  CustomerQueueStatusView _toPresentationStatus(CustomerQueueStatusView data) {
    if (!data.isNoShow) {
      return data;
    }

    return CustomerQueueStatusView(
      position: null,
      estimatedWaitMinutes: null,
      isCurrentTurn: false,
      isNoShow: true,
      currentServingIndicator: data.currentServingIndicator,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
