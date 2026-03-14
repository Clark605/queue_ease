import '../../../../../core/error/result.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';

/// Repository for customer-side organization operations (read-only).
///
/// Customers only need to resolve booking link slugs to organizations.
/// They never create, update, or query by adminUid.
abstract class CustomerOrganizationRepository {
  /// Returns the organization matching [slug], or `null` if not found.
  ///
  /// Slug matching is case-insensitive. Used by the customer booking flow
  /// to resolve deep link slugs like "acme-cafe-abc123".
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug);
}
