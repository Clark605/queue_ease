# Contract: ServiceRepository

**File**: `lib/shared/organization/domain/repositories/service_repository.dart`  
**Layer**: Domain (no framework imports)  
**Implements**: Clean Architecture repository interface

---

## Purpose

Defines the contract for all service data operations scoped to an organization. Services are stored in the subcollection `organizations/{orgId}/services/{serviceId}`.

---

## Interface

```dart
abstract class ServiceRepository {
  /// Returns a real-time stream of all [ServiceEntity] records for [orgId].
  ///
  /// The stream includes both active and inactive services, ordered by
  /// [createdAt] ascending. Emits an empty list if no services exist.
  /// Emits an error event if the read fails.
  Stream<List<ServiceEntity>> watchServices(String orgId);

  /// Creates a new [ServiceEntity] under the given organization.
  ///
  /// [service.id] is ignored; Firestore auto-generates the document ID.
  /// [service.orgId] must match a valid organization owned by the caller.
  /// [service.createdAt] is set to server timestamp by the implementation.
  ///
  /// Errors:
  /// - [ValidationException] if name is empty, exceeds 100 chars, or
  ///   durationMinutes is ≤ 0
  /// - [DatabaseException] if the Firestore write fails
  Future<Result<ServiceEntity>> createService(ServiceEntity service);

  /// Updates all mutable fields of an existing [ServiceEntity].
  ///
  /// [service.id] and [service.orgId] must match an existing document.
  /// [service.createdAt] is immutable and preserved by the implementation.
  ///
  /// Errors:
  /// - [ValidationException] if name is empty, exceeds 100 chars, or
  ///   durationMinutes is ≤ 0
  /// - [DatabaseException] if the Firestore write fails
  Future<Result<void>> updateService(ServiceEntity service);

  /// Permanently deletes the service identified by [serviceId] under [orgId].
  ///
  /// Errors:
  /// - [DatabaseException] if the document does not exist or write fails
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  });
}
```

---

## Method Contracts

### `watchServices`

| Concern | Detail |
|---------|--------|
| Preconditions | `orgId` is a valid organization ID the caller has read access to |
| Stream behaviour | Emits immediately; continues emitting on any service CRUD operation; emits `[]` for an org with no services |
| Ordering | Results ordered by `createdAt` ascending (oldest first) |
| Error cases | Stream emits error on network failure or missing parent org; caller must handle with `onError` |
| Cancellation | Caller is responsible for cancelling the stream subscription when the screen is disposed |

### `createService`

| Concern | Detail |
|---------|--------|
| Preconditions | `orgId` exists and belongs to the authenticated admin; `name` valid; `durationMinutes` > 0 |
| Postconditions | Document created at `organizations/{orgId}/services/{auto-id}`; `timeMarginMinutes` defaults to `5` if not provided; `isActive` defaults to `true`; `createdAt` is server timestamp |
| Error cases | `ValidationException` on invalid fields; `DatabaseException` on Firestore failure |
| Idempotency | NOT idempotent — duplicate calls create duplicate documents |

### `updateService`

| Concern | Detail |
|---------|--------|
| Preconditions | Service with `service.id` exists under `service.orgId`; `service.name` valid; `service.durationMinutes` > 0 |
| Postconditions | Document updated with new field values; `createdAt` and `orgId` are preserved unchanged |
| Error cases | `ValidationException` on invalid fields; `DatabaseException` on Firestore failure |
| Idempotency | Idempotent — updating with same data is safe |

### `deleteService`

| Concern | Detail |
|---------|--------|
| Preconditions | Service document exists; caller must have confirmed deletion before calling (confirmation dialog is a UI concern, not a contract concern) |
| Postconditions | Document permanently removed from `organizations/{orgId}/services/{serviceId}` |
| Error cases | `DatabaseException` if document not found or write fails |
| Idempotency | Idempotent — deleting an already-deleted document returns success |

---

## Validation Rules (shared between create and update)

| Field | Rule |
|-------|------|
| `name` | Non-empty after trimming; max 100 characters |
| `durationMinutes` | Integer strictly greater than 0 |
| `timeMarginMinutes` | Integer ≥ 0; default `5` on create if absent |
| `price` | If present, must be ≥ 0 |

---

## Dependencies (implementation, not interface)

- `FirebaseFirestore` (data layer only)
- `ServiceModel` (data layer only)
- `AppLogger` (data layer only)
