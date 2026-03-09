import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/organization_entity.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/firestore_organization_datasource.dart';

@LazySingleton(as: OrganizationRepository)
class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl(this._datasource, this._logger);

  final FirestoreOrganizationDatasource _datasource;
  final AppLogger _logger;

  @override
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  }) {
    return Result.guard(() async {
      _validateName(name);
      _logger.debug(
        'OrganizationRepository: createOrganization → adminUid=$adminUid',
      );
      return _datasource.create(adminUid: adminUid, name: name.trim());
    });
  }

  @override
  Stream<OrganizationEntity> watchOrganization(String orgId) {
    _logger.debug('OrganizationRepository: watchOrganization → orgId=$orgId');
    return _datasource.watchById(orgId);
  }

  @override
  Future<Result<void>> updateOrganization(OrganizationEntity organization) {
    return Result.guard(() async {
      _validateName(organization.name);
      _logger.debug(
        'OrganizationRepository: updateOrganization → orgId=${organization.id}',
      );
      await _datasource.update(organization);
    });
  }

  @override
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  ) {
    return Result.guard(() async {
      _logger.debug(
        'OrganizationRepository: getOrganizationByAdminUid → '
        'adminUid=$adminUid',
      );
      return _datasource.getByAdminUid(adminUid);
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
