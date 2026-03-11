# Implementation Plan: Unify Core Components & Restructure Project

**Branch**: `003-unify-core-components` | **Date**: March 11, 2026 | **Spec**: [spec.md](spec.md)  
**Input**: `specs/003-unify-core-components/spec.md`

## Summary

Structural refactor across six concern areas — zero new packages, zero behavioural changes. No new tests are written as part of this spec:

1. **SnackBar centralisation** — Replace 10+ inline `ScaffoldMessenger.showSnackBar` call sites with a static `AppSnackBar` utility in `core/utils/`.
2. **Time picker centralisation** — Extract the identical `_parse`/`_fmt`/`_display`/`_pickTime` methods duplicated in `day_working_hours_tile.dart` and `break_time_section.dart` into a shared `TimePickerHelper` in `core/utils/`.
3. **Widget library** — Move 10 generic widgets (error views, empty states, form components, stepper, avatar, loading button) from feature folders into `core/widgets/` with a barrel export. Rename all to remove feature-specific prefixes.
4. **Theme alignment** — Add `SnackBarThemeData`, `BottomSheetThemeData`, and `DialogThemeData` to `AppTheme`.
5. **Data layer split** — Move admin-only write operations out of `shared/organization/` into `admin/` feature data layers; shared layer retains only entities, read interfaces, and read datasources. Requires `build_runner` regeneration.
6. **Dashboard extraction** — Extract `_NowServingCard`, `_ManagementGrid`, and `_ManagementCard` from `admin_dashboard_tab.dart` into separate widget files, reducing the file to under 300 lines.

## Technical Context

**Language/Version**: Dart 3.9+ / Flutter 3.27+  
**Primary Dependencies**: flutter_bloc 9.1.1+, get_it 8.0.2+, injectable 2.5.0+, go_router 14.6.2+, firebase_core, cloud_firestore, firebase_auth, firebase_crashlytics  
**Storage**: Cloud Firestore  
**Testing**: N/A — no new tests required for this spec  
**Target Platform**: iOS 16+ and Android 6+ (phone primary, tablet secondary)  
**Project Type**: Mobile App — Flutter, Clean Architecture (Data / Domain / Presentation layers)  
**Performance Goals**: Maintain 60 fps; refactor must not introduce additional widget rebuilds  
**Constraints**: No new packages; backward-compatible structural reorganisation only; existing code must compile after import-path updates  
**Scale/Scope**: ~15 screens affected; ~11 unique SnackBar call sites; 10 widgets to centralise; 3 shared datasource files to split

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Requirement | Status | Notes |
|-----------|-------------|--------|-------|
| I — Code Quality | Domain layer has zero Flutter/Firebase imports; Cubit pattern everywhere; `Result<T>` on all async ops | ✅ PASS | New admin domain interfaces follow same pattern; no Flutter imports in domain files |
| II — Flexibility | Extracted widgets accept all customisation via constructor parameters; no hardcoded feature-specific strings | ✅ PASS | `FormAppBar.title`, `FormActionBar.label`, `ErrorView.onRetry`, `EmptyStateView.icon` are all parameterised |
| III — Testing Standards | No new tests required for this spec; existing tests compile after import-path updates | ⚠️ SKIPPED | TDD explicitly skipped per developer decision for this refactor |
| IV — UX Consistency | All centralised widgets use `AppColors` + `AppTextStyles`; SnackBar/BottomSheet/Dialog themes added to `AppTheme` | ✅ PASS | No inline colour literals in centralised widgets |
| V — Fast Delivery | Six independent phases; each phase is independently mergeable and does not block the next | ✅ PASS | Phase ordering minimises risk: utilities → widgets → theme → data → dashboard |
| VI — Performance | `const` constructors throughout new widgets; no `setState` inside logic; `ListView.builder` preserved for all lists | ✅ PASS | New widgets all use `const` constructors; no widget-tree regressions introduced |

**Gate result: PASS — proceeding to Phase 0 research.**

## Project Structure

### Documentation (this feature)

```text
specs/003-unify-core-components/
├── plan.md              # This file
├── research.md          # Phase 0 — design decisions + resolved unknowns
├── data-model.md        # Phase 1 — widget API contracts + data-layer split design
├── quickstart.md        # Phase 1 — developer guide for new core components
├── contracts/
│   └── widget-api.md    # Phase 1 — full public constructor API for each widget
├── checklists/
│   └── requirements.md  # Existing requirements checklist (all items pass)
└── tasks.md             # Phase 2 — implementation tasks (created by /speckit.tasks)
```

