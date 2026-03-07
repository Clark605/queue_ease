import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/firestore_service_datasource.dart';

@LazySingleton(as: ServiceRepository)
class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._datasource, this._logger);

  final FirestoreServiceDatasource _datasource;
  final AppLogger _logger;

  @override
  Stream<List<ServiceEntity>> watchServices(String orgId) {
    _logger.debug('ServiceRepository: watchServices → orgId=$orgId');
    return _datasource.watchServices(orgId);
  }

  @override
  Future<Result<ServiceEntity>> createService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      final effective = _applyDefaults(service);
      _logger.debug('ServiceRepository: createService → name=${service.name}');
      return _datasource.create(effective);
    });
  }

  @override
  Future<Result<void>> updateService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      _logger.debug(
        'ServiceRepository: updateService → serviceId=${service.id}',
      );
      await _datasource.update(service);
    });
  }

  @override
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  }) {
    return Result.guard(() async {
      _logger.debug('ServiceRepository: deleteService → serviceId=$serviceId');
      await _datasource.delete(orgId: orgId, serviceId: serviceId);
    });
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _validate(ServiceEntity service) {
    final name = service.name.trim();
    if (name.isEmpty) {
      throw const ValidationException(
        'Service name cannot be empty.',
        field: 'name',
      );
    }
    if (name.length > 100) {
      throw const ValidationException(
        'Service name must not exceed 100 characters.',
        field: 'name',
      );
    }
    if (service.durationMinutes <= 0) {
      throw const ValidationException(
        'Duration must be greater than zero.',
        field: 'durationMinutes',
      );
    }
  }

  /// Applies default values before persisting a new service.
  ///
  /// [timeMarginMinutes] defaults to `5` when `0` and no explicit override
  /// was provided.
  ServiceEntity _applyDefaults(ServiceEntity service) {
    if (service.timeMarginMinutes == 0) {
      return ServiceEntity(
        id: service.id,
        orgId: service.orgId,
        name: service.name,
        durationMinutes: service.durationMinutes,
        timeMarginMinutes: 5,
        isActive: service.isActive,
        createdAt: service.createdAt,
        price: service.price,
        queueType: service.queueType,
        description: service.description,
      );
    }
    return service;
  }
}
