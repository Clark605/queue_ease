import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../../../../shared/organization/domain/repositories/service_repository.dart';
import '../../../services/domain/repositories/admin_service_repository.dart';
import 'service_state.dart';

/// Manages service list state and CRUD operations for an organization.
///
/// Uses [ServiceRepository] for the real-time watch stream and
/// [AdminServiceRepository] for all write operations.
@injectable
class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit(
    this._serviceRepository,
    this._adminServiceRepository,
    this._logger,
  ) : super(const ServiceInitial());

  final ServiceRepository _serviceRepository;
  final AdminServiceRepository _adminServiceRepository;
  final AppLogger _logger;

  StreamSubscription<List<ServiceEntity>>? _servicesSubscription;

  /// Watches the service list for [orgId] in real-time.
  ///
  /// Emits [ServiceLoading] initially, then [ServiceLoaded] on each update.
  /// Any previous subscription is cancelled before starting a new one.
  Future<void> watchServices(String orgId) async {
    _logger.info('ServiceCubit: watchServices → $orgId');
    emit(const ServiceLoading());

    await _servicesSubscription?.cancel();

    _servicesSubscription = _serviceRepository
        .watchServices(orgId)
        .listen(
          (services) {
            _logger.debug(
              'ServiceCubit: received update → ${services.length} services',
            );
            emit(ServiceLoaded(services));
          },
          onError: (error, stackTrace) {
            _logger.error(
              'ServiceCubit: watchServices stream error',
              error,
              stackTrace,
            );
            emit(
              ServiceError(
                error is AppException
                    ? error.message
                    : 'Failed to load services',
              ),
            );
          },
        );
  }

  /// Creates a new service under the given organization.
  ///
  /// Emits [ServiceOperationSuccess] on success, or [ServiceError] on failure.
  /// Does not emit [ServiceLoading] to avoid clobbering the current list view.
  /// The real-time stream will re-emit [ServiceLoaded] with the updated list
  /// automatically.
  Future<void> createService(ServiceEntity service) async {
    _logger.info('ServiceCubit: createService → ${service.name}');

    final result = await _adminServiceRepository.createService(service);
    switch (result) {
      case Success():
        _logger.info('ServiceCubit: createService success');
        emit(const ServiceOperationSuccess());
      case Failure(:final exception):
        _logger.error('ServiceCubit: createService failed', exception);
        emit(ServiceMutationError(exception.message));
    }
  }

  /// Updates an existing service.
  ///
  /// Emits [ServiceOperationSuccess] on success, or [ServiceError] on failure.
  /// Does not emit [ServiceLoading] to avoid clobbering the current list view.
  Future<void> updateService(ServiceEntity service) async {
    _logger.info('ServiceCubit: updateService → ${service.id}');

    final result = await _adminServiceRepository.updateService(service);
    switch (result) {
      case Success():
        _logger.info('ServiceCubit: updateService success');
        emit(const ServiceOperationSuccess());
      case Failure(:final exception):
        _logger.error('ServiceCubit: updateService failed', exception);
        emit(ServiceMutationError(exception.message));
    }
  }

  /// Permanently deletes a service by [serviceId] under [orgId].
  ///
  /// Emits [ServiceOperationSuccess] on success, or [ServiceError] on failure.
  /// Does not emit [ServiceLoading] to avoid clobbering the current list view.
  Future<void> deleteService({
    required String orgId,
    required String serviceId,
  }) async {
    _logger.info('ServiceCubit: deleteService → $serviceId');

    final result = await _adminServiceRepository.deleteService(
      orgId: orgId,
      serviceId: serviceId,
    );
    switch (result) {
      case Success():
        _logger.info('ServiceCubit: deleteService success');
        emit(const ServiceOperationSuccess());
      case Failure(:final exception):
        _logger.error('ServiceCubit: deleteService failed', exception);
        emit(ServiceMutationError(exception.message));
    }
  }

  @override
  Future<void> close() {
    _servicesSubscription?.cancel();
    return super.close();
  }
}
