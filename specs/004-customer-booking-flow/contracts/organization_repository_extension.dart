import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/shared/organization/domain/entities/organization_entity.dart';

/// Extended domain contract for shared organization operations.
///
/// Adds the slug-based lookup method required by the customer booking flow.
/// The existing `watchOrganization` and `getOrganizationByAdminUid` methods
/// remain unchanged.
abstract class OrganizationRepository {
  // ... existing methods ...

  /// Returns the organization matching [slug], or `null` if not found.
  ///
  /// Slug matching is case-insensitive in the Firestore query.
  /// Used by the customer booking flow to resolve deep links.
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug);
}
