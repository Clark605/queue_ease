# Tasks: Unify Core Components & Restructure Project

**Input**: `specs/003-unify-core-components/` — plan.md, spec.md, data-model.md, contracts/widget-api.md, research.md, quickstart.md  
**Branch**: `003-unify-core-components`  
**Tests**: None — TDD explicitly skipped for this spec

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks in the same phase)
- **[Story]**: User story label ([US1]–[US6])
- No story label = Setup or Polish phase

---

## Phase 1: Setup

**Purpose**: Create the `core/widgets/` directory and empty barrel file so all US3 widget files have a home.

- [X] T001 Create empty barrel file at `lib/core/widgets/widgets.dart` (no exports yet — populated in US3)

**Checkpoint**: `lib/core/widgets/` directory exists.

---

## Phase 2: User Story 1 — AppSnackBar (Priority: P1) 🎯 MVP

**Goal**: Replace all inline `ScaffoldMessenger.showSnackBar` calls across the codebase with `AppSnackBar`.

**Verify**: Search for `ScaffoldMessenger.of(context).showSnackBar` — zero matches outside `app_snack_bar.dart`.

- [X] T002 [US1] Create `lib/core/utils/app_snack_bar.dart` — `abstract final class AppSnackBar` with four static methods: `showSuccess`, `showError`, `showWarning`, `showInfo`; each calls `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(...)` with `SnackBarBehavior.floating`, rounded corners (radius 8), and the matching `AppColors.*` background
- [X] T003 [P] [US1] Replace inline SnackBar call in `lib/admin/dashboard/presentation/pages/admin_dashboard_tab.dart` with `AppSnackBar.*`
- [X] T004 [P] [US1] Replace all 6 inline SnackBar calls in `lib/admin/presentation/pages/settings_page.dart` with `AppSnackBar.*`
- [X] T005 [P] [US1] Replace inline SnackBar calls and local `_showSnackBar` helper in `lib/admin/working_hours/presentation/pages/working_hours_page.dart` with `AppSnackBar.*`
- [X] T006 [P] [US1] Replace inline SnackBar calls in `lib/admin/services/presentation/pages/service_form_page.dart` with `AppSnackBar.*`
- [X] T007 [P] [US1] Replace inline SnackBar calls in `lib/admin/organization/presentation/pages/organization_profile_edit_page.dart` with `AppSnackBar.*`
- [X] T008 [P] [US1] Replace inline SnackBar call in `lib/admin/queue_management/presentation/pages/queue_management_page.dart` with `AppSnackBar.*`
- [X] T009 [P] [US1] Replace inline SnackBar call in `lib/shared/auth/presentation/widgets/forgot_password_bottom_sheet.dart` with `AppSnackBar.*`

> **Note**: T003–T009 are parallel with each other (different files) but all depend on T002.

**Checkpoint**: Zero inline SnackBar calls remain outside `app_snack_bar.dart`.

---

## Phase 3: User Story 2 — TimePickerHelper (Priority: P1)

**Goal**: Extract duplicated `_parse`/`_fmt`/`_display`/`_pickTime` methods into a shared helper.

**Verify**: Search for `_parse` and `_fmt` in `admin/working_hours/presentation/widgets/` — zero results.

- [X] T010 [US2] Create `lib/core/utils/time_picker_helper.dart` — `abstract final class TimePickerHelper` with four static methods: `parse(String hhmm) → TimeOfDay`, `format(TimeOfDay t) → String`, `display(String hhmm) → String` (12h AM/PM), `pick(BuildContext context, String current) → Future<TimeOfDay?>`; add malformed-input guard in `parse` (log warning, return `TimeOfDay(hour:0, minute:0)`)
- [X] T011 [P] [US2] Update `lib/admin/working_hours/presentation/widgets/day_working_hours_tile.dart` — replace local `_parse`, `_fmt`, `_display`, `_pickTime` implementations with calls to `TimePickerHelper.*`; delete the four private methods
- [X] T012 [P] [US2] Update `lib/admin/working_hours/presentation/widgets/break_time_section.dart` — replace local `_parse`, `_fmt`, `_display`, `_pickTime` implementations with calls to `TimePickerHelper.*`; delete the four private methods

