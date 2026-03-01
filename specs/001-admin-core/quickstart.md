# Quickstart: Implementing Admin Core

**Branch**: `001-admin-core`  
**Date**: March 1, 2026  
**Sprint**: Sprint 2 (Week 3)

This guide walks through the complete implementation sequence for the Admin Core feature. Follow each step in order — later steps depend on earlier ones.

---

## Prerequisites

- `001-firestore-security-rules` merged to `develop`
- Running on branch `001-admin-core` (already created)
- `flutter pub get` for latest dependencies
- Firebase emulators available for local dev testing: `firebase emulators:start`

---

## Stitch Design Reference

All screen designs live in the **QueueEase** Stitch project (`10237896241607667264`).  
See [ui-screens.md](ui-screens.md) for the full screen → Flutter page mapping with screenshots.

| Stitch Screen | Screen ID | Step |
|---|---|---|
| Business Admin Dashboard | `8dfd84da8a4e47bfb11d83662b881e0c` | Step 10 |
| Organization Landing Screen Variant 3 | `2561164f987a4e7c84c9c59d56576da7` | Step 7 |
| Service Details — Modern Grid | `2dc2ab8c7eab425497cafcb23034f587` | Step 7 |
| Services Management Empty State | `6390660a070a4727baea580118dd6bca` | Step 8 |
| Services Management List | `eb2781a9ff3646ef87decaf682022a32` | Step 8 |
| Add Service Form (Variant 2) | `eb5dc21cc1624d30877ae249112e941a` | Step 8 |
| Edit Service Form (Variant 1) | `dd7e56c4ee974bc2a41b13443f8b0b75` | Step 8 |
| _(Tutorial overlay — no Stitch screen; see notes)_ | — | Step 9 |

