# Data Model: Unify Core Components & Restructure Project

**Phase**: 1 — Design & Contracts  
**Branch**: `003-unify-core-components`

---

## 1. Core Utility Entities

### `AppSnackBar` (`lib/core/utils/app_snack_bar.dart`)

Static utility — no instantiation, no state.

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `showSuccess` | `static void showSuccess(BuildContext context, String message)` | Floating SnackBar, `AppColors.success` background |
| `showError` | `static void showError(BuildContext context, String message)` | Floating SnackBar, `AppColors.error` background |
| `showWarning` | `static void showWarning(BuildContext context, String message)` | Floating SnackBar, `AppColors.warning` background |
| `showInfo` | `static void showInfo(BuildContext context, String message)` | Floating SnackBar, `AppColors.info` background |

**Internal behaviour** (all four methods share): Calls `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(...))` with `behavior: SnackBarBehavior.floating`, `shape: RoundedRectangleBorder(borderRadius: 8)`, white text, and the relevant `AppColors.*` background.

---

### `TimePickerHelper` (`lib/core/utils/time_picker_helper.dart`)

Static utility — `abstract final class`, no instantiation.

| Method | Signature | Source | Behaviour |
|--------|-----------|--------|-----------|
| `parse` | `static TimeOfDay parse(String hhmm)` | `_parse` in both widget files | Splits on `':'`, returns `TimeOfDay(hour, minute)`. Returns `TimeOfDay(hour:0, minute:0)` and logs warning if malformed. |
| `format` | `static String format(TimeOfDay t)` | `_fmt` in both widget files | Pads to `HH:MM` (`padLeft(2, '0')`). |
| `display` | `static String display(String hhmm)` | `_display` in both widget files | Converts 24h `HH:MM` to 12h `h:mm AM/PM` string for UI display. |
| `pick` | `static Future<TimeOfDay?> pick(BuildContext context, String current)` | `_pickTime` in both widget files | Shows `showTimePicker` with `initialTime: parse(current)`. Returns `null` on cancel. |

---

## 2. Core Widget Entities

Each widget lives in `lib/core/widgets/` and is exported from `lib/core/widgets/widgets.dart`.

### `ErrorView` (`error_view.dart`)

Unified from two divergent implementations.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `message` | `String` | ✅ | — | Detail text below the title |
| `title` | `String` | ❌ | `'Something went wrong'` | Heading above message |
| `onRetry` | `VoidCallback?` | ❌ | `null` | When non-null, shows a `FilledButton('Retry')` |

**Layout**: `Center → Column` — `Icon(Icons.error_outline, size:64, color:AppColors.error)` → title → message → conditional retry button.

---

### `EmptyStateView` (`empty_state_view.dart`)

Extracted from `service_list_page.dart`, parameterised.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `icon` | `IconData` | ✅ | — | Icon shown inside circle container |
| `title` | `String` | ✅ | — | Bold heading |
| `subtitle` | `String` | ✅ | — | Secondary description |
| `actionLabel` | `String?` | ❌ | `null` | Label for the CTA button |
| `onAction` | `VoidCallback?` | ❌ | `null` | Callback for the CTA button; button shown only when both `actionLabel` and `onAction` are non-null |

**Layout**: `Center → Column` — circle container(64, `Colors.grey.shade100`) with `Icon` → title → subtitle → optional `FilledButton.icon`.

---

### `InitialsAvatar` (`initials_avatar.dart`)

Extracted from `_InitialsAvatar` in `service_list_tile.dart`.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `name` | `String` | ✅ | — | Full name; initials extracted automatically |
| `size` | `double` | ❌ | `40` | Diameter of the circle |
| `backgroundColor` | `Color?` | ❌ | `AppColors.primaryLight` | Circle background |
| `textColor` | `Color?` | ❌ | `AppColors.onPrimary` | Initials text colour |

**Initials logic**: Split on whitespace, take first character of first two words, uppercase. Returns `'?'` for empty name.

---

### `NumericStepperRow` (`numeric_stepper_row.dart`)

Extracted from `ServiceStepperRow` + `_StepperButton` in `service_stepper_row.dart`.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `icon` | `IconData` | ✅ | — | Leading icon in 40×40 primary-bg container |
| `title` | `String` | ✅ | — | Primary label |
| `subtitle` | `String?` | ❌ | `null` | Secondary label |
| `value` | `int` | ✅ | — | Current numeric value |
| `unit` | `String` | ✅ | — | Unit label (e.g. `'min'`) |
| `onDecrement` | `VoidCallback?` | ❌ | `null` | Decrement tap; button disabled when null |
| `onIncrement` | `VoidCallback?` | ❌ | `null` | Increment tap; button disabled when null |

---

### `FormFieldLabel` (`form_field_label.dart`)

Extracted from `ServiceFieldLabel` in `service_form_shared.dart`.

| Property | Type | Required | Notes |
|----------|------|----------|-------|
| `text` | `String` | ✅ | Displayed in `bodySmall`, `w600`, `AppColors.onSurfaceVariant` |

---

### `FormCard` (`form_card.dart`)

Extracted from `ServiceFormCard` in `service_form_shared.dart`.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `child` | `Widget` | ✅ | — | Content |
| `padding` | `EdgeInsetsGeometry?` | ❌ | `EdgeInsets.all(16)` | Inner padding |

**Style**: `Border.all(outline.withValues(alpha:0.5))`, single-item box shadow, `borderRadius: 12`.

---

### `FormAppBar` (`form_app_bar.dart`)

Extracted from `ServiceFormAppBar`, generalised.