> **Note**: T011 and T012 are parallel (different files) but both depend on T010.

**Checkpoint**: Both widget files import `TimePickerHelper`; no local time parsing logic remains.

---

## Phase 4: User Story 3 — Widget Centralization (Priority: P1)

**Goal**: Create 10 reusable widgets in `core/widgets/`, update all consumers, delete original feature-specific implementations.

**Verify**: `core/widgets/` contains 10 widget files + barrel; `service_form_shared.dart`, `service_form_app_bar.dart`, `service_form_bottom_bar.dart`, `service_stepper_row.dart` are deleted.

### Create core widgets (all parallel)

- [X] T013 [P] [US3] Create `lib/core/widgets/error_view.dart` — `ErrorView({required String message, String title = 'Something went wrong', VoidCallback? onRetry})`; retry `FilledButton` rendered only when `onRetry != null`; icon `Icons.error_outline` size 64 `AppColors.error`
- [X] T014 [P] [US3] Create `lib/core/widgets/empty_state_view.dart` — `EmptyStateView({required IconData icon, required String title, required String subtitle, String? actionLabel, VoidCallback? onAction})`; add `assert((actionLabel == null) == (onAction == null))`; CTA is `FilledButton.icon` shown only when both are non-null
- [X] T015 [P] [US3] Create `lib/core/widgets/initials_avatar.dart` — `InitialsAvatar({required String name, double size = 40, Color? backgroundColor, Color? textColor})`; split name on whitespace, take first char of first two words, uppercase; returns `'?'` for empty name
- [X] T016 [P] [US3] Create `lib/core/widgets/numeric_stepper_row.dart` — `NumericStepperRow({required IconData icon, required String title, String? subtitle, required int value, required String unit, VoidCallback? onDecrement, VoidCallback? onIncrement})`; leading 40×40 primary-bg icon container; bordered square stepper buttons disabled when callback is null
- [X] T017 [P] [US3] Create `lib/core/widgets/form_field_label.dart` — `FormFieldLabel({required String text})`; `bodySmall`, `w600`, `AppColors.onSurfaceVariant`
- [X] T018 [P] [US3] Create `lib/core/widgets/form_card.dart` — `FormCard({required Widget child, EdgeInsetsGeometry? padding})`; `Border.all(outline.withValues(alpha:0.5))`, single-item box shadow, `borderRadius:12`, default padding `EdgeInsets.all(16)`
- [X] T019 [P] [US3] Create `lib/core/widgets/form_app_bar.dart` — `FormAppBar({required String title, required VoidCallback onBack}) implements PreferredSizeWidget`; `preferredSize = Size.fromHeight(kToolbarHeight + 1)`; bottom `PreferredSize` divider line; back `IconButton`
- [X] T020 [P] [US3] Create `lib/core/widgets/form_action_bar.dart` — `FormActionBar({required String label, required VoidCallback? onSave, bool isLoading = false})`; top border container; respects `MediaQuery.of(context).padding.bottom` safe area; `isLoading` shows `CircularProgressIndicator(strokeWidth:2)` instead of label
- [X] T021 [P] [US3] Create `lib/core/widgets/loading_button.dart` — `LoadingButton({required String label, required VoidCallback? onPressed, bool isLoading = false})`; `SizedBox(width: double.infinity)` wrapping `FilledButton`; `isLoading` shows `CircularProgressIndicator(strokeWidth:2)`
- [X] T022 [P] [US3] Create `lib/core/widgets/app_field_decoration.dart` — top-level function `InputDecoration appFieldDecoration({required String hintText})`; all 5 border states (`border`, `enabledBorder`, `focusedBorder`, `errorBorder`, `focusedErrorBorder`) using `OutlineInputBorder(borderRadius:8)` with `AppColors.*` colours

### Populate barrel file

