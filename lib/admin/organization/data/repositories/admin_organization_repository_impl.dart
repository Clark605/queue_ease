import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import '../../domain/repositories/admin_organization_repository.dart';
import '../datasources/admin_organization_datasource.dart';

@LazySingleton(as: AdminOrganizationRepository)
class AdminOrganizationRepositoryImpl implements AdminOrganizationRepository {
  AdminOrganizationRepositoryImpl(this._datasource, this._logger);

  final AdminOrganizationDatasource _datasource;
  final AppLogger _logger;

  @override
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  }) {
    return Result.guard(() async {
      _validateName(name);
      _logger.debug(
        'AdminOrganizationRepository: createOrganization → adminUid=$adminUid',
      );
      return _datasource.create(adminUid: adminUid, name: name.trim());
    });
  }

  @override
  Future<Result<void>> updateOrganization(OrganizationEntity organization) {
    return Result.guard(() async {
      _validateName(organization.name);
      _logger.debug(
        'AdminOrganizationRepository: updateOrganization → orgId=${organization.id}',
      );
      await _datasource.update(organization);
    });
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  void _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        'Organization name cannot be empty.',
        field: 'name',
      );
    }
    if (trimmed.length > 100) {
      throw const ValidationException(
        'Organization name must be 100 characters or fewer.',
        field: 'name',
      );
    }
  }
}
