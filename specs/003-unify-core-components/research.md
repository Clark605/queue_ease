# Research: Unify Core Components & Restructure Project

**Phase**: 0 — Resolved Unknowns & Design Decisions  
**Branch**: `003-unify-core-components`

All decisions below were resolved during the planning session with the project owner. No external package research was needed — this is a pure structural refactor of existing code.

---

## Decision 1 — SnackBar Delivery Mechanism

**Question**: Should the centralized SnackBar use a static utility, a global singleton, or an inherited widget?

**Decision**: Static utility class `AppSnackBar` in `core/utils/`.

**Rationale**: The codebase already uses `ScaffoldMessenger.of(context)` directly at all call sites. A static utility mirrors this pattern without adding a new abstraction layer. It requires no DI registration and is accessible from anywhere that has a `BuildContext`. An inherited widget would add overhead for a concern that is purely presentational.

**Alternatives Considered**:
- `ScaffoldMessenger` global key on `MaterialApp` — rejected; couples the utility to app-level wiring and breaks when multiple navigators are in play.
- Injected service via GetIt — rejected; SnackBar display is a UI side-effect, not a business concern; it should not live in the service graph.

---

## Decision 2 — ErrorView Signature Unification

**Question**: Two `_ErrorView` implementations exist with different signatures. Which wins?

| Source | Has retry button | Title parameterised | Message parameterised |
|--------|-----------------|--------------------|-----------------------|
| `working_hours_body.dart` | ✅ yes (`onRetry` callback) | ❌ hardcoded | ✅ yes |
| `service_list_page.dart` | ❌ no retry | ❌ hardcoded 'Something went wrong' | ✅ yes |

**Decision**: Unified `ErrorView` with an optional `onRetry` callback and an optional `title` parameter with a default value.

```dart
ErrorView({
  required String message,
  String title = 'Something went wrong',
  VoidCallback? onRetry,           // retry button appears only when non-null
})
```

**Rationale**: The retry-capable version is strictly more capable. Making `onRetry` nullable and `title` optional means both existing call sites map to the same widget without any feature-logic changes. The retry `FilledButton` is only constructed when `onRetry != null`.

---

## Decision 3 — FormAppBar and FormActionBar Generalisation

**Question**: `ServiceFormAppBar` uses an `isEditMode` bool to choose between 'Add Service' and 'Edit Service'. `ServiceFormBottomBar` hardcodes 'Save Service'. How should these be generalised?

**Decision**: Replace mode-driven logic with a plain required `title` / `label` parameter.

```dart
// Before
ServiceFormAppBar({required bool isEditMode})   // drives 'Add Service' / 'Edit Service'
ServiceFormBottomBar({required bool isLoading}) // hardcodes 'Save Service'

// After
FormAppBar({required String title, required VoidCallback onBack})
FormActionBar({required String label, required VoidCallback onSave, bool isLoading = false})
```

**Rationale**: The mode logic belongs at the feature level (the call site), not in a generic widget. Passing `title` directly makes the widget reusable for any form in any feature. Call sites update their `isEditMode ? 'Edit Service' : 'Add Service'` ternary in the same commit.

---

## Decision 4 — TimePickerHelper Shape

**Question**: Should `TimePickerHelper` be a static methods class, an extension on `String`/`TimeOfDay`, or a standalone function library?

**Decision**: `abstract final class TimePickerHelper` with four static methods.

```dart
abstract final class TimePickerHelper {
  static TimeOfDay parse(String hhmm) { … }
  static String format(TimeOfDay t) { … }
  static String display(String hhmm) { … }   // returns 12 h AM/PM string
  static Future<TimeOfDay?> pick(BuildContext context, String current) async { … }
}
```

**Rationale**: `abstract final` prevents instantiation and subclassing without requiring a private constructor. The four methods mirror the four private methods currently duplicated across the two widgets, making migration mechanical. An extension on `String` would pollute the `String` API surface for a domain-specific operation.

**Edge case handled**: `parse` must guard against malformed input (e.g. `'25:99'`). Implementation returns `TimeOfDay(hour: 0, minute: 0)` and logs a warning via `AppLogger` when input fails the `HH:MM` pattern check.

---

## Decision 5 — Admin Data Layer Split Strategy

**Question**: Should the shared `ServiceRepository` abstract interface be split into two interfaces, or should admin write ops live behind a separate `AdminServiceRepository`?

**Decision**: Create a separate `AdminServiceRepository` (domain) in `admin/services/domain/repositories/` with only the write methods. The shared `ServiceRepository` retains only `watchServices`. The admin service form Cubit switches its dependency from `ServiceRepository` to `AdminServiceRepository`.

```
ServiceRepository (shared)      → watchServices(orgId)
AdminServiceRepository (admin)  → createService, updateService, deleteService
```

Same split applies to:
- `WorkingHoursRepository` → `AdminWorkingHoursRepository` (saveAllWorkingHours)
- `OrganizationRepository` → `AdminOrganizationRepository` (createOrganization, updateOrganization)

**Rationale**: Splitting into two interfaces is cleaner than making the shared interface carry admin-only methods. It also satisfies FR-009 literally: shared interfaces contain only read operations. The DI registration of the admin impls is self-contained in each admin feature module.

**DI impact**: `AdminServiceRepositoryImpl`, `AdminWorkingHoursRepositoryImpl`, and `AdminOrganizationRepositoryImpl` each annotated `@LazySingleton(as: AdminXxxRepository)`. Running `dart run build_runner build --delete-conflicting-outputs` after Phase 4 regenerates `injection.config.dart` automatically.

---

## Decision 6 — Dashboard Extraction Scope

**Question**: How many private widgets in `admin_dashboard_tab.dart` should be extracted?

**Decision**: Extract only the three largest: `_NowServingCard`, `_ManagementGrid`, and `_ManagementCard`. Leave `_DashboardHeader`, `_StatsStrip`, and `_StatChip` in the same file.

**Rationale**: The spec success criterion SC-006 requires the file to be under 300 lines. Extracting the three largest achieves this. Extracting all six would be useful but is scope creep for a P3 story.

**Target files**:
- `admin/dashboard/presentation/widgets/now_serving_card.dart`
- `admin/dashboard/presentation/widgets/management_grid.dart`
- `admin/dashboard/presentation/widgets/management_card.dart`

---

## Decision 7 — Barrel File Scope

**Question**: Should `core/widgets/widgets.dart` export everything in `core/widgets/`, or be curated?

**Decision**: Export all 10 centralised widgets plus `appFieldDecoration`. Future additions to `core/widgets/` are automatically added to the barrel file at creation time.

**Rationale**: Barrel files in `core/` are the standard pattern in this codebase (confirmed by reviewing `core/theme/` usage). A complete barrel means feature files need only one import: `import 'package:queue_ease/core/widgets/widgets.dart';`.
