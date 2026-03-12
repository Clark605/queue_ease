import '../../../../../core/error/result.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';

/// Unified repository for ALL admin organization operations (read + write).
///
/// This replaces the previous split between OrganizationRepository (reads)
/// and AdminOrganizationRepository (writes), eliminating dual injection.
abstract class AdminOrganizationRepository {
  // -------------------------------------------------------------------------
  // Read Operations
  // -------------------------------------------------------------------------

  /// Returns a real-time stream of the [OrganizationEntity] for [orgId].
  ///
  /// Used by admin dashboard to watch organization profile changes.
  Stream<OrganizationEntity> watchOrganization(String orgId);

  /// Returns the [OrganizationEntity] owned by [adminUid], or `null` if none
  /// exists.
  ///
  /// Used during admin onboarding to check if admin already has an organization.
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  );

  // -------------------------------------------------------------------------
  // Write Operations
  // -------------------------------------------------------------------------

  /// Creates a new organization owned by [adminUid] with the given [name].
  ///
  /// Generates a unique booking link slug and updates the user document
  /// with organizationId in a batch write.
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });

  /// Updates the organization profile with new data.
  ///
  /// Only updates fields that can be modified: name, address, description,
  /// logoUrl, isOpen. Immutable fields (id, adminUid, slug, createdAt)
  /// are not included.
  Future<Result<void>> updateOrganization(OrganizationEntity organization);
}
