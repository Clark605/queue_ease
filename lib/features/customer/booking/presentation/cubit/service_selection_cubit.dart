import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/use_cases/get_active_services_use_case.dart';
import 'service_selection_state.dart';

@injectable
class ServiceSelectionCubit extends Cubit<ServiceSelectionState> {
  ServiceSelectionCubit(this._getActiveServices, this._logger)
    : super(const ServiceSelectionInitial());

  final GetActiveServicesUseCase _getActiveServices;
  final AppLogger _logger;

  /// Loads all active services for the given organization.
  Future<void> loadServices(String orgId) async {
    emit(const ServiceSelectionLoading());

    final result = await _getActiveServices(orgId);
    switch (result) {
      case Success(:final data):
        _logger.debug(
          'ServiceSelectionCubit: loaded ${data.length} active service(s) for orgId=$orgId',
        );
        emit(ServiceSelectionLoaded(data));
      case Failure(:final exception):
        _logger.error(
          'ServiceSelectionCubit: failed to load services for orgId=$orgId',
          exception,
        );
        emit(ServiceSelectionError(exception.message));
    }
  }
}
