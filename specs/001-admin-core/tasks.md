# Tasks: Admin Core — Organization Setup & Service Management

**Branch**: `001-admin-core` | **Sprint**: Sprint 2 | **Tests**: Deferred to Sprint 8  
**Input**: [spec.md](spec.md) · [plan.md](plan.md) · [research.md](research.md) · [data-model.md](data-model.md) · [contracts/](contracts/) · [quickstart.md](quickstart.md) · [ui-screens.md](ui-screens.md)

**Total tasks**: 33 across 7 phases  
**No test tasks** — deferred to Sprint 8 per team decision (see plan.md Constitution Check)

---

## Phase 1: Setup — Module Scaffolding (~20 min)

**Purpose**: Create the new feature module directory structures so file creation in later phases has a clean home.

- [X] T001 [P] Create lib/admin/organization/presentation/{cubit,pages,widgets}/ module directory structure
- [X] T002 [P] Create lib/admin/tutorial/presentation/{cubit,widgets}/ module directory structure

---

## Phase 2: Foundational — Domain Layer (~1.5 hours)

**Purpose**: Core domain types that every user story depends on. No user story work can begin until this phase is complete.

**⚠️ CRITICAL**: UserEntity is imported by AuthCubit, router, and every presentation cubit. Both repository interfaces must exist before any datasource or implementation can reference them.

- [X] T003 Modify UserEntity: remove `orgName: String?`, add `organizationId: String?` and `tutorialCompleted: bool`, update `props` in lib/shared/auth/domain/entities/user_entity.dart
- [X] T004 [P] Create OrganizationRepository interface with `createOrganization`, `watchOrganization`, `updateOrganization`, `getOrganizationByAdminUid` in lib/shared/organization/domain/repositories/organization_repository.dart (see [contracts/organization-repository.md](contracts/organization-repository.md))
- [X] T005 [P] Create ServiceRepository interface with `watchServices`, `createService`, `updateService`, `deleteService` in lib/shared/organization/domain/repositories/service_repository.dart (see [contracts/service-repository.md](contracts/service-repository.md))

**Checkpoint**: Domain layer complete. All four user story phases may now begin.

---

## Phase 3: User Story 1 — Admin Signs Up and Organization Is Created (Priority: P1) 🎯 MVP

**Goal**: Atomic sign-up creates an Organization record and links it to the admin's user profile via `organizationId`. A router guard blocks all admin routes for accounts with no linked org and redirects to a "Complete Your Setup" screen.

**Independent Test**: A new admin signs up → `organizations/{orgId}` document exists in Firestore with `adminUid` matching the user → `users/{uid}.organizationId` equals that orgId → admin lands on dashboard.

