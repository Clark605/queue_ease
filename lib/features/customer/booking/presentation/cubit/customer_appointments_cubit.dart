import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../domain/use_cases/watch_customer_appointments_use_case.dart';
import 'customer_appointments_state.dart';

@injectable
class CustomerAppointmentsCubit extends Cubit<CustomerAppointmentsState> {
  CustomerAppointmentsCubit(this._watchAppointments, this._logger)
    : super(const CustomerAppointmentsInitial());

  final WatchCustomerAppointmentsUseCase _watchAppointments;
  final AppLogger _logger;

  static const _fallbackMessage =
      'Unable to load your appointments right now. Please try again.';

  StreamSubscription<Result<List<AppointmentEntity>>>? _sub;

  void watchAppointments({required String customerId, required DateTime date}) {
    emit(const CustomerAppointmentsLoading());
    _sub?.cancel();
    _logger.info(
      'CustomerAppointmentsCubit',
      'watchAppointments customerId=${customerId.substring(0, 4)}...',
    );
    _sub = _watchAppointments(customerId: customerId, date: date).listen(
      (result) {
        switch (result) {
          case Success(:final data):
            emit(CustomerAppointmentsLoaded(appointments: data));
          case Failure(:final exception):
            _logger.error('CustomerAppointmentsCubit: stream error', exception);
            final message = exception.message.trim().isEmpty
                ? _fallbackMessage
                : exception.message;
            emit(CustomerAppointmentsError(message: message));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'CustomerAppointmentsCubit: unexpected error',
          error,
          stackTrace,
        );
        emit(const CustomerAppointmentsError(message: _fallbackMessage));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
