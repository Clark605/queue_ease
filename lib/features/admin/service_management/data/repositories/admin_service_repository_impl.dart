import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';
import '../../domain/repositories/admin_service_repository.dart';
import '../datasources/admin_service_datasource.dart';

/// Implementation of [AdminServiceRepository] using Firestore.
///
/// Handles all admin service operations through a single unified datasource.
@LazySingleton(as: AdminServiceRepository)
class AdminServiceRepositoryImpl implements AdminServiceRepository {
  AdminServiceRepositoryImpl(this._datasource, this._logger);

  final AdminServiceDatasource _datasource;
  final AppLogger _logger;

  // ---------------------------------------------------------------------------
  // Read Operations
  // ---------------------------------------------------------------------------

  @override
  Stream<List<ServiceEntity>> watchServices(String orgId) {
    _logger.debug('AdminServiceRepositoryImpl: watchServices → orgId=$orgId');
    return _datasource.watchServices(orgId);
  }

  @override
  Future<Result<List<ServiceEntity>>> getServices(String orgId) async {
    _logger.debug('AdminServiceRepositoryImpl: getServices → orgId=$orgId');
    try {
      final services = await _datasource.getServices(orgId);
      return Success(services);
    } on AppException catch (e) {
      _logger.error(
        'AdminServiceRepositoryImpl: getServices failed orgId=$orgId',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'AdminServiceRepositoryImpl: getServices unexpected error orgId=$orgId',
        e,
        st,
      );
      return Failure(
        UnknownException(
          'An unexpected error occurred.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Write Operations
  // ---------------------------------------------------------------------------

  @override
  Future<Result<ServiceEntity>> createService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      final effective = _applyDefaults(service);
      _logger.debug(
        'AdminServiceRepositoryImpl: createService → name=${service.name}',
      );
      return _datasource.create(effective);
    });
  }

  @override
  Future<Result<void>> updateService(ServiceEntity service) {
    return Result.guard(() async {
      _validate(service);
      _logger.debug(
        'AdminServiceRepositoryImpl: updateService → serviceId=${service.id}',
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
        'AdminServiceRepositoryImpl: deleteService → serviceId=$serviceId',
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
