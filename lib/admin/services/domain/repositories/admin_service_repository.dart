import '../../../../core/error/result.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';

/// Domain contract for admin-only service write operations.
///
/// Read operations (watchServices) remain on the shared [ServiceRepository].
abstract class AdminServiceRepository {
  Future<Result<ServiceEntity>> createService(ServiceEntity service);
  Future<Result<void>> updateService(ServiceEntity service);
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  });
}