- [X] T006 [P] Create FirestoreOrganizationDatasource (`@lazySingleton`, inject `FirebaseFirestore` + `AppLogger`, implement `create` using `WriteBatch`, `watchById`, `update`, `getByAdminUid`, private slug generation helper) in lib/shared/organization/data/datasources/firestore_organization_datasource.dart
- [X] T007 [P] Update FirestoreUserDatasource: replace `orgName` with `organizationId` in `createOrGet` and `_fromDoc`; add `updateOrganizationId(String uid, String organizationId)` method; add `markTutorialCompleted(String uid)` method; add `tutorialCompleted: false` to default map in lib/shared/auth/data/datasources/firestore_user_datasource.dart
- [X] T008 Create OrganizationRepositoryImpl (`@LazySingleton(as: OrganizationRepository)`, inject `FirestoreOrganizationDatasource` + `AppLogger`, validate name ≤100 chars non-empty, wrap in `Result.guard()`) in lib/shared/organization/data/repositories/organization_repository_impl.dart
- [X] T009 Update AuthRepositoryImpl: inject `OrganizationRepository`; after user profile created for admin role, call `organizationRepository.createOrganization(adminUid: uid, name: orgName ?? '')` via WriteBatch; return updated `UserEntity` with `organizationId` in lib/shared/auth/data/repositories/auth_repository_impl.dart
- [X] T010 Add missing-org guard to GoRouter redirect in app_router.dart: if `user.role == admin && user.organizationId == null && location != Routes.adminSetup` → redirect to `/a/setup`; add `Routes.adminSetup = '/a/setup'` constant; add `GoRoute` for `/a/setup` → `OrganizationSetupPage` in lib/core/app/router/app_router.dart
- [X] T011 Create OrganizationSetupPage: single `TextFormField` for org name, submit button, calls `AuthCubit` or dedicated setup flow, loading + error states, redirects to dashboard on success (Stitch baseline: [Organization Landing Screen Variant 3](ui-screens.md#2-organization-landing-screen-variant-3) — simplified) in lib/admin/organization/presentation/pages/organization_setup_page.dart
- [X] T012 Run `flutter pub run build_runner build --delete-conflicting-outputs`; verify `injection.config.dart` includes `OrganizationRepository` and `FirestoreOrganizationDatasource`

**Checkpoint**: New admin sign-up → org created → user linked → dashboard reachable. Accounts with missing org are redirected to `/a/setup`.

---

## Phase 4: User Story 2 — Admin Views and Edits Organization Profile (Priority: P2)

**Goal**: Real-time org profile view and edit. Admin can navigate to profile, see all fields, update name/address/description/logo, and have changes reflected immediately.

**Independent Test**: Signed-in admin navigates to `/a/org/profile` → sees org name from sign-up → edits description → saves → description updates on screen without manual refresh. Saving an empty org name shows a validation error.

- [X] T013 [P] Create OrganizationState (sealed: `OrganizationInitial`, `OrganizationLoading`, `OrganizationLoaded(OrganizationEntity org)`, `OrganizationError(String message)`, extends `Equatable`) in lib/admin/organization/presentation/cubit/organization_state.dart
- [X] T014 [P] Create OrganizationProfileForm widget (reusable form with fields for name, address, description, logo URL; `GlobalKey<FormState>`, field-level validators, `onSaved` callbacks) in lib/admin/organization/presentation/widgets/organization_profile_form.dart
- [X] T015 Create OrganizationCubit (`@injectable`, inject `OrganizationRepository`; `watchOrganization(String orgId)` streams; `updateOrganization(OrganizationEntity org)`; cancel StreamSubscription on `close()`) in lib/admin/organization/presentation/cubit/organization_cubit.dart
- [X] T016 Create OrganizationProfilePage (`BlocBuilder<OrganizationCubit, OrganizationState>`, read-only display of all org fields, FAB/edit button navigates to edit page, Stitch reference: [Organization Landing Screen Variant 3](ui-screens.md#2-organization-landing-screen-variant-3) + [Service Details Modern Grid](ui-screens.md#7-service-details--modern-grid)) in lib/admin/organization/presentation/pages/organization_profile_page.dart
- [X] T017 Create OrganizationProfileEditPage (uses `OrganizationProfileForm`, pre-populates from `OrganizationLoaded` state, save button calls `organizationCubit.updateOrganization`, shows `SnackBar` on success/error) in lib/admin/organization/presentation/pages/organization_profile_edit_page.dart
- [X] T018 Add `/a/org/profile` and `/a/org/edit` routes to `Routes` class and GoRouter; both routes are only reachable when `user.organizationId != null` in lib/core/app/router/app_router.dart

**Checkpoint**: Admin can view and edit org profile with real-time updates. Stories 1 and 2 both testable independently.

---

## Phase 5: User Story 3 — Admin Creates and Manages Services (Priority: P3)

**Goal**: Full service CRUD with a real-time list. Empty-state screen, add form, edit form, swipe-to-delete with confirmation, active/inactive toggle.

**Independent Test**: Admin opens `/a/services` (empty state) → adds service (name + 30 min) → appears in list → edits duration to 45 min → list updates → deletes service with confirmation → list empty again.

- [X] T019 Create FirestoreServiceDatasource (`@lazySingleton`, inject `FirebaseFirestore` + `AppLogger`, subcollection path `organizations/{orgId}/services`, `watchServices` uses `snapshots()` ordered by `createdAt`, `create`, `update`, `delete`) in lib/shared/organization/data/datasources/firestore_service_datasource.dart
- [X] T020 Create ServiceRepositoryImpl (`@LazySingleton(as: ServiceRepository)`, inject `FirestoreServiceDatasource` + `AppLogger`, validate name ≤100 chars non-empty and `durationMinutes > 0`, default `timeMarginMinutes` to 5 if not set, wrap all ops in `Result.guard()`) in lib/shared/organization/data/repositories/service_repository_impl.dart
- [X] T021 [P] Create ServiceState (sealed: `ServiceInitial`, `ServiceLoading`, `ServiceLoaded(List<ServiceEntity> services)`, `ServiceError(String message)`, `ServiceOperationSuccess`, extends `Equatable`) in lib/admin/services/presentation/cubit/service_state.dart
- [X] T022 [P] Create ServiceListTile widget (displays service name, duration badge, active/inactive chip, edit icon button, delete icon button; takes `ServiceEntity` + callbacks) in lib/admin/services/presentation/widgets/service_list_tile.dart
- [X] T023 Create ServiceCubit (`@injectable`, inject `ServiceRepository`; `watchServices(String orgId)`; `createService`, `updateService`, `deleteService`; cancel StreamSubscription on `close()`; emit `ServiceOperationSuccess` after write ops for SnackBar) in lib/admin/services/presentation/cubit/service_cubit.dart
- [X] T024 Create ServiceListPage (`BlocBuilder<ServiceCubit, ServiceState>`, shows empty-state widget when `services.isEmpty`, `ListView` of `ServiceListTile` when loaded, FAB opens `ServiceFormPage`, Stitch references: [Empty State](ui-screens.md#3-services-management--empty-state) + [List](ui-screens.md#4-services-management--list)) in lib/admin/services/presentation/pages/service_list_page.dart
- [X] T025 Create ServiceFormPage (shared add/edit page; optional `ServiceEntity? service` param determines add vs edit mode; fields: name, duration, time margin, price, description, active toggle; save calls `createService` or `updateService`; Stitch references: [Add Form](ui-screens.md#5-add-service-form-variant-2) + [Edit Form](ui-screens.md#6-edit-service-form-variant-1)) in lib/admin/services/presentation/pages/service_form_page.dart
- [X] T026 Add `/a/services` and `/a/services/form` routes to `Routes` class and GoRouter in lib/core/app/router/app_router.dart
- [X] T027 Run `flutter pub run build_runner build --delete-conflicting-outputs`; verify `injection.config.dart` includes `ServiceRepository` and `FirestoreServiceDatasource`

**Checkpoint**: Full service CRUD functional with real-time list. Stories 1, 2, and 3 all testable independently.

---

## Phase 6: User Story 4 — First-Time Setup Tutorial (Priority: P4)

**Goal**: One-time overlay tutorial shown on first dashboard visit. Guides admin through 3 steps (confirm profile → add service → acknowledge ready), skippable at any point, persisted per account via Firestore `tutorialCompleted` field.

**Independent Test**: Freshly registered admin lands on dashboard → tutorial overlay appears at Step 1 → admin advances through all 3 steps → tutorial dismisses with "You're all set" → admin signs out and back in → no tutorial shown.

- [X] T028 [P] Create TutorialState (sealed: `TutorialHidden`, `TutorialActive(TutorialStep step)`, `TutorialCompleted`; `TutorialStep` enum: `confirmProfile`, `addService`, `acknowledgeReady`) in lib/admin/tutorial/presentation/cubit/tutorial_state.dart
- [X] T029 Create TutorialCubit (inject `FirestoreUserDatasource`; `initialize(UserEntity user)` emits `TutorialActive(confirmProfile)` if `!user.tutorialCompleted`; `advance()` progresses steps, on last step calls `markTutorialCompleted` then emits `TutorialCompleted`; `skip()` calls `markTutorialCompleted` + emits `TutorialCompleted`) in lib/admin/tutorial/presentation/cubit/tutorial_cubit.dart
- [X] T030 Create TutorialOverlay widget (`BlocBuilder<TutorialCubit, TutorialState>`; positioned overlay with step title, description text, progress dots, "Next" / "Skip" buttons; uses primary colour `#136dec`, Inter font, 8px radius; visible only when `TutorialActive`; tone reference: customer onboarding screens in [ui-screens.md](ui-screens.md)) in lib/admin/tutorial/presentation/widgets/tutorial_overlay.dart
- [X] T031 Integrate TutorialOverlay into AdminDashboardPage: wrap body with `Stack`, add `BlocBuilder<TutorialCubit, TutorialState>` overlay layer, call `tutorialCubit.initialize(user)` in `initState` / dashboard load in lib/admin/dashboard/presentation/pages/admin_dashboard_page.dart

**Checkpoint**: Tutorial appears on first visit, persists completion, never re-appears. All 4 user stories testable independently.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Wire all cubits at the right scope, run final build_runner, validate the full smoke-test checklist.

- [ ] T032 Provide `OrganizationCubit`, `ServiceCubit`, and `TutorialCubit` via `MultiBlocProvider` at the admin dashboard route level (or router-level `BlocProvider.value` for cubits shared across admin routes); ensure `watchOrganization` and `watchServices` are called after dashboard mounts in lib/core/app/router/app_router.dart (or admin dashboard scaffold)
- [ ] T033 Run final `flutter pub run build_runner build --delete-conflicting-outputs` and walk through the full smoke-test checklist in [quickstart.md Step 12](quickstart.md#step-12--manual-smoke-test-checklist) (15-item manual verification covering sign-up, tutorial, org profile, service CRUD, and missing-org redirect)

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)       → no dependencies
Phase 2 (Foundational) → depends on Phase 1 — BLOCKS all user stories
Phase 3 (US1 P1)      → depends on Phase 2 — no other story deps
Phase 4 (US2 P2)      → depends on Phase 2 — no hard dep on US1 but needs OrganizationRepositoryImpl (T008) for live data
Phase 5 (US3 P3)      → depends on Phase 2 — no hard dep on US1/US2
Phase 6 (US4 P4)      → depends on Phases 3+4+5 being complete (tutorial references org profile and services)
Phase 7 (Polish)      → depends on Phases 3–6
```

### Within-Phase Parallel Opportunities

| Phase | Parallel group |
|---|---|
| Phase 1 | T001 ‖ T002 |
| Phase 2 | T004 ‖ T005 (after T003) |
| Phase 3 | T006 ‖ T007 (after T004/T005); T008 after T006; T009 after T008 |
| Phase 4 | T013 ‖ T014 (after T003); T015 after T013; T016 after T014+T015 |
| Phase 5 | T021 ‖ T022 (after T005); T023 after T021 |
| Phase 6 | T028 first; T029 after T028; T030 after T029; T031 after T030 |

---

## Parallel Execution Snippets

```bash
# Phase 2 — once T003 is done, launch in parallel:
T004: lib/shared/organization/domain/repositories/organization_repository.dart
T005: lib/shared/organization/domain/repositories/service_repository.dart

# Phase 3 — after T004 is done, launch in parallel:
T006: lib/shared/organization/data/datasources/firestore_organization_datasource.dart
T007: lib/shared/auth/data/datasources/firestore_user_datasource.dart  (update)

# Phase 4 — after T003 is done, launch in parallel:
T013: lib/admin/organization/presentation/cubit/organization_state.dart
T014: lib/admin/organization/presentation/widgets/organization_profile_form.dart

# Phase 5 — after T020 is done, launch in parallel:
T021: lib/admin/services/presentation/cubit/service_state.dart
T022: lib/admin/services/presentation/widgets/service_list_tile.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup module directories
2. Phase 2: UserEntity + domain interfaces
3. Phase 3 (US1): Data layer → auth update → router guard → setup page → build_runner
4. **STOP and VALIDATE**: Sign up as new admin → verify org doc + user link → verify `/a/setup` redirect

### Incremental Delivery

| Sprint Stage | What gets delivered |
|---|---|
| After Phase 3 (US1) | Admin sign-up creates org; missing-org guard active; setup page works |
| After Phase 4 (US2) | Org profile view + edit live with real-time stream |
| After Phase 5 (US3) | Full service CRUD with real-time list |
| After Phase 6 (US4) | First-time tutorial overlay persistent per account |
| After Phase 7 | All smoke tests pass; Sprint 2 demo-ready |

---

## Task Count Summary

| Phase | Tasks | Story |
|---|---|---|
| Phase 1: Setup | 2 | — |
| Phase 2: Foundational | 3 | — |
| Phase 3: US1 (P1) | 7 | US1 |
| Phase 4: US2 (P2) | 6 | US2 |
| Phase 5: US3 (P3) | 9 | US3 |
| Phase 6: US4 (P4) | 4 | US4 |
| Phase 7: Polish | 2 | — |
| **Total** | **33** | |
