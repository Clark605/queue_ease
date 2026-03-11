import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../../domain/repositories/admin_service_repository.dart';
import '../datasources/admin_service_datasource.dart';

@LazySingleton(as: AdminServiceRepository)
class AdminServiceRepositoryImpl implements AdminServiceRepository {
  AdminServiceRepositoryImpl(this._datasource, this._logger);

  final AdminServiceDatasource _datasource;
  final AppLogger _logger;

  @override
  Future<Result<ServiceEntity>> createService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      final effective = _applyDefaults(service);
      _logger.debug(
        'AdminServiceRepository: createService → name=${service.name}',
      );
      return _datasource.create(effective);
    });
  }

  @override
  Future<Result<void>> updateService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      _logger.debug(
        'AdminServiceRepository: updateService → serviceId=${service.id}',
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
      _logger.debug(
        'AdminServiceRepository: deleteService → serviceId=$serviceId',
      );
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