- [X] T023 [US3] Add exports for all 10 widgets/functions to `lib/core/widgets/widgets.dart` (depends on T013–T022)

### Update consumers (all parallel, depend on T023)

- [X] T024 [P] [US3] Update `lib/admin/working_hours/presentation/widgets/working_hours_body.dart` — replace `_SaveButton` with `LoadingButton`, replace `_ErrorView` with `ErrorView(title: 'Failed to load working hours', ...)`; delete both private classes
- [X] T025 [P] [US3] Update `lib/admin/services/presentation/pages/service_list_page.dart` — replace `_EmptyStateView` with `EmptyStateView(icon: Icons.medical_services_outlined, ...)`; replace `_ErrorView` with `ErrorView(...)`; delete both private classes
- [X] T026 [P] [US3] Update `lib/admin/services/presentation/widgets/service_list_tile.dart` — replace `_InitialsAvatar` usages with `InitialsAvatar(name: ...)`; delete the `_InitialsAvatar` private class
- [X] T027 [P] [US3] Update `lib/admin/services/presentation/pages/service_form_page.dart` — replace `ServiceFormAppBar(isEditMode: ...)` with `FormAppBar(title: cubit.isEditMode ? 'Edit Service' : 'Add Service', onBack: context.pop)`; replace `ServiceFormBottomBar` with `FormActionBar(label: 'Save Service', ...)`; replace `ServiceFieldLabel`→`FormFieldLabel`, `ServiceFormCard`→`FormCard`, `serviceFieldDecoration`→`appFieldDecoration`, `ServiceStepperRow`→`NumericStepperRow`; update imports

### Delete old source files (all parallel, depend on T027)

- [X] T028 [P] [US3] Delete `lib/admin/services/presentation/widgets/service_form_shared.dart`
- [X] T029 [P] [US3] Delete `lib/admin/services/presentation/widgets/service_form_app_bar.dart`
- [X] T030 [P] [US3] Delete `lib/admin/services/presentation/widgets/service_form_bottom_bar.dart`
- [X] T031 [P] [US3] Delete `lib/admin/services/presentation/widgets/service_stepper_row.dart`

**Checkpoint**: `lib/core/widgets/` has 10 dart files + barrel; no `Service`-prefixed widget classes remain in feature folders.

---

## Phase 5: User Story 4 — Theme Alignment (Priority: P2)

**Goal**: Add `SnackBarThemeData`, `BottomSheetThemeData`, `DialogThemeData` to `AppTheme`; remove any inline overrides.

**Verify**: `showModalBottomSheet` and `showDialog` call sites have no explicit `backgroundColor` or `shape` overrides.

- [ ] T032 [US4] Update `lib/core/theme/app_theme.dart` — add `snackBarTheme` (`behavior: floating`, `shape: RoundedRectangleBorder(radius:8)`, `contentTextStyle: white bodyMedium`), `bottomSheetTheme` (top corners radius 16, `backgroundColor: AppColors.surface`), and `dialogTheme` (`shape: RoundedRectangleBorder(radius:12)`, `elevation:3`, `backgroundColor: AppColors.surface`) to the `ThemeData` builder
- [ ] T033 [P] [US4] Audit all `showModalBottomSheet` call sites — remove any explicit `backgroundColor`, `shape`, or `elevation` parameters that duplicate the new theme defaults
- [ ] T034 [P] [US4] Audit all `showDialog` call sites — remove any explicit `backgroundColor` or `shape` parameters that duplicate the new theme defaults

> **Note**: T033 and T034 are parallel (different search scope) but both depend on T032.

**Checkpoint**: Zero `showModalBottomSheet` or `showDialog` calls override styles already defined in `AppTheme`.

---

## Phase 6: User Story 5 — Admin Data Layer Split (Priority: P2)

**Goal**: Move admin-specific write operations out of `shared/organization/` into `admin/` feature data layers.

**Verify**: `shared/organization/` datasources and repositories contain no `create`, `update`, `delete`, or `saveAll` methods.

### Create admin domain interfaces (all parallel)

