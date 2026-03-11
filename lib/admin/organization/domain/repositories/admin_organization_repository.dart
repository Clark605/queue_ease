import '../../../../core/error/result.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';

/// Domain contract for admin-only organization write operations.
///
/// Read operations (watchOrganization, getOrganizationByAdminUid) remain on
/// the shared [OrganizationRepository].
abstract class AdminOrganizationRepository {
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });
  Future<Result<void>> updateOrganization(OrganizationEntity organization);
}
