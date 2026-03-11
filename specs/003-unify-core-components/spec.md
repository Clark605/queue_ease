# Feature Specification: Unify Core Components & Restructure Project

**Feature Branch**: `003-unify-core-components`  
**Created**: March 11, 2026  
**Status**: Draft  
**Input**: User description: "Unify duplicated components across the project into core folder (widgets, dialogs, pickers, snackbars), update theming files to match the current design system, and restructure project structure in admin/customer/shared folders to properly separate data/domain layers"

## User Scenarios

### User Story 1 - Consistent Feedback Messages Across All Screens (Priority: P1)

As a developer working on any feature, I use a single centralized SnackBar utility so that all user feedback messages have consistent styling, behavior, and placement across the entire app.

**Why this priority**: SnackBar calls are the most widespread duplication in the codebase (10+ files with inline `ScaffoldMessenger.showSnackBar` calls, each with different styling). This creates visual inconsistency for users and maintenance burden for developers. Fixing this first eliminates the highest-volume duplication.

**Acceptance Scenarios**:

1. **Given** a developer needs to show a success message, **When** they call `AppSnackBar.showSuccess(context, 'Saved')`, **Then** a floating green SnackBar with the message appears, styled per the app's design system.
2. **Given** a developer needs to show an error message, **When** they call `AppSnackBar.showError(context, 'Failed to save')`, **Then** a floating red SnackBar with the error message appears.
3. **Given** any screen previously using inline SnackBar calls, **When** the refactor is complete, **Then** zero inline `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` calls remain outside the utility class.

---

### User Story 2 - Centralized Time Picker Logic (Priority: P1)

As a developer building time-related features, I use a single time picker helper so that time parsing, formatting, and picker invocation logic is not duplicated across widgets.

**Why this priority**: The exact same `_parse(String hhmm)` and `_fmt(TimeOfDay t)` functions plus `showTimePicker` wrapper are duplicated identically in `day_working_hours_tile.dart` and `break_time_section.dart`. This is a concrete DRY violation that affects correctness if either copy drifts.

**Acceptance Scenarios**:

1. **Given** the time picker helper exists in `core/utils/`, **When** `day_working_hours_tile.dart` needs to parse "09:30", **Then** it calls the shared helper and gets `TimeOfDay(hour: 9, minute: 30)`.
2. **Given** the time picker helper exists, **When** `break_time_section.dart` formats `TimeOfDay(hour: 14, minute: 0)`, **Then** it calls the same shared helper and gets "14:00".
3. **Given** the refactor is complete, **When** searching for `_parse` and `_fmt` in working hours widgets, **Then** zero local implementations remain.

---

### User Story 3 - Centralize Shared & Duplicated Widgets into Core (Priority: P1)

As a developer building new features, I find generic reusable widgets (error views, empty states, avatars, form components, numeric steppers) in `core/widgets/` so I can compose screens without reinventing common UI patterns or duplicating code.

**Why this priority**: The codebase audit found 11 widgets that are either duplicated across features or generic enough to be reused project-wide, yet they currently live inside feature-specific folders. Specifically:
- `_ErrorView` is duplicated identically in `working_hours_body.dart` and `service_list_page.dart`
- `_EmptyStateView` (icon + title + subtitle + CTA) in `service_list_page.dart` is a universal list-page pattern
- `_InitialsAvatar` in `service_list_tile.dart` is a generic name-to-initials circular badge
- `_StepperButton` and `ServiceStepperRow` are generic numeric +/- controls
- Form components (`ServiceFieldLabel`, `ServiceFormCard`, `ServiceFormAppBar`, `ServiceFormBottomBar`, `serviceFieldDecoration()`) are prefixed with "Service" but have zero service-specific logic — they are generic form building blocks
- `_SaveButton` in `working_hours_body.dart` is a generic full-width loading button

Centralizing these eliminates duplication today and provides a widget toolkit for future features.

**Acceptance Scenarios**:

1. **Given** the `ErrorView` widget exists in `core/widgets/`, **When** the working hours page and service list page need to show an error, **Then** both import and use the same `ErrorView` from core.
2. **Given** generic form widgets exist in `core/widgets/` (e.g., `FormFieldLabel`, `FormCard`, `FormAppBar`, `FormActionBar`), **When** a new feature requires a form, **Then** the developer uses core widgets without creating new form components.
3. **Given** the `InitialsAvatar` widget exists in `core/widgets/`, **When** any list tile needs a name-based avatar, **Then** it uses the shared widget.
4. **Given** the refactor is complete, **When** examining feature-specific widget folders, **Then** they contain only feature-specific widgets, not generic reusable ones.

---

### User Story 4 - Theme Alignment with Design System (Priority: P2)

As a user of the app, I experience consistent visual styling for SnackBars, BottomSheets, and Dialogs because these component themes are defined centrally in the app's theme configuration.

