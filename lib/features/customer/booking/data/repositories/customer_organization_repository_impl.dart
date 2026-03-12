import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';
import '../../domain/repositories/customer_organization_repository.dart';
import '../datasources/customer_organization_datasource.dart';

/// Implementation of [CustomerOrganizationRepository] using Firestore.
///
/// Provides read-only access to organization data for customers.
@LazySingleton(as: CustomerOrganizationRepository)
class CustomerOrganizationRepositoryImpl
    implements CustomerOrganizationRepository {
  CustomerOrganizationRepositoryImpl(this._datasource, this._logger);

  final CustomerOrganizationDatasource _datasource;
  final AppLogger _logger;

  @override
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug) async {
    _logger.debug(
      'CustomerOrganizationRepositoryImpl: getOrganizationBySlug → slug=$slug',
    );
    try {
      final organization = await _datasource.getBySlug(slug);
      return Success(organization);
    } on AppException catch (e) {
      _logger.error(
        'CustomerOrganizationRepositoryImpl: getOrganizationBySlug failed '
        'slug=$slug',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'CustomerOrganizationRepositoryImpl: getOrganizationBySlug '
        'unexpected error slug=$slug',
        e,
        st,
      );
      return Failure(
        UnknownException(
          'An unexpected error occurred while retrieving the organization.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
