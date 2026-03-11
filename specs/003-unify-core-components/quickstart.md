# Quickstart: Core Components Library

**Feature**: `003-unify-core-components`  
**Branch**: `003-unify-core-components`

This guide covers how to use the new shared utilities and widget library introduced by this refactor.

---

## Core Utilities

### `AppSnackBar`

```dart
import 'package:queue_ease/core/utils/app_snack_bar.dart';

// Show a success message
AppSnackBar.showSuccess(context, 'Working hours saved');

// Show an error message
AppSnackBar.showError(context, 'Failed to save. Please try again.');

// Show a warning
AppSnackBar.showWarning(context, 'No internet connection');

// Show informational message
AppSnackBar.showInfo(context, 'Changes will take effect on next open');
```

The previous inline pattern is **removed**:

```dart
// ❌ Old — do not use
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Saved'), backgroundColor: Colors.green),
);

// ✅ New
AppSnackBar.showSuccess(context, 'Saved');
```

---

### `TimePickerHelper`

```dart
import 'package:queue_ease/core/utils/time_picker_helper.dart';

// Parse a stored HH:MM string into a TimeOfDay
final time = TimePickerHelper.parse('09:30'); // → TimeOfDay(9, 30)

// Format a TimeOfDay back to HH:MM for storage
final stored = TimePickerHelper.format(TimeOfDay(hour: 14, minute: 0)); // → '14:00'

// Get a display string (12h AM/PM) for UI labels
final label = TimePickerHelper.display('14:00'); // → '2:00 PM'

// Show the time picker dialog and get the result
final picked = await TimePickerHelper.pick(context, '09:30');
if (picked != null) {
  final newValue = TimePickerHelper.format(picked);
}
```

---

## Core Widgets

All widgets are available from a single import:

```dart
import 'package:queue_ease/core/widgets/widgets.dart';
```

### `ErrorView`

```dart
// Minimal — no retry button
ErrorView(message: state.errorMessage)

// With retry
ErrorView(
  title: 'Failed to load working hours',
  message: state.errorMessage,
  onRetry: () => cubit.load(),
)
```

### `EmptyStateView`

```dart
// Without action button
EmptyStateView(
  icon: Icons.inbox_outlined,
  title: 'No items',
  subtitle: 'Nothing has been added yet.',
)

// With action button
EmptyStateView(
  icon: Icons.medical_services_outlined,
  title: 'No services yet',
  subtitle: 'Add your first service to get started.',
  actionLabel: 'Add Service',
  onAction: () => cubit.openAddService(),
)
```

### `InitialsAvatar`

```dart
// Default size (40)
InitialsAvatar(name: service.name)

// Custom size and colour
InitialsAvatar(
  name: user.displayName,
  size: 56,
  backgroundColor: AppColors.primaryLight,
)
```

### `NumericStepperRow`

```dart
NumericStepperRow(
  icon: Icons.timer_outlined,
  title: 'Duration',
  subtitle: 'Service appointment length',
  value: state.durationMinutes,
  unit: 'min',
  onDecrement: state.durationMinutes > 5 ? cubit.decrementDuration : null,
  onIncrement: cubit.incrementDuration,
)
```

### `FormFieldLabel`

```dart
FormFieldLabel(text: 'Service Name')
```

### `FormCard`

```dart
FormCard(
  child: Column(
    children: [
      FormFieldLabel(text: 'Details'),
      TextFormField(...),
    ],
  ),
)

// Custom padding
FormCard(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  child: ...,
)
```

### `FormAppBar`

```dart
Scaffold(
  appBar: FormAppBar(
    title: isEditMode ? 'Edit Service' : 'Add Service',
    onBack: context.pop,
  ),
  ...
)
```

### `FormActionBar`

```dart
Scaffold(
  bottomNavigationBar: FormActionBar(
    label: 'Save Service',
    onSave: cubit.submit,
    isLoading: state.isSaving,
  ),
  ...
)
```

### `LoadingButton`

```dart
LoadingButton(
  label: 'Save Working Hours',
  onPressed: cubit.save,
  isLoading: state.isSaving,
)
```

### `appFieldDecoration`

```dart
import 'package:queue_ease/core/widgets/widgets.dart';

TextFormField(
  decoration: appFieldDecoration(hintText: 'Enter service name'),
)
```

---

## Theme — Automatic Styling

After the `AppTheme` update, the following render correctly without per-call overrides:

- **SnackBars** — floating, rounded corners, appropriate background from `AppColors`  
  (styled automatically by `AppSnackBar` methods; do not pass `SnackBar(backgroundColor:...)` manually)

- **BottomSheets** — rounded top corners (radius 16), `AppColors.surface` background  
  (any `showModalBottomSheet` call gets this automatically)

- **Dialogs** — rounded corners (radius 12), `AppColors.surface` background  
  (any `showDialog` call gets this automatically)

---

## Admin Data Layer — Updated DI Usage

After Phase 4, admin Cubits must inject `AdminXxxRepository` instead of the shared `XxxRepository`:

```dart
// ❌ Old — ServiceFormCubit injecting shared repository for writes
@injectable
class ServiceFormCubit extends Cubit<ServiceFormState> {
  ServiceFormCubit(this._repo);
  final ServiceRepository _repo; // had createService / updateService

// ✅ New — separate read and write repositories
@injectable
class ServiceFormCubit extends Cubit<ServiceFormState> {
  ServiceFormCubit(this._readRepo, this._writeRepo);
  final ServiceRepository _readRepo;          // watchServices only
  final AdminServiceRepository _writeRepo;    // create / update / delete
```

Run code generation after any `@injectable` change:

```powershell
dart run build_runner build --delete-conflicting-outputs
```
