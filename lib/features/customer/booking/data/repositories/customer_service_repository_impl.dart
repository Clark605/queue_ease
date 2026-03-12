import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';
import '../../domain/repositories/customer_service_repository.dart';
import '../datasources/customer_service_datasource.dart';

/// Implementation of [CustomerServiceRepository] using Firestore.
///
/// Provides read-only access to services for customers.
@LazySingleton(as: CustomerServiceRepository)
class CustomerServiceRepositoryImpl implements CustomerServiceRepository {
  CustomerServiceRepositoryImpl(this._datasource, this._logger);

  final CustomerServiceDatasource _datasource;
  final AppLogger _logger;

  @override
  Future<Result<List<ServiceEntity>>> getActiveServices(String orgId) async {
    _logger.debug(
      'CustomerServiceRepositoryImpl: getActiveServices → orgId=$orgId',
    );
    try {
      final services = await _datasource.getActiveServices(orgId);
      return Success(services);
    } on AppException catch (e) {
      _logger.error(
        'CustomerServiceRepositoryImpl: getActiveServices failed orgId=$orgId',
        e,
      );
      return Failure(e);
    } catch (e, st) {
      _logger.error(
        'CustomerServiceRepositoryImpl: getActiveServices unexpected error '
        'orgId=$orgId',
        e,
        st,
      );
      return Failure(
        UnknownException(
          'An unexpected error occurred while retrieving services.',
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
