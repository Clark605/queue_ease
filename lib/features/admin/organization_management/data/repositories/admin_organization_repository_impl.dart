import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';
import '../../domain/repositories/admin_organization_repository.dart';
import '../datasources/admin_organization_datasource.dart';

/// Implementation of [AdminOrganizationRepository] using Firestore.
///
/// Handles all admin organization operations through a single unified datasource.
@LazySingleton(as: AdminOrganizationRepository)
class AdminOrganizationRepositoryImpl implements AdminOrganizationRepository {
  AdminOrganizationRepositoryImpl(this._datasource, this._logger);

  final AdminOrganizationDatasource _datasource;
  final AppLogger _logger;

  // ---------------------------------------------------------------------------
  // Read Operations
  // ---------------------------------------------------------------------------

  @override
  Stream<OrganizationEntity> watchOrganization(String orgId) {
    _logger.debug(
      'AdminOrganizationRepositoryImpl: watchOrganization → orgId=$orgId',
    );
    return _datasource.watchById(orgId);
  }

  @override
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  ) async {
    _logger.debug(
      'AdminOrganizationRepositoryImpl: getOrganizationByAdminUid → '
      'adminUid=$adminUid',
    );
    try {
      final organization = await _datasource.getByAdminUid(adminUid);
      return Success(organization);
    } on AppException catch (e) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: getOrganizationByAdminUid failed '
        'adminUid=$adminUid',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: getOrganizationByAdminUid '
        'unexpected error adminUid=$adminUid',
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
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  }) async {
    _logger.debug(
      'AdminOrganizationRepositoryImpl: createOrganization → '
      'adminUid=$adminUid name=$name',
    );
    try {
      final organization = await _datasource.create(
        adminUid: adminUid,
        name: name,
      );
      return Success(organization);
    } on AppException catch (e) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: createOrganization failed '
        'adminUid=$adminUid',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: createOrganization unexpected error '
        'adminUid=$adminUid',
        e,
        st,
      );
      return Failure(
        UnknownException(
          'An unexpected error occurred while creating the organization.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateOrganization(
    OrganizationEntity organization,
  ) async {
    _logger.debug(
      'AdminOrganizationRepositoryImpl: updateOrganization → '
      'orgId=${organization.id}',
    );
    try {
      await _datasource.update(organization);
      return const Success(null);
    } on AppException catch (e) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: updateOrganization failed '
        'orgId=${organization.id}',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'AdminOrganizationRepositoryImpl: updateOrganization unexpected error '
        'orgId=${organization.id}',
        e,
        st,
      );
      return Failure(
        UnknownException(
          'An unexpected error occurred while updating the organization.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
