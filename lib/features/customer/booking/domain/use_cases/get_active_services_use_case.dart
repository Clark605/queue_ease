import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/service_entity.dart';
import '../../domain/repositories/customer_service_repository.dart';

/// Returns active services for the given organization.
///
/// Queries [CustomerServiceRepository] for all isActive services.
@lazySingleton
class GetActiveServicesUseCase {
  const GetActiveServicesUseCase(this._repository, this._logger);

  final CustomerServiceRepository _repository;
  final AppLogger _logger;

  Future<Result<List<ServiceEntity>>> call(String orgId) async {
    _logger.debug('GetActiveServicesUseCase: call → orgId=$orgId');
    final result = await _repository.getActiveServices(orgId);
    return switch (result) {
      Success(:final data) => () {
        _logger.debug(
          'GetActiveServicesUseCase: found ${data.length} active services',
        );
        return result;
      }(),
      Failure(:final exception) => () {
        _logger.error(
          'GetActiveServicesUseCase: failed to fetch services for orgId=$orgId',
          exception,
        );
        return result;
      }(),
    };
  }
}