- [ ] T035 [P] [US5] Create `lib/admin/services/domain/repositories/admin_service_repository.dart` — `abstract class AdminServiceRepository` with `createService`, `updateService`, `deleteService` matching signatures from `contracts/widget-api.md`
- [ ] T036 [P] [US5] Create `lib/admin/working_hours/domain/repositories/admin_working_hours_repository.dart` — `abstract class AdminWorkingHoursRepository` with `saveAllWorkingHours`
- [ ] T037 [P] [US5] Create `lib/admin/organization/domain/repositories/admin_organization_repository.dart` — `abstract class AdminOrganizationRepository` with `createOrganization`, `updateOrganization`

### Create admin datasources (all parallel, depend on T035–T037)

- [ ] T038 [P] [US5] Create `lib/admin/services/data/datasources/admin_service_datasource.dart` — copy `create`, `update`, `delete` methods from `lib/shared/organization/data/datasources/firestore_service_datasource.dart`; add `@lazySingleton`
- [ ] T039 [P] [US5] Create `lib/admin/working_hours/data/datasources/admin_working_hours_datasource.dart` — copy `saveAll` method from `lib/shared/organization/data/datasources/firestore_working_hours_datasource.dart`; add `@lazySingleton`
- [ ] T040 [P] [US5] Create `lib/admin/organization/data/datasources/admin_organization_datasource.dart` — copy `create` and `update` write methods from `lib/shared/organization/data/datasources/firestore_organization_datasource.dart`; add `@lazySingleton`

### Create admin repository implementations (all parallel, depend on T035–T040)

- [ ] T041 [P] [US5] Create `lib/admin/services/data/repositories/admin_service_repository_impl.dart` — `@LazySingleton(as: AdminServiceRepository)` implementing `AdminServiceRepository`; inject `AdminServiceDatasource`; move `_validate` and `_applyDefaults` helpers from `ServiceRepositoryImpl`
- [ ] T042 [P] [US5] Create `lib/admin/working_hours/data/repositories/admin_working_hours_repository_impl.dart` — `@LazySingleton(as: AdminWorkingHoursRepository)` implementing `AdminWorkingHoursRepository`; inject `AdminWorkingHoursDatasource`; move validation helpers from `WorkingHoursRepositoryImpl`
- [ ] T043 [P] [US5] Create `lib/admin/organization/data/repositories/admin_organization_repository_impl.dart` — `@LazySingleton(as: AdminOrganizationRepository)` implementing `AdminOrganizationRepository`; inject `AdminOrganizationDatasource`

### Strip write operations from shared layer (all parallel, depend on T038–T043)

- [ ] T044 [P] [US5] Update `lib/shared/organization/domain/repositories/service_repository.dart` — remove `createService`, `updateService`, `deleteService` abstract methods; keep `watchServices` only
- [ ] T045 [P] [US5] Update `lib/shared/organization/domain/repositories/working_hours_repository.dart` — remove `saveAllWorkingHours` abstract method; keep `watchWorkingHours` only
- [ ] T046 [P] [US5] Update `lib/shared/organization/domain/repositories/organization_repository.dart` — remove `createOrganization`, `updateOrganization` abstract methods; keep `watchOrganization` and `getByAdminUid`
- [ ] T047 [P] [US5] Update `lib/shared/organization/data/datasources/firestore_service_datasource.dart` — delete `create`, `update`, `delete` methods; keep `watchServices` only
- [ ] T048 [P] [US5] Update `lib/shared/organization/data/datasources/firestore_working_hours_datasource.dart` — delete `saveAll` method; keep `watchWorkingHours` only
- [ ] T049 [P] [US5] Update `lib/shared/organization/data/datasources/firestore_organization_datasource.dart` — delete write methods; keep read methods only
- [ ] T050 [P] [US5] Update `lib/shared/organization/data/repositories/service_repository_impl.dart` — remove `createService`, `updateService`, `deleteService` implementations and `_validate`/`_applyDefaults` helpers (moved to `AdminServiceRepositoryImpl`)
- [ ] T051 [P] [US5] Update `lib/shared/organization/data/repositories/working_hours_repository_impl.dart` — remove `saveAllWorkingHours` implementation
- [ ] T052 [P] [US5] Update `lib/shared/organization/data/repositories/organization_repository_impl.dart` — remove `createOrganization`, `updateOrganization` implementations

