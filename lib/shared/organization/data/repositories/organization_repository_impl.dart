import 'package:injectable/injectable.dart';

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
  Stream<OrganizationEntity> watchOrganization(String orgId) {
    _logger.debug('OrganizationRepository: watchOrganization → orgId=$orgId');
    return _datasource.watchById(orgId);
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

  @override
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug) {
    return Result.guard(() async {
      _logger.debug(
        'OrganizationRepository: getOrganizationBySlug → slug=$slug',
      );
      return _datasource.getBySlug(slug);
    });
  }
}
