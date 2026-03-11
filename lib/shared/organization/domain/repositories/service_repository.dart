import '../entities/service_entity.dart';

/// Domain contract for shared (read-only) service data operations.
///
/// Write operations are handled by [AdminServiceRepository] in the admin layer.
abstract class ServiceRepository {
  /// Returns a real-time stream of all [ServiceEntity] records for [orgId],
  /// ordered by [createdAt] ascending.
  Stream<List<ServiceEntity>> watchServices(String orgId);
}
