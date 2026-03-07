import '../entities/organization_entity.dart';
import '../../../../core/error/result.dart';

/// Domain contract for all organization data operations.
///
/// The data layer implements this interface; the presentation layer depends
/// only on this abstraction.  No framework imports belong here.
abstract class OrganizationRepository {
  /// Creates a new [OrganizationEntity] in the data store.
  ///
  /// Generates a unique [bookingLinkSlug] from [name] automatically.
  /// Returns the created entity on success.
  ///
  /// Throws:
  /// - [ValidationException] if [name] is empty or exceeds 100 characters.
  /// - [DatabaseException] if the Firestore write fails.
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });

  /// Returns a real-time stream of the [OrganizationEntity] for [orgId].
  ///
  /// Emits a new value whenever the document changes in Firestore.
  /// The caller is responsible for cancelling the subscription on dispose.
  Stream<OrganizationEntity> watchOrganization(String orgId);

  /// Updates mutable fields of an existing organization.
  ///
  /// Only [name], [address], [description], [logoUrl], and [isOpen] may be
  /// changed.  The fields [adminUid], [bookingLinkSlug], and [createdAt] are
  /// immutable and will be preserved by the implementation.
  ///
  /// Throws:
  /// - [ValidationException] if [name] is empty or exceeds 100 characters.
  /// - [DatabaseException] if the Firestore write fails.
  Future<Result<void>> updateOrganization(OrganizationEntity organization);

  /// Returns the [OrganizationEntity] owned by [adminUid], or `null` if none
  /// exists.
  ///
  /// Used during the missing-org recovery flow to detect and reuse an
  /// existing org document before creating a new one.
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  );
}
