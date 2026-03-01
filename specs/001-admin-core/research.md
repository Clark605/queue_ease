# Research: Admin Core — Organization Setup & Service Management

**Phase**: 0  
**Date**: March 1, 2026  
**Status**: Complete — all NEEDS CLARIFICATION resolved

---

## 1. Slug Generation Strategy (FR-004 + Edge Case: simultaneous sign-up collision)

**Decision**: Auto-generate from org name + random suffix using a URL-safe, lowercase, hyphenated format. Format: `{sanitized-name}-{6-char-random-alphanum}`. Example: `sunrise-clinic-a3x9kp`.

**Rationale**: The random suffix makes collisions statistically negligible (36^6 ≈ 2.2 billion combinations) without requiring a uniqueness read-before-write. The Firestore security rules already restrict slug mutation after creation (field immutability). No separate uniqueness check is needed at the client — the random component is sufficient at this scale.

**Alternatives considered**:
- UUID slug: Universally unique but not human-readable (poor for QR landing pages in Sprint 3).
- Sequential number: Requires a counter document and a transaction; adds complexity for no benefit.
- Firestore transaction check: Read-then-write uniqueness guard is valid but unnecessary given the random suffix approach.

**Implementation note**: Slug sanitisation: lowercase, replace spaces/special chars with hyphens, trim consecutive hyphens, max 50 chars before the suffix. Slug is written once at org creation and never updated by the client (enforced by existing security rules).

---

## 2. Tutorial State Persistence (FR-022: survives reinstall / device switch)

**Decision**: Store tutorial completion state as a boolean field `tutorialCompleted` on the user's Firestore document (`users/{uid}`). Read it as part of the existing user profile fetch on login.

**Rationale**: `SharedPreferences` is device-local and does not survive reinstall or device switch, which would fail FR-022. Firestore user documents are already read on every sign-in (the existing `FirestoreUserDatasource.createOrGet` method). Adding one field to that document is the minimal, consistent approach. No new collection or document type is required.

**Alternatives considered**:
- SharedPreferences: Fast but fails FR-022 (device-local only).
- Separate Firestore `tutorialState` subcollection: Unnecessary complexity for a single boolean.
- Firebase Remote Config feature flag: Appropriate for rollout control, not per-user completion state.

**Data impact**: One new boolean field `tutorialCompleted` on the `users/{uid}` document. Default `false` (or absent) → tutorial shows. Set to `true` on completion or skip.

---

## 3. Missing-Org Router Guard Pattern (FR-005a)

**Decision**: Extend the existing `GoRouter` redirect function in `app_router.dart`. When the authenticated user has `UserRole.admin` and `user.organizationId == null`, redirect to a new `/a/setup` route (the "Complete Your Setup" screen), blocking all other `/a/` routes until `organizationId` is populated. The `GoRouterRefreshStream` already listens to `AuthCubit` — updating the `AuthCubit` state after org creation will automatically trigger a redirect to `/a/dashboard`.

**Rationale**: The existing router guard pattern is well-established in the codebase (auth state → redirect). Extending it for the missing-org case follows the same pattern without introducing a new state management mechanism. Refreshing the router via `AuthCubit` state change is clean and consistent with how post-login routing already works.

**Alternatives considered**:
- Separate `OrgSetupCubit` refresh stream: Adds a second `refreshListenable` to GoRouter; valid but more complex than needed.
- Navigator push from dashboard: Breaks the declarative router model; hard to guard all sub-routes.

---

## 4. Organization Creation Atomicity (FR-001 + FR-002)

**Decision**: Org creation happens sequentially after account creation, not in a Firestore transaction. Sequence: (1) Firebase Auth creates account, (2) `FirestoreUserDatasource.createOrGet` writes user doc with `organizationId: null`, (3) `OrganizationRepository.createOrganization` writes org doc, (4) `FirestoreUserDatasource.updateOrganizationId` updates user doc with the new org ID.

