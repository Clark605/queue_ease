import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/organization_entity.dart';
import '../../domain/repositories/customer_organization_repository.dart';

/// Resolves a booking link slug to the matching [OrganizationEntity].
@lazySingleton
class GetOrganizationBySlugUseCase {
  const GetOrganizationBySlugUseCase(this._repository, this._logger);

  final CustomerOrganizationRepository _repository;
  final AppLogger _logger;

  Future<Result<OrganizationEntity?>> call(String slug) async {
    final result = await _repository.getOrganizationBySlug(slug);
    return switch (result) {
      Success(:final data) when data == null => () {
        _logger.warning(
          'GetOrganizationBySlugUseCase: no organization found for slug=$slug',
        );
        return result;
      }(),
      Failure(:final exception) when exception is DatabaseException => () {
        _logger.error(
          'GetOrganizationBySlugUseCase: database error for slug=$slug',
          exception,
          exception.stackTrace,
        );
        return result;
      }(),
      _ => result,
    };
  }
}
