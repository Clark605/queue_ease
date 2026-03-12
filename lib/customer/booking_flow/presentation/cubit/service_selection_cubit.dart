import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/use_cases/get_active_services_use_case.dart';
import 'service_selection_state.dart';

@injectable
class ServiceSelectionCubit extends Cubit<ServiceSelectionState> {
  ServiceSelectionCubit(this._getActiveServices, this._logger)
    : super(const ServiceSelectionInitial());

  final GetActiveServicesUseCase _getActiveServices;
  final AppLogger _logger;

  StreamSubscription<dynamic>? _subscription;

  void loadServices(String orgId) {
    emit(const ServiceSelectionLoading());
    _subscription?.cancel();
    _subscription = _getActiveServices(orgId).listen(
      (services) {
        _logger.debug(
          'ServiceSelectionCubit: received ${services.length} active service(s) for orgId=$orgId',
        );
        emit(ServiceSelectionLoaded(services));
      },
      onError: (Object error, StackTrace st) {
        _logger.error(
          'ServiceSelectionCubit: stream error for orgId=$orgId',
          error,
          st,
        );
        final message = error is AppException
            ? error.message
            : 'Failed to load services. Please try again.';
        emit(ServiceSelectionError(message));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