Steps 3–4 are not atomic but the missing-org guard (FR-005a) provides recovery. Step 4 failure leaves the org doc orphaned but the admin can retry — the "Complete Your Setup" screen calls only step 3+4 and is idempotent (checks for an existing org by `adminUid` before creating a new one).

**Rationale**: Firestore does not support cross-document atomic writes outside of batched writes (which still do not provide read-then-write atomicity). A Firestore batched write can atomically write the org doc and update the user doc in one round-trip. **Use a `WriteBatch` for steps 3+4** to ensure both documents are written together or not at all.

**Revised decision**: Use `WriteBatch` for the combined org-doc-create + user-doc-update operation. This does not help if Auth creation succeeds but the batch fails, but it prevents the partial state where the org doc exists but the user doc still has `organizationId: null`.

---

## 5. Firestore Collection Structure for Services

**Decision**: Services are stored in a **subcollection** `organizations/{orgId}/services/{serviceId}`. This is already the established pattern in the existing `ServiceModel.fromDoc` implementation (the `orgId` is passed as a parameter since it is not in the document itself). The `OrganizationRepository` and `ServiceRepository` both use this layout.

**Rationale**: Subcollection scoping allows Firestore security rules to use `get(/databases/(default)/documents/organizations/{orgId})` to validate org membership — this is already implemented in the deployed rules. A top-level services collection would require a compound index on `orgId` and would need extra security rule logic. Subcollection is simpler, already supported by existing models and rules.

---

## 6. UserEntity: `orgName` → `organizationId` Migration

**Decision**: Replace `orgName: String?` with `organizationId: String?` on `UserEntity`. Existing `FirestoreUserDatasource` methods that read/write `orgName` are updated to use `organizationId`. No database migration script is needed — the app is in active development with no production users. Existing dev Firestore data (if any) can be manually cleared or re-created.

**Rationale**: The `orgName` field was a placeholder collected at sign-up before the Organization entity was fully designed. Now that a full Organization document exists, the string denormalization is removed at the source. All UI reading the org name will use the Organization document via `organizationId`.

---

## 7. Auth Repository Signup Modification (FR-001 + FR-002)

**Decision**: `AuthRepositoryImpl.signUpWithEmailPassword` is extended to accept an `orgName` parameter (already present) and, for admin sign-ups, call `OrganizationRepository.createOrganization` after the user profile is created. The `OrganizationRepository` is injected into `AuthRepositoryImpl` only when the role is admin (or passed in always and conditionally called). The returned `organizationId` is then written to the user document.

**Rationale**: Auth signup already orchestrates multiple steps (Auth credential + Firestore profile). Adding org creation to this sequence is consistent and keeps the signup logic centralized. The alternative (calling org creation from the signup Cubit) would put data orchestration in the presentation layer, violating Clean Architecture.

**Implementation note**: `OrganizationRepository` is a new dependency of `AuthRepositoryImpl`. Injectable DI will wire it automatically since both are registered as `LazySingleton`.

---

## All NEEDS CLARIFICATION items from spec: Resolved

| Item | Resolution |
|------|------------|
| Slug uniqueness on concurrent sign-ups | Random 6-char suffix makes collision statistically negligible; no transaction guard needed |
| Tutorial state across devices | `tutorialCompleted` boolean on Firestore user document |
| Missing-org recovery UX | GoRouter redirect guard; `AuthCubit` stream refresh triggers automatic re-route after setup |
| Org creation atomicity | `WriteBatch` for org-doc + user-doc-update; missing-org guard provides recovery for Auth-level failure |
| Services collection layout | Subcollection `organizations/{orgId}/services` — already established in existing models |
| `orgName` migration path | Direct field replacement; no DB migration needed (dev environment only) |
| Auth repo modification | `OrganizationRepository` injected into `AuthRepositoryImpl`; org creation called conditionally for admin sign-ups |