### Source Code Layout (state after refactor completes)

```text
lib/
├── core/
│   ├── utils/
│   │   ├── app_logger.dart                        # existing — unchanged
│   │   ├── app_snack_bar.dart                     # NEW — AppSnackBar static utility
│   │   └── time_picker_helper.dart                # NEW — parse / format / display / pick
│   ├── widgets/
│   │   ├── widgets.dart                           # NEW — barrel export
│   │   ├── error_view.dart                        # NEW — unified ErrorView
│   │   ├── empty_state_view.dart                  # NEW — EmptyStateView
│   │   ├── initials_avatar.dart                   # NEW — InitialsAvatar
│   │   ├── numeric_stepper_row.dart               # NEW — NumericStepperRow
│   │   ├── form_field_label.dart                  # NEW — FormFieldLabel
│   │   ├── form_card.dart                         # NEW — FormCard
│   │   ├── form_app_bar.dart                      # NEW — FormAppBar
│   │   ├── form_action_bar.dart                   # NEW — FormActionBar
│   │   ├── loading_button.dart                    # NEW — LoadingButton
│   │   └── app_field_decoration.dart              # NEW — appFieldDecoration() function
│   └── theme/
│       ├── app_colors.dart                        # existing — unchanged
│       ├── app_text_styles.dart                   # existing — unchanged
│       └── app_theme.dart                         # UPDATED — +snackBarTheme, +bottomSheetTheme, +dialogTheme
│
├── admin/
│   ├── services/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── admin_service_repository.dart  # NEW — write-only abstract interface
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── admin_service_datasource.dart  # NEW — create / update / delete (moved from shared)
│   │       └── repositories/
│   │           └── admin_service_repository_impl.dart  # NEW — @LazySingleton(as: AdminServiceRepository)
│   │
│   ├── working_hours/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── admin_working_hours_repository.dart  # NEW — saveAllWorkingHours interface
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── admin_working_hours_datasource.dart  # NEW — saveAll (moved from shared)
│   │       └── repositories/
│   │           └── admin_working_hours_repository_impl.dart  # NEW — @LazySingleton(as: AdminWorkingHoursRepository)
│   │
│   ├── organization/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── admin_organization_repository.dart  # NEW — createOrganization / updateOrganization
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── admin_organization_datasource.dart  # NEW — write ops (moved from shared)
│   │       └── repositories/
│   │           └── admin_organization_repository_impl.dart  # NEW — @LazySingleton(as: AdminOrganizationRepository)
│   │
│   └── dashboard/
│       └── presentation/
│           └── widgets/
│               ├── now_serving_card.dart          # NEW — extracted from admin_dashboard_tab.dart
│               ├── management_grid.dart           # NEW — extracted from admin_dashboard_tab.dart
│               └── management_card.dart           # NEW — extracted from admin_dashboard_tab.dart
│
└── shared/
    └── organization/
        ├── domain/
        │   └── repositories/
        │       ├── service_repository.dart        # UPDATED — watchServices only (write methods removed)
        │       ├── working_hours_repository.dart  # UPDATED — watchWorkingHours only (saveAll removed)
        │       └── organization_repository.dart   # UPDATED — watchOrganization + getByAdminUid only
        └── data/
            ├── datasources/
            │   ├── firestore_service_datasource.dart           # UPDATED — watchServices only
            │   ├── firestore_working_hours_datasource.dart     # UPDATED — watchWorkingHours only
            │   └── firestore_organization_datasource.dart      # UPDATED — read ops only
            └── repositories/
                ├── service_repository_impl.dart                # UPDATED — watchServices only
                ├── working_hours_repository_impl.dart          # UPDATED — watchWorkingHours only
                └── organization_repository_impl.dart           # UPDATED — read ops only
```

**Structure Decision**: Flutter Clean Architecture mobile layout. Write operations for each admin feature live exclusively in that feature's data layer. Shared layer provides entity types, read-only domain interfaces, and read-only Firestore datasources used by both admin and customer presenters.

`core/di/injection.config.dart` is regenerated via `dart run build_runner build --delete-conflicting-outputs` after Phase 4 changes.

## Complexity Tracking

> No constitution violations. This refactor reduces complexity — no justification table needed.