**Why this priority**: The current `AppTheme` only defines basic input/button/card theming. SnackBars, BottomSheets, and Dialogs are styled inline in individual files, leading to visual inconsistency. Adding these component themes to `AppTheme` ensures design system compliance app-wide.

**Acceptance Scenarios**:

1. **Given** the updated `AppTheme` with SnackBar theme, **When** a SnackBar is shown on any screen, **Then** it uses floating behavior, rounded corners, and colors from the design system by default.
2. **Given** the updated `AppTheme` with BottomSheet theme, **When** a BottomSheet is shown (e.g., forgot password), **Then** it uses rounded top corners and correct background color from the theme.
3. **Given** the updated `AppTheme` with Dialog theme, **When** any dialog is shown (e.g., delete confirmation), **Then** it uses the theme-defined shape, elevation, and colors.

---

### User Story 5 - Admin-Specific Repository Operations in Admin Folder (Priority: P2)

As a developer maintaining the codebase, I find admin-specific data operations (like `saveAllWorkingHours`, `createService`, `createOrganization`) in the admin folder, not in `shared/organization/`, so that each role owns its write operations while sharing read-only entities and interfaces.

**Why this priority**: Currently, admin-specific CRUD operations live in `shared/organization/` repositories and datasources, even though only admin features use them. This violates separation of concerns and will create conflicts when customer-specific operations are added later. The shared layer should contain only truly shared entities and read interfaces.

**Acceptance Scenarios**:

1. **Given** admin-specific write operations are moved to `admin/` feature folders, **When** the admin creates a service, **Then** the operation uses the admin-owned datasource/repository implementation.
2. **Given** shared entities and read-only interfaces remain in `shared/organization/`, **When** a customer feature later needs to read organization data, **Then** it accesses `shared/organization/` without depending on admin code.
3. **Given** the restructure is complete, **When** examining `shared/organization/` repositories, **Then** they contain only entity definitions, read-only repository interfaces, and shared read operations.

---

### User Story 6 - Dashboard Widget Extraction (Priority: P3)

As a developer maintaining the admin dashboard, I work with clearly separated widget files instead of a single large file with many nested private widgets.

**Why this priority**: `admin_dashboard_tab.dart` contains 6+ nested private widgets in a single file. Extracting the largest ones improves readability and makes it easier to modify individual dashboard sections independently. Lower priority because it's a single-file issue, not a cross-cutting concern.


**Acceptance Scenarios**:

1. **Given** the largest nested widgets are extracted, **When** viewing `admin_dashboard_tab.dart`, **Then** the file is under 300 lines.
2. **Given** `_NowServingCard` is extracted to its own file, **When** the dashboard renders, **Then** the Now Serving card displays identically to before.
3. **Given** `_ManagementGrid` and `_ManagementCard` are extracted, **When** the dashboard renders, **Then** the management grid displays identically to before.

---

### Edge Cases

- What happens when a SnackBar is triggered while another is already showing? The centralized utility dismisses the current SnackBar before showing the new one.
- What happens when time picker helper receives an invalid time string (e.g., "25:99")? The helper handles gracefully with a sensible default or clear error.
- What happens when admin repository methods are called but the user doesn't have admin role? Existing auth guards continue to prevent unauthorized access.
- What happens when theme changes are applied but a widget hardcodes inline styles? The audit identifies and removes all hardcoded style overrides that conflict with theme values.
- What happens when a centralized widget needs feature-specific customization? Core widgets accept configuration parameters (callbacks, styles) rather than embedding business logic — features wrap or configure them as needed.

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide a centralized `AppSnackBar` static utility class in `core/utils/` with methods for success, error, warning, and info SnackBars.
- **FR-002**: System MUST replace all inline `ScaffoldMessenger.showSnackBar` calls across the codebase with the `AppSnackBar` utility.
- **FR-003**: System MUST extract duplicated time parsing, formatting, and picker invocation logic from `day_working_hours_tile.dart` and `break_time_section.dart` into a shared `core/utils/` helper.
- **FR-004**: System MUST centralize the following duplicated and generic widgets into `core/widgets/`:
  - `ErrorView` — extracted from identical implementations in `working_hours_body.dart` and `service_list_page.dart`
  - `EmptyStateView` — extracted from `service_list_page.dart` (icon + title + subtitle + optional CTA pattern)
  - `InitialsAvatar` — extracted from `service_list_tile.dart` (name-to-initials circular badge)
  - `NumericStepperRow` — extracted from `service_stepper_row.dart` and `_StepperButton` (icon + label + ±controls)
  - `FormFieldLabel` — extracted from `ServiceFieldLabel` in `service_form_shared.dart`
  - `FormCard` — extracted from `ServiceFormCard` in `service_form_shared.dart`
  - `FormAppBar` — extracted from `service_form_app_bar.dart` (iOS-style form header)
  - `FormActionBar` — extracted from `service_form_bottom_bar.dart` (sticky bottom bar with save + loading state)
  - `LoadingButton` — extracted from `_SaveButton` in `working_hours_body.dart` (full-width button with loading indicator)
  - `appFieldDecoration()` — extracted from `serviceFieldDecoration()` in `service_form_shared.dart`
