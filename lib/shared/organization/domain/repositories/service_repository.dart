import '../entities/service_entity.dart';
import '../../../../core/error/result.dart';

/// Domain contract for all service data operations scoped to an organization.
///
/// Services are stored in the subcollection
/// `organizations/{orgId}/services/{serviceId}`.
/// No framework imports belong here.
abstract class ServiceRepository {
  /// Returns a real-time stream of all [ServiceEntity] records for [orgId].
  ///
  /// Includes both active and inactive services, ordered by [createdAt]
  /// ascending.  Emits an empty list when no services exist.
  /// The caller is responsible for cancelling the subscription on dispose.
  Stream<List<ServiceEntity>> watchServices(String orgId);

  /// Creates a new [ServiceEntity] under the given organization.
  ///
  /// [service.id] is ignored — Firestore auto-generates the document ID.
  /// [service.createdAt] is set to the server timestamp by the implementation.
  ///
  /// Throws:
  /// - [ValidationException] if [name] is empty, exceeds 100 chars, or
  ///   [durationMinutes] ≤ 0.
  /// - [DatabaseException] if the Firestore write fails.
  Future<Result<ServiceEntity>> createService(ServiceEntity service);

  /// Updates all mutable fields of an existing [ServiceEntity].
  ///
  /// [service.id] and [service.orgId] must match an existing document.
  /// [service.createdAt] is immutable and is preserved by the implementation.
  ///
  /// Throws:
  /// - [ValidationException] if [name] is empty, exceeds 100 chars, or
  ///   [durationMinutes] ≤ 0.
  /// - [DatabaseException] if the Firestore write fails.
  Future<Result<void>> updateService(ServiceEntity service);

  /// Permanently deletes the service identified by [serviceId] under [orgId].
  ///
  /// Throws:
  /// - [DatabaseException] if the document does not exist or the write fails.
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  });
}