### Update admin Cubits to inject admin repositories (all parallel, depend on T041–T043)

- [ ] T053 [P] [US5] Update service write Cubit(s) in `lib/admin/services/presentation/cubits/` — replace `ServiceRepository` injections used for write ops with `AdminServiceRepository`; `ServiceRepository` injection for `watchServices` remains
- [ ] T054 [P] [US5] Update working hours Cubit in `lib/admin/working_hours/presentation/cubits/` — replace `WorkingHoursRepository.saveAllWorkingHours` call with `AdminWorkingHoursRepository.saveAllWorkingHours`; `WorkingHoursRepository` injection for `watchWorkingHours` remains
- [ ] T055 [P] [US5] Update organization Cubit(s) in `lib/admin/organization/presentation/cubits/` — replace `OrganizationRepository` write method calls with `AdminOrganizationRepository`; read calls remain on `OrganizationRepository`

### Regenerate DI

- [ ] T056 [US5] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/core/di/injection.config.dart` with the three new `@LazySingleton` registrations (depends on T041–T043)

**Checkpoint**: `flutter analyze` passes; `injection.config.dart` registers `AdminServiceRepositoryImpl`, `AdminWorkingHoursRepositoryImpl`, `AdminOrganizationRepositoryImpl`.

---

## Phase 7: User Story 6 — Dashboard Extraction (Priority: P3)

**Goal**: Reduce `admin_dashboard_tab.dart` to under 300 lines by extracting the three largest nested widgets.

**Verify**: `wc -l admin_dashboard_tab.dart` (or IDE line count) shows ≤ 300; dashboard renders identically.

- [ ] T057 [P] [US6] Create `lib/admin/dashboard/presentation/widgets/management_card.dart` — extract `_ManagementCard` private class from `admin_dashboard_tab.dart` into a public `ManagementCard` widget
- [ ] T058 [P] [US6] Create `lib/admin/dashboard/presentation/widgets/now_serving_card.dart` — extract `_NowServingCard` and its dependent `_QueueActionButton` private class into `NowServingCard` widget file

> **Note**: T057 and T058 are parallel (independent widgets).

- [ ] T059 [US6] Create `lib/admin/dashboard/presentation/widgets/management_grid.dart` — extract `_ManagementGrid` into `ManagementGrid` widget; import `ManagementCard` from T057 (depends on T057)
- [ ] T060 [US6] Update `lib/admin/dashboard/presentation/pages/admin_dashboard_tab.dart` — delete the four extracted private classes (`_NowServingCard`, `_QueueActionButton`, `_ManagementGrid`, `_ManagementCard`); add imports for the three new widget files; verify file is ≤ 300 lines (depends on T057–T059)

**Checkpoint**: `admin_dashboard_tab.dart` ≤ 300 lines; dashboard compiles and renders identically.

---

## Phase 8: Polish

**Purpose**: Final compile and analysis verification across all changes.

- [ ] T061 Run `flutter analyze --no-fatal-infos` and resolve all errors and warnings introduced by this refactor
- [ ] T062 [P] Run `flutter build apk --debug` (or equivalent) to confirm full build succeeds end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phases 2–4 (US1, US2, US3)**: Depend on Phase 1; independent of each other — can run in parallel
- **Phase 5 (US4)**: Independent — can run in parallel with US1–US3
- **Phase 6 (US5)**: Independent — can run in parallel with US1–US4; `build_runner` (T056) runs after all admin files are created
- **Phase 7 (US6)**: Independent — can run at any point after Phase 1
- **Phase 8 (Polish)**: Depends on all preceding phases being complete

### User Story Dependencies

| Story | Depends On | Can Parallelise With |
|-------|-----------|----------------------|
| US1 | T001 (Setup) | US2, US3, US4, US5, US6 |
| US2 | T001 (Setup) | US1, US3, US4, US5, US6 |
| US3 | T001 (Setup) | US1, US2, US4, US5, US6 |
| US4 | T001 (Setup) | US1, US2, US3, US5, US6 |
| US5 | T001 (Setup) | US1, US2, US3, US4, US6 |
| US6 | T001 (Setup) | US1, US2, US3, US4, US5 |

### Key Intra-Phase Dependencies

- **US1**: T002 → T003–T009 (all consumer updates parallel after utility exists)
- **US2**: T010 → T011, T012 (both consumer updates parallel after helper exists)
- **US3**: T013–T022 (parallel) → T023 (barrel) → T024–T027 (parallel consumers) → T028–T031 (parallel deletions)
- **US4**: T032 → T033, T034 (parallel audits after theme updated)
- **US5**: T035–T037 (parallel) + T038–T040 (parallel) → T041–T043 (parallel impls) → T044–T055 (parallel strip + cubit updates) → T056 (build_runner)
- **US6**: T057, T058 (parallel) → T059 → T060

---

## Parallel Execution Examples

### Running US1 (SnackBar) and US2 (TimePickerHelper) simultaneously

```
[Agent A]                          [Agent B]
T002 Create AppSnackBar            T010 Create TimePickerHelper
T003–T009 Update call sites        T011–T012 Update both tiles
```

### Running all US3 widget creations in one batch

```
T013 ErrorView     T014 EmptyStateView    T015 InitialsAvatar
T016 NumericStepperRow   T017 FormFieldLabel   T018 FormCard
T019 FormAppBar    T020 FormActionBar     T021 LoadingButton
T022 appFieldDecoration
     ↓ (all complete)