- **FR-005**: System MUST rename centralized widgets to remove feature-specific prefixes (e.g., `ServiceFieldLabel` → `FormFieldLabel`, `ServiceFormCard` → `FormCard`).
- **FR-006**: System MUST provide a barrel file (`core/widgets/widgets.dart`) exporting all centralized widgets.
- **FR-007**: System MUST add SnackBar, BottomSheet, and Dialog component themes to the central theme configuration.
- **FR-008**: System MUST move admin-specific write operations (create, update, delete for organizations, services, and working hours) from `shared/organization/` into corresponding `admin/` feature folders with their own data layers.
- **FR-009**: `shared/organization/` MUST retain only entity definitions, read-only repository interfaces, and shared read-only data operations.
- **FR-010**: Same separation principle MUST apply to customer-specific operations — any customer-specific write operations must live in `customer/` feature folders.
- **FR-011**: System MUST extract the largest nested private widgets from `admin_dashboard_tab.dart` (specifically `_NowServingCard`, `_ManagementGrid`, and `_ManagementCard`) into separate widget files in `admin/dashboard/presentation/widgets/`.
- **FR-012**: The centralized delete confirmation dialog MUST remain as the dialog utility and any other scattered dialog creation patterns should use it.
> **Note**: No new tests are required for this spec. Existing tests must compile after import-path updates but writing new test coverage is out of scope.
### Key Entities

- **AppSnackBar**: Static utility class providing `showSuccess`, `showError`, `showWarning`, `showInfo` methods. Lives in `core/utils/`.
- **TimePickerHelper**: Utility with `parse(String hhmm)`, `format(TimeOfDay t)`, and optional picker invocation helper. Lives in `core/utils/`.
- **Core Widget Library**: Reusable UI components (`ErrorView`, `EmptyStateView`, `InitialsAvatar`, `NumericStepperRow`, `FormFieldLabel`, `FormCard`, `FormAppBar`, `FormActionBar`, `LoadingButton`). Lives in `core/widgets/`.
- **Admin Data Layer**: Admin-specific repositories and datasources for write operations on organizations, services, and working hours. Lives in `admin/{feature}/data/`.
- **Shared Organization Layer**: Read-only entities, repository interfaces, and shared read datasources. Lives in `shared/organization/`.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Zero inline `ScaffoldMessenger.showSnackBar` calls remain outside the centralized utility — all SnackBar feedback uses `AppSnackBar`.
- **SC-002**: Zero duplicated time parsing/formatting logic — only one implementation exists in `core/utils/`.
- **SC-003**: `core/widgets/` contains at least 10 centralized widgets with a barrel file, and zero duplicated widget implementations remain across feature folders.
- **SC-004**: Central theme configuration includes SnackBar, BottomSheet, and Dialog component themes, and all instances inherit from the theme without inline style overrides.
- **SC-005**: `shared/organization/` contains zero admin-specific write operations — all create/update/delete datasource methods live in admin feature folders.
- **SC-006**: `admin_dashboard_tab.dart` is under 300 lines after extracting the largest nested widgets.
- **SC-007**: No feature folder directly imports from another feature folder — cross-feature dependencies go through `shared/` or `core/`.

## Assumptions

- The current color palette (primary, success, error, warning, info) provides sufficient semantic colors for SnackBar theming without new color additions.
- The refactor preserves all existing functionality — no behavioral changes, only structural reorganization.
- Admin features that reuse `shared/organization/` read operations will import entity types and read-only interfaces from `shared/`, but own their write implementations.
- Customer-specific write operations do not currently exist in `shared/`, so FR-007 is a constraint for future work rather than an immediate migration task.
- The partial dashboard extraction targets only the 2-3 largest nested widgets, not all 6+ private widgets.
- Empty `.gitkeep` placeholder folders in admin and customer features are intentionally kept for future scaffolding.

## Dependencies

- This refactor has no external package dependencies — it is purely a structural reorganization of existing code.
- The DI configuration will need updates to register admin-specific repositories after the data layer split.
- Router configuration may need import path updates if any page files move.

## Risks

- **Import Breakage**: Moving files changes import paths across many files. Mitigate by using IDE refactoring tools and doing a full build verification after each move.
- **DI Registration Drift**: Splitting shared repositories into admin-specific ones requires updating dependency injection registration. Mitigate by running code generation after changes.
- **Behavioral Regression**: Structural changes could introduce subtle bugs if methods are missed during migration. Mitigate by verifying each admin CRUD operation end-to-end after migration.
