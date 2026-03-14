import '../../../../../core/error/result.dart';
import '../../../../../features/shared_domain/entities/service_entity.dart';

/// Repository for customer-side service operations (read-only).
///
/// Customers only need to view active services for booking.
/// They never create, update, or delete services.
abstract class CustomerServiceRepository {
  /// Returns all active services for [orgId].
  ///
  /// Used by the customer booking flow to display service options.
  Future<Result<List<ServiceEntity>>> getActiveServices(String orgId);
}
