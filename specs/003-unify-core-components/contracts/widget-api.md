# Widget API Contracts

**Feature**: `003-unify-core-components`  
**Layer**: Presentation — `lib/core/widgets/`

This document is the authoritative constructor-level API for every widget in the `core/widgets/` library. Implementers must match these signatures exactly. Call sites use these signatures to update their imports.

---

## Barrel Export

```dart
// lib/core/widgets/widgets.dart
export 'app_field_decoration.dart';
export 'empty_state_view.dart';
export 'error_view.dart';
export 'form_action_bar.dart';
export 'form_app_bar.dart';
export 'form_card.dart';
export 'form_field_label.dart';
export 'initials_avatar.dart';
export 'loading_button.dart';
export 'numeric_stepper_row.dart';
```

---

## `ErrorView`

```dart
/// A generic full-screen error state with an optional retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
}
```

**Migration map**:

| Old location | Old call | New call |
|---|---|---|
| `working_hours_body.dart` | `_ErrorView(message: state.message, onRetry: cubit.loadWorkingHours)` | `ErrorView(message: state.message, onRetry: cubit.loadWorkingHours, title: 'Failed to load working hours')` |
| `service_list_page.dart` | `_ErrorView(message: state.message)` | `ErrorView(message: state.message)` |

---

## `EmptyStateView`

```dart
/// A generic full-screen empty state with icon, descriptive text, and optional CTA.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must both be provided or both omitted',
       );

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
}
```

**Migration map**:

| Old location | New call |
|---|---|
| `service_list_page.dart _EmptyStateView` | `EmptyStateView(icon: Icons.medical_services_outlined, title: 'No services yet', subtitle: '...', actionLabel: 'Add Service', onAction: _onAdd)` |

---

## `InitialsAvatar`

```dart
/// Circular avatar displaying the initials extracted from [name].
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
}
```

**Migration map**:

| Old location | New call |
|---|---|
| `service_list_tile.dart _InitialsAvatar` | `InitialsAvatar(name: service.name)` |

---

## `NumericStepperRow`

```dart
/// A row composing a leading icon, label column, and integer ± controls.
class NumericStepperRow extends StatelessWidget {
  const NumericStepperRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.unit,
    this.onDecrement,
    this.onIncrement,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int value;
  final String unit;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
}
```

**Migration map**:

| Old location | New call |
|---|---|
| `service_stepper_row.dart ServiceStepperRow` | Direct rename + import update |

---

## `FormFieldLabel`

```dart
/// A small, bold label for form field groups.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({super.key, required this.text});

  final String text;
}
```

**Migration map**:

| Old location | New name |
|---|---|
| `service_form_shared.dart ServiceFieldLabel` | `FormFieldLabel` |

---

## `FormCard`

```dart
/// A card container with a subtle border and shadow for grouping form fields.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
}
```

**Migration map**:

| Old location | New name |
|---|---|
| `service_form_shared.dart ServiceFormCard` | `FormCard` |

---

## `FormAppBar`

```dart
/// A form-specific AppBar with a back button and bottom divider.
///
/// Implements [PreferredSizeWidget] — use directly as [Scaffold.appBar].
class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FormAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
```

**Migration map**:

| Old location | Old call | New call |
|---|---|---|
| `service_form_page.dart` | `ServiceFormAppBar(isEditMode: cubit.isEditMode)` | `FormAppBar(title: cubit.isEditMode ? 'Edit Service' : 'Add Service', onBack: context.pop)` |

---

## `FormActionBar`

```dart
/// A sticky bottom bar with a primary action button and safe-area padding.
class FormActionBar extends StatelessWidget {
  const FormActionBar({
    super.key,
    required this.label,
    required this.onSave,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onSave;
  final bool isLoading;
}
```

**Migration map**:

| Old location | Old call | New call |
|---|---|---|
| `service_form_page.dart` | `ServiceFormBottomBar(isLoading: state.isSaving)` | `FormActionBar(label: 'Save Service', onSave: cubit.submit, isLoading: state.isSaving)` |

---

## `LoadingButton`

```dart
/// A full-width FilledButton with an optional loading indicator.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
}
```

**Migration map**:

| Old location | Old call | New call |
|---|---|---|
| `working_hours_body.dart _SaveButton` | `_SaveButton(isSaving: state.isSaving, onSave: cubit.save)` | `LoadingButton(label: 'Save Working Hours', onPressed: cubit.save, isLoading: state.isSaving)` |

---

## `appFieldDecoration`

```dart
/// Returns a consistent [InputDecoration] for all text fields in the app.
InputDecoration appFieldDecoration({required String hintText});
```

**Migration map**:

| Old location | Old call | New call |
|---|---|---|
| `service_form_shared.dart` | `serviceFieldDecoration(hintText: '...')` | `appFieldDecoration(hintText: '...')` |

---

## Domain Interface Contracts

### `AdminServiceRepository`

```dart
// lib/admin/services/domain/repositories/admin_service_repository.dart
abstract class AdminServiceRepository {
  Future<Result<ServiceEntity>> createService(ServiceEntity service);
  Future<Result<void>> updateService(ServiceEntity service);
  Future<Result<void>> deleteService({
    required String orgId,
    required String serviceId,
  });
}
```

### `AdminWorkingHoursRepository`

```dart
// lib/admin/working_hours/domain/repositories/admin_working_hours_repository.dart
abstract class AdminWorkingHoursRepository {
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
```

### `AdminOrganizationRepository`

```dart
// lib/admin/organization/domain/repositories/admin_organization_repository.dart
abstract class AdminOrganizationRepository {
  Future<Result<OrganizationEntity>> createOrganization({
    required String adminUid,
    required String name,
  });
  Future<Result<void>> updateOrganization(OrganizationEntity organization);
}
```
