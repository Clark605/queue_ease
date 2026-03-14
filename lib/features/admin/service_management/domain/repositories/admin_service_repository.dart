import '../../../../../core/error/result.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';

/// Unified repository for ALL admin service operations (read + write).
///
/// This replaces the previous split between ServiceRepository (reads)
/// and AdminServiceRepository (writes), eliminating dual injection.
abstract class AdminServiceRepository {
  // -------------------------------------------------------------------------
  // Read Operations
  // -------------------------------------------------------------------------

  /// Returns a real-time stream of all services for [orgId].
  ///
  /// Used by admin dashboard to watch service list changes.
  Stream<List<ServiceEntity>> watchServices(String orgId);

  /// Returns all services for [orgId] (snapshot).
  ///
  /// Used for one-time queries when stream is not needed.
  Future<Result<List<ServiceEntity>>> getServices(String orgId);

  // -------------------------------------------------------------------------
  // Write Operations
  // -------------------------------------------------------------------------

  /// Creates a new service under [orgId].
  Future<Result<ServiceEntity>> createService(ServiceEntity service);

  /// Updates an existing service.
  Future<Result<void>> updateService(ServiceEntity service);

  /// Permanently deletes a service by [serviceId] under [orgId].
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  });
}