| Property | Type | Required | Notes |
|----------|------|----------|-------|
| `title` | `String` | ✅ | AppBar title text |
| `onBack` | `VoidCallback` | ✅ | Leading back button callback |

**Implements** `PreferredSizeWidget`; `preferredSize = Size.fromHeight(kToolbarHeight + 1)`. Bottom border rendered via `PreferredSize` child.

---

### `FormActionBar` (`form_action_bar.dart`)

Extracted from `ServiceFormBottomBar`, label made required.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `label` | `String` | ✅ | — | Button label (was hardcoded 'Save Service') |
| `onSave` | `VoidCallback?` | ✅ | — | Save callback; null disables the button |
| `isLoading` | `bool` | ❌ | `false` | Shows spinner instead of label |

**Style**: Top border, respects `MediaQuery.of(context).padding.bottom` for safe area.

---

### `LoadingButton` (`loading_button.dart`)

Extracted from `_SaveButton` in `working_hours_body.dart`.

| Property | Type | Required | Default | Notes |
|----------|------|----------|---------|-------|
| `label` | `String` | ✅ | — | Button text |
| `onPressed` | `VoidCallback?` | ✅ | — | Tap callback; null disables |
| `isLoading` | `bool` | ❌ | `false` | Shows `CircularProgressIndicator(strokeWidth:2)` |

**Layout**: `SizedBox(width: double.infinity) → FilledButton`.

---

### `appFieldDecoration` (`app_field_decoration.dart`)

Extracted from `serviceFieldDecoration()` in `service_form_shared.dart`.

```dart
InputDecoration appFieldDecoration({required String hintText})
```

Returns a full `InputDecoration` covering all 5 border states (`border`, `enabledBorder`, `focusedBorder`, `errorBorder`, `focusedErrorBorder`). All borders use `OutlineInputBorder` with `borderRadius: 8`.

---

## 3. Domain Interface Entities (Admin Data Layer Split)

### `AdminServiceRepository` (`lib/admin/services/domain/repositories/admin_service_repository.dart`)

Abstract class — write operations only.

```dart
abstract class AdminServiceRepository {
  Future<Result<ServiceEntity>> createService(ServiceEntity service);
  Future<Result<void>> updateService(ServiceEntity service);
  Future<Result<void>> deleteService({required String orgId, required String serviceId});
}
```

**Implementation**: `AdminServiceRepositoryImpl` in `lib/admin/services/data/repositories/`  
**Datasource**: `AdminServiceDatasource` in `lib/admin/services/data/datasources/` (methods moved from `FirestoreServiceDatasource`)

---

### `AdminWorkingHoursRepository` (`lib/admin/working_hours/domain/repositories/admin_working_hours_repository.dart`)

```dart
abstract class AdminWorkingHoursRepository {
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
```

**Implementation**: `AdminWorkingHoursRepositoryImpl` in `lib/admin/working_hours/data/repositories/`  
**Datasource**: `AdminWorkingHoursDatasource` in `lib/admin/working_hours/data/datasources/` (`saveAll` method moved from `FirestoreWorkingHoursDatasource`)

---

### `AdminOrganizationRepository` (`lib/admin/organization/domain/repositories/admin_organization_repository.dart`)

```dart
abstract class AdminOrganizationRepository {
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });
  Future<Result<void>> updateOrganization(OrganizationEntity organization);
}
```

**Implementation**: `AdminOrganizationRepositoryImpl` in `lib/admin/organization/data/repositories/`  
**Datasource**: `AdminOrganizationDatasource` in `lib/admin/organization/data/datasources/`

---

## 4. Shared Domain Interfaces (Post-Split)

### `ServiceRepository` (updated)

```dart
abstract class ServiceRepository {
  Stream<List<ServiceEntity>> watchServices(String orgId);
  // createService, updateService, deleteService removed → AdminServiceRepository
}
```

### `WorkingHoursRepository` (updated)

```dart
abstract class WorkingHoursRepository {
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);
  // saveAllWorkingHours removed → AdminWorkingHoursRepository
}
```

### `OrganizationRepository` (updated)

```dart
abstract class OrganizationRepository {
  Stream<OrganizationEntity> watchOrganization(String orgId);
  Future<OrganizationEntity?> getByAdminUid(String adminUid);
  // createOrganization, updateOrganization removed → AdminOrganizationRepository
}
```

---

## 5. Theme Entities

### `AppTheme` additions (`lib/core/theme/app_theme.dart`)

Three new `ThemeData` component themes added to the existing `ThemeData` builder:

| Theme | Key Properties |
|-------|---------------|
| `SnackBarThemeData` | `behavior: floating`, `shape: RoundedRectangleBorder(radius:8)`, `contentTextStyle: white bodyMedium` |
| `BottomSheetThemeData` | `shape: RoundedRectangleBorder(topLeft:16, topRight:16)`, `backgroundColor: AppColors.surface` |
| `DialogThemeData` | `shape: RoundedRectangleBorder(radius:12)`, `elevation: 3`, `backgroundColor: AppColors.surface` |

---

## 6. State Transitions

No state machine changes. This refactor is structural only — all Cubit states, events, and domain logic remain unchanged. Cubits that previously depended on `ServiceRepository` for write operations will depend on `AdminServiceRepository` instead; their state models are unaffected.

---

## 7. Validation Rules

| Entity | Rule | Error |
|--------|------|-------|
| `TimePickerHelper.parse` | Input must match `r'^\d{2}:\d{2}$'` | Logs warning, returns `TimeOfDay(0,0)` |
| `EmptyStateView` | `actionLabel` and `onAction` must both be non-null or both null | Debug assertion; in release, button simply hidden if either is null |
