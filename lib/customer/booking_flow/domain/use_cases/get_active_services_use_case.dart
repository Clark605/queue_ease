import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../../../../shared/organization/domain/repositories/service_repository.dart';

/// Returns a stream of active services for the given organization.
///
/// Filters [ServiceRepository.watchServices] to [isActive == true].
@lazySingleton
class GetActiveServicesUseCase {
  const GetActiveServicesUseCase(this._repository, this._logger);

  final ServiceRepository _repository;
  final AppLogger _logger;

  Stream<List<ServiceEntity>> call(String orgId) {
    return _repository
        .watchServices(orgId)
        .map((services) {
          final active = services.where((s) => s.isActive).toList();
          return active;
        })
        .handleError((Object error, StackTrace st) {
          _logger.error(
            'GetActiveServicesUseCase: failed to fetch services for orgId=$orgId',
            error,
            st,
          );
          if (error is AppException) throw error;
          throw UnknownException(
            'Failed to load services.',
            cause: error,
            stackTrace: st,
          );
        });
  }
}