> **Gap**: Organization Setup page and the Admin Tutorial overlay have no dedicated Stitch screens.  
> Use "Organization Landing Screen Variant 3" as the design baseline for both, simplified as described in [ui-screens.md](ui-screens.md#gaps--missing-screens).

---

## Step 1 — Domain: Repository Interfaces (P0 foundation, ~1 hour)

Create the two new repository interface files. These live in the domain layer and have **zero external imports** (no Flutter, no Firebase, no injectable).

**Files to create:**
- `lib/shared/organization/domain/repositories/organization_repository.dart`
- `lib/shared/organization/domain/repositories/service_repository.dart`

**Reference**: See [contracts/organization-repository.md](contracts/organization-repository.md) and [contracts/service-repository.md](contracts/service-repository.md) for the exact method signatures.

**Key rules:**
- Import only `package:queue_ease/core/error/result.dart` and the entity files
- All async methods return `Future<Result<T>>`; streams return `Stream<T>`
- No annotations, no `@injectable`

---

## Step 2 — Domain: Modify `UserEntity` and `AuthRepository` (~30 min)

**`lib/shared/auth/domain/entities/user_entity.dart`**:
- Remove `orgName: String?`
- Add `organizationId: String?`
- Add `tutorialCompleted: bool` (defaults to `false` in constructor)
- Update `props` list accordingly

**`lib/shared/auth/domain/repositories/auth_repository.dart`**:
- Update `signUpWithEmailPassword` signature: replace `orgName` param with `orgName` kept for the call but make clear in the doc comment that it's consumed to create an Organization document for admin sign-ups

No behaviour change in this interface yet — the implementation change comes in Step 5.

---

## Step 3 — Data: Datasources (~2 hours)

### 3a. `FirestoreOrganizationDatasource`
- File: `lib/shared/organization/data/datasources/firestore_organization_datasource.dart`
- Annotate `@lazySingleton`
- Inject `FirebaseFirestore` and `AppLogger`
- Methods: `create`, `watchById`, `update`, `getByAdminUid`
- Use `OrganizationModel.fromDoc` for deserialization; `toMap()` for writes
- Slug generation logic lives here (private helper method)
- `create` uses a `WriteBatch` that simultaneously writes the org document and updates `users/{uid}.organizationId`

### 3b. `FirestoreServiceDatasource`
- File: `lib/shared/organization/data/datasources/firestore_service_datasource.dart`
- Annotate `@lazySingleton`
- Inject `FirebaseFirestore` and `AppLogger`
- Methods: `watchServices`, `create`, `update`, `delete`
- Services subcollection path: `organizations/{orgId}/services`
- `watchServices` uses `snapshots()` on the subcollection, ordered by `createdAt` ascending

### 3c. Update `FirestoreUserDatasource`
- Replace all references to `orgName` with `organizationId`
- Add a new method: `updateOrganizationId(String uid, String organizationId)`
- Add `tutorialCompleted` field to `createOrGet` default map (value: `false`)
- Add `markTutorialCompleted(String uid)` method

---

## Step 4 — Data: Repository Implementations (~1.5 hours)

### 4a. `OrganizationRepositoryImpl`
- File: `lib/shared/organization/data/repositories/organization_repository_impl.dart`
- Annotate `@LazySingleton(as: OrganizationRepository)`
- Inject `FirestoreOrganizationDatasource` and `AppLogger`
- Validate `name` (non-empty, ≤100 chars) before calling datasource — throw `ValidationException` on failure
- Wrap all datasource calls in `Result.guard()`

### 4b. `ServiceRepositoryImpl`
- File: `lib/shared/organization/data/repositories/service_repository_impl.dart`
- Annotate `@LazySingleton(as: ServiceRepository)`
- Inject `FirestoreServiceDatasource` and `AppLogger`
- Validate `name` and `durationMinutes` before calls — throw `ValidationException` on failure
- Apply `timeMarginMinutes` default of `5` in `createService` if value is `0` and no explicit override provided

---

## Step 5 — Data: Update `AuthRepositoryImpl` (~45 min)

- Inject `OrganizationRepository` as a new constructor parameter
- In `signUpWithEmailPassword`, after the user profile is created:
  - If `role == UserRole.admin`, call `organizationRepository.createOrganization(adminUid: uid, name: orgName ?? '')`
  - The `WriteBatch` inside `FirestoreOrganizationDatasource.create` handles the user doc update atomically
  - Return the updated `UserEntity` with `organizationId` populated
- Run `build_runner` to regenerate injection config: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Step 6 — Router: Add New Routes and Missing-Org Guard (~45 min)

**`lib/core/app/router/app_router.dart`**:

Add new route constants to `Routes`:
```dart
static const String adminSetup    = '/a/setup';
static const String adminOrgProfile  = '/a/org/profile';
static const String adminOrgEdit     = '/a/org/edit';
static const String adminServices    = '/a/services';
static const String adminServiceForm = '/a/services/form';
```

Extend the router `redirect` function — inside the `Authenticated` branch, before the cross-role check, add:
```dart
// Missing-org guard for admin
if (user.role == UserRole.admin && 
    user.organizationId == null &&
    location != Routes.adminSetup) {
  return Routes.adminSetup;
}
if (user.role == UserRole.admin &&
    user.organizationId != null &&
    location == Routes.adminSetup) {
  return Routes.adminDashboard;
}
```

Add `GoRoute` entries for all 5 new routes pointing to the corresponding page classes.

---

## Step 7 — Presentation: Organization Feature Module (~3 hours)

> **Stitch references**: [Organization Landing Screen Variant 3](ui-screens.md#2-organization-landing-screen-variant-3) · [Service Details — Modern Grid](ui-screens.md#7-service-details--modern-grid)

**`admin/organization/presentation/cubit/organization_cubit.dart`**:
- Inject `OrganizationRepository`
- States: `OrganizationInitial`, `OrganizationLoading`, `OrganizationLoaded(OrganizationEntity org)`, `OrganizationError(String message)`
- `watchOrganization(String orgId)`: subscribes to the stream; emits `Loaded` on each event
- `updateOrganization(OrganizationEntity org)`: emits `Loading`, then `Loaded` or `Error`
- `setupOrganization({required String adminUid, required String name})`: calls `createOrganization`; on success triggers `AuthCubit` reload

**Pages to create:**
- `organization_setup_page.dart`: single text field for org name + submit button; shown when `organizationId == null`
- `organization_profile_page.dart`: displays org fields; FAB/edit button navigates to edit page
- `organization_profile_edit_page.dart`: form with all editable fields; save calls `updateOrganization`

---

## Step 8 — Presentation: Services Feature Module (~3 hours)

> **Stitch references**: [Services Management Empty State](ui-screens.md#3-services-management--empty-state) · [Services Management List](ui-screens.md#4-services-management--list) · [Add Service Form (Variant 2)](ui-screens.md#5-add-service-form-variant-2) · [Edit Service Form (Variant 1)](ui-screens.md#6-edit-service-form-variant-1)

**`admin/services/presentation/cubit/service_cubit.dart`**:
- Inject `ServiceRepository`
- States: `ServiceInitial`, `ServiceLoading`, `ServiceLoaded(List<ServiceEntity> services)`, `ServiceError(String message)`, `ServiceOperationSuccess`
- `watchServices(String orgId)`: subscribes to stream
- `createService(ServiceEntity service)`: emits `Loading`, then re-subscribes (stream auto-updates)
- `updateService(ServiceEntity service)`: same pattern
- `deleteService({required String orgId, required String serviceId})`: same pattern; emits `ServiceOperationSuccess` for snackbar confirmation

**Pages to create:**
- `service_list_page.dart`: `StreamBuilder`-backed list; FAB to add; tap to edit; swipe-to-delete with confirmation dialog
- `service_form_page.dart`: shared add/edit form; receives optional `ServiceEntity` for edit mode

**Key widget**: `service_list_tile.dart` — displays name, duration, active/inactive badge, and trailing actions

---

## Step 9 — Presentation: Tutorial Feature Module (~2 hours)

> **Stitch reference**: No dedicated tutorial screen in Stitch. Design the overlay using the app's primary colour (`#136dec`), Inter font, and 8px radius. Reference the customer onboarding screens (`51b1b1ae`, `d524f657`, `a410645f`) for visual tone.

**`admin/tutorial/presentation/cubit/tutorial_cubit.dart`**:
- Inject `FirestoreUserDatasource` (or abstract it behind a `UserRepository` in a future sprint)
- States: `TutorialHidden`, `TutorialActive(TutorialStep step)`, `TutorialCompleted`
- `TutorialStep` enum: `confirmProfile`, `addService`, `acknowledgeReady`
- `initialize(UserEntity user)`: emits `TutorialActive(confirmProfile)` if `!user.tutorialCompleted`
- `advance()`: progresses through steps; on last step calls `markTutorialCompleted`
- `skip()`: calls `markTutorialCompleted`; emits `TutorialCompleted`

**Widget**: `tutorial_overlay.dart` — positioned overlay with step description, highlight indicator, progress dots, "Next" / "Skip" buttons. Uses `BlocBuilder<TutorialCubit, TutorialState>`.

**Integration**: `AdminDashboardPage` wraps content with a `Stack` + `BlocBuilder` for `TutorialCubit`; overlay renders on top when `TutorialActive`.

---

## Step 10 — Wiring: `AdminDashboardPage` Integration (~1 hour)

> **Stitch reference**: [Business Admin Dashboard](ui-screens.md#1-business-admin-dashboard) — screen ID `8dfd84da8a4e47bfb11d83662b881e0c`

- Provide `OrganizationCubit`, `ServiceCubit`, and `TutorialCubit` via `MultiBlocProvider` at the admin dashboard level (or at router level using `BlocProvider.value` for shared cubits)
- On dashboard load, call `organizationCubit.watchOrganization(user.organizationId!)` and `tutorialCubit.initialize(user)`
- Bottom navigation bar (or drawer): Organisation Profile | Services | (future: Queue, Settings)

---

## Step 11 — Run `build_runner`

After all DI annotations are in place:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Verify `injection.config.dart` includes `OrganizationRepository`, `ServiceRepository`, `FirestoreOrganizationDatasource`, `FirestoreServiceDatasource`.

---

## Step 12 — Manual Smoke Test Checklist

Walk through the following manually to verify the feature before PR:

- [ ] New admin signs up → org created in Firestore → user doc has `organizationId`
- [ ] Dashboard loads without errors
- [ ] Tutorial appears on first load; advances through 3 steps; disappears on completion
- [ ] Tutorial does not appear on second sign-in
- [ ] "Skip" tutorial → does not appear on next visit
- [ ] Org profile screen shows correct name, address, description
- [ ] Editing org name saves and reflects immediately
- [ ] Editing the name to empty shows validation error
- [ ] Service list screen shows empty state on fresh org
- [ ] Add service → appears in list immediately
- [ ] Edit service duration → list updates
- [ ] Toggle service inactive → badge shows; service still visible to admin
- [ ] Delete service → confirmation dialog → service removed
- [ ] Sign out with no org (simulate by clearing `organizationId` in Firestore) → redirected to `/a/setup`
- [ ] Complete setup from `/a/setup` → redirected to dashboard

---

## Key Patterns Reference

**Result\<T\> wrapping** (follow constitution):
```dart
Future<Result<OrganizationEntity>> createOrganization(...) async {
  return Result.guard(() async {
    _validateName(name); // throws ValidationException on failure
    final org = await _datasource.create(adminUid: adminUid, name: name);
    return org;
  });
}
```

**Stream in Cubit** (cancel subscription on close):
```dart
StreamSubscription<OrganizationEntity>? _sub;

Future<void> watchOrganization(String orgId) async {
  emit(OrganizationLoading());
  await _sub?.cancel();
  _sub = _repo.watchOrganization(orgId).listen(
    (org) => emit(OrganizationLoaded(org)),
    onError: (e) => emit(OrganizationError(e.toString())),
  );
}

@override
Future<void> close() {
  _sub?.cancel();
  return super.close();
}
```

**Defensive form validation** (validate on save, not just on submit):
```dart
final _formKey = GlobalKey<FormState>();

// In save handler:
if (!_formKey.currentState!.validate()) return;
_formKey.currentState!.save();
```
