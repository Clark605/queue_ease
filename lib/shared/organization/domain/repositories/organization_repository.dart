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
}