T023 Populate barrel
     ↓
T024–T027 Consumer updates (parallel)
     ↓ (all complete)
T028–T031 Delete old files (parallel)
```

### Running US5 admin domain files in one batch

```
T035 AdminServiceRepository    T036 AdminWorkingHoursRepository    T037 AdminOrganizationRepository
T038 AdminServiceDatasource    T039 AdminWHDatasource               T040 AdminOrgDatasource
     ↓ (all complete)
T041 AdminServiceRepoImpl      T042 AdminWHRepoImpl                 T043 AdminOrgRepoImpl
     ↓ (all complete)
T044–T055 Strip shared + update Cubits (all parallel)
     ↓ (all complete)
T056 build_runner
```

---

## Implementation Strategy

**Suggested MVP**: Complete US1 + US2 + US3 first — these are all P1 and can be merged independently. US4 (theme) is a small follow-up. US5 (data split) is the highest-risk phase due to DI regeneration — tackle it last among P2 stories. US6 (dashboard) is a nice-to-have P3 improvement.

**Risk mitigation for US5**: Create all new admin files and verify they compile before stripping the shared layer. This way, if a step fails, the shared layer is still intact and the app remains functional.

---

## Summary

| Phase | Story | Priority | Tasks | Key Files |
|-------|-------|----------|-------|-----------|
| 1 | Setup | — | T001 | `core/widgets/widgets.dart` |
| 2 | US1 AppSnackBar | P1 🎯 | T002–T009 | `core/utils/app_snack_bar.dart` + 7 call sites |
| 3 | US2 TimePickerHelper | P1 | T010–T012 | `core/utils/time_picker_helper.dart` + 2 tiles |
| 4 | US3 Widget Library | P1 | T013–T031 | 10 new core widgets + 4 consumers + 4 deletions |
| 5 | US4 Theme | P2 | T032–T034 | `core/theme/app_theme.dart` + 2 audits |
| 6 | US5 Data Split | P2 | T035–T056 | 9 new admin files + shared layer strip + build_runner |
| 7 | US6 Dashboard | P3 | T057–T060 | 3 new widget files + `admin_dashboard_tab.dart` |
| 8 | Polish | — | T061–T062 | `flutter analyze` + full build |
| **Total** | | | **62 tasks** | |
