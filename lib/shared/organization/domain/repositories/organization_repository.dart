import '../entities/organization_entity.dart';
import '../../../../core/error/result.dart';

/// Domain contract for shared (read-only) organization data operations.
///
/// Write operations are handled by [AdminOrganizationRepository] in the admin layer.
abstract class OrganizationRepository {
  /// Returns a real-time stream of the [OrganizationEntity] for [orgId].
  Stream<OrganizationEntity> watchOrganization(String orgId);

  /// Returns the [OrganizationEntity] owned by [adminUid], or `null` if none
  /// exists.
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  );

  /// Returns the organization matching [slug], or `null` if not found.
  ///
  /// Slug matching is case-insensitive in the Firestore query.
  /// Used by the customer booking flow to resolve deep links.
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug);
}
