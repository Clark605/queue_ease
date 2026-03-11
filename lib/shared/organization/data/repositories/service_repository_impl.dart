import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/firestore_service_datasource.dart';

@LazySingleton(as: ServiceRepository)
class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._datasource, this._logger);

  final FirestoreServiceDatasource _datasource;
  final AppLogger _logger;

  @override
  Stream<List<ServiceEntity>> watchServices(String orgId) {
    _logger.debug('ServiceRepository: watchServices → orgId=$orgId');
    return _datasource.watchServices(orgId);
  }
}
