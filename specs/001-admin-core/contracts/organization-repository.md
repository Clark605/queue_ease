# Contract: OrganizationRepository

**File**: `lib/shared/organization/domain/repositories/organization_repository.dart`  
**Layer**: Domain (no framework imports)  
**Implements**: Clean Architecture repository interface

---

## Purpose

Defines the contract for all organization data operations. The data layer implements this interface; the presentation layer depends only on this abstraction.

---

## Interface

```dart
abstract class OrganizationRepository {
  /// Creates a new [OrganizationEntity] in the data store.
  ///
  /// Generates a unique [bookingLinkSlug] from [name] automatically.
  /// Returns the created entity on success.
  ///
  /// Errors:
  /// - [ValidationException] if [name] is empty or exceeds 100 characters
  /// - [DatabaseException] if the Firestore write fails
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });

  /// Returns a real-time stream of the [OrganizationEntity] for [orgId].
  ///
  /// Emits a new value whenever the organization document changes.
  /// Emits an error event if the document does not exist or the read fails.
  Stream<OrganizationEntity> watchOrganization(String orgId);

  /// Updates mutable fields of an existing organization.
  ///
  /// Only the following fields may be updated: [name], [address],
  /// [description], [logoUrl], [isOpen].
  /// All other fields (adminUid, bookingLinkSlug, createdAt) are immutable.
  ///
  /// Errors:
  /// - [ValidationException] if [name] is empty or exceeds 100 characters
  /// - [DatabaseException] if the Firestore write fails
  Future<Result<void>> updateOrganization(OrganizationEntity organization);

  /// Returns the [OrganizationEntity] owned by [adminUid], or null if none.
  ///
  /// Used during the missing-org recovery flow to detect and reuse an
  /// existing org document before creating a new one.
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(
    String adminUid,
  );
}
```

---

## Method Contracts

### `createOrganization`

| Concern | Detail |
|---------|--------|
| Preconditions | `adminUid` is a valid, authenticated user UID; `name` is non-empty after trimming |
| Postconditions | Organization document exists in `organizations/{orgId}`; `bookingLinkSlug` is unique; `isOpen` defaults to `false`; `createdAt` is server timestamp |
| Error cases | `ValidationException` on invalid name; `DatabaseException` on Firestore failure |
| Idempotency | NOT idempotent — calling twice creates two org documents |

### `watchOrganization`

| Concern | Detail |
|---------|--------|
| Preconditions | `orgId` is a valid organization ID |
| Stream behaviour | Emits immediately with cached data if available; continues emitting on remote changes |
| Error cases | Stream emits error if document not found or network fails; caller must handle with `onError` |
| Cancellation | Caller is responsible for cancelling the stream subscription when the screen is disposed |

### `updateOrganization`

| Concern | Detail |
|---------|--------|
| Preconditions | Organization with `organization.id` exists; `organization.name` is valid |
| Postconditions | Mutable fields updated in Firestore; immutable fields (`adminUid`, `bookingLinkSlug`, `createdAt`) preserved |
| Error cases | `ValidationException` on invalid name; `DatabaseException` on Firestore failure |
| Idempotency | Idempotent — updating with the same data is safe |

### `getOrganizationByAdminUid`

| Concern | Detail |
|---------|--------|
| Purpose | Used in missing-org recovery: check if an org already exists before creating a new one |
| Returns | `Result<OrganizationEntity?>` — `null` inside `Success` means no org found |
| Error cases | `DatabaseException` on Firestore failure |

---

## Slug Generation (implementation guidance — not part of interface)

Format: `{sanitized-name}-{6-char-random-alphanum}`  
Sanitisation: lowercase, replace non-alphanumeric with `-`, collapse consecutive `-`, trim leading/trailing `-`, cap at 50 characters before suffix.  
Example: `"Sunrise Clinic & Spa"` → `"sunrise-clinic-spa-a3x9kp"`

---

## Dependencies (implementation, not interface)

- `FirebaseFirestore` (data layer only)
- `OrganizationModel` (data layer only)
- `AppLogger` (data layer only)
