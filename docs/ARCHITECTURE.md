# Queue Ease - Architecture Documentation

**Last Updated:** March 12, 2026  
**Version:** 1.1.0+1  
**Architecture Pattern:** Clean Architecture with Role-Based Feature Repositories (ADR-001)

---

## Table of Contents

1. [Overview](#overview)
2. [Architectural Principles](#architectural-principles)
3. [Project Structure](#project-structure)
4. [Layer Responsibilities](#layer-responsibilities)
5. [Feature Modules](#feature-modules)
6. [Dependency Injection](#dependency-injection)
7. [Error Handling](#error-handling)
8. [Navigation Architecture](#navigation-architecture)
9. [State Management](#state-management)
10. [Platform-Specific Configurations](#platform-specific-configurations)
11. [Testing Strategy](#testing-strategy)
12. [Code Organization Guidelines](#code-organization-guidelines)

---

## Overview

Queue Ease is built using **Clean Architecture** principles with a **Role-Based Feature Repository** structure (ADR-001). Each role (admin / customer) owns its own repository interface and implementation, eliminating shared mutable state and making permission boundaries explicit at the type level.

### Technology Stack

- **Framework**: Flutter 3.9.0+
- **Language**: Dart 3.9.0+
- **State Management**: flutter_bloc (Cubit pattern)
- **Dependency Injection**: GetIt + Injectable
- **Navigation**: GoRouter 17.1.0
- **Backend**: Firebase (Auth, Firestore, Crashlytics)
- **Logging**: Talker + Talker BLoC Logger
- **Testing**: flutter_test, bloc_test, mocktail
- **QR Code**: qr_flutter 4.1.0
- **Sharing**: share_plus 12.0.1
- **Gallery**: gal 2.3.0

---

## Architectural Principles

### 1. Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Pages, Widgets, State Management) │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Entities, Repository Interfaces,      │
│   Use Cases)                            │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│   (Models, Datasources, Repositories)   │
└─────────────────────────────────────────┘
```

**Dependency Rule**: Dependencies flow **inward** only. The domain layer has zero dependencies on Flutter or external packages.

### 2. Role-Based Feature Repositories (ADR-001)

Repository interfaces are split by role rather than entity. Admins get full CRUD; customers get read-only access. This makes permission boundaries explicit and removes the need for access-control logic scattered across cubits.

```
admin_service_repository.dart   → watchServices, addService, updateService, deleteService
customer_service_repository.dart → getActiveServices   (read-only)
```

### 3. SOLID Principles

- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Clients depend on abstractions they use
- **Dependency Inversion**: Depend on abstractions, not concretions

### 4. Feature-Based Organization

Each feature is self-contained with its own data/domain/presentation layers:

```
feature_name/
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── repositories/   # abstract interfaces
│   └── use_cases/      # (where applicable)
└── presentation/
    ├── pages/
    ├── widgets/
    └── cubit/
```

---

## Project Structure

```
lib/
├── core/                                  # Shared infrastructure
│   ├── config/
│   │   ├── flavor_config.dart             # Dev/Prod environment config
│   │   ├── auth_module.dart
│   │   └── config_module.dart
│   ├── di/
│   │   ├── injection.dart                 # GetIt + Injectable setup
│   │   └── injection.config.dart          # Generated registrations
│   ├── dialogs/
│   │   └── delete_confirmation_dialog.dart
│   ├── error/
│   │   ├── result.dart                    # Result<T> type
│   │   ├── app_exception.dart             # Sealed exception hierarchy
│   │   └── error.dart                     # Exports
│   ├── router/
│   │   ├── app_router.dart                # GoRouter with RBAC guards
│   │   └── go_router_refresh_stream.dart
│   ├── services/
│   │   ├── onboarding_service.dart        # First-launch completion state
│   │   └── user_session_service.dart      # Session persistence
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── app_logger.dart                # Talker-based logger
│   │   ├── app_snack_bar.dart             # Centralized snackbar helpers
│   │   ├── snackbar_utils.dart
│   │   ├── time_picker_helper.dart
│   │   └── time_picker_utils.dart
│   ├── widgets/                           # Reusable shared widgets
│   │   ├── app_field_decoration.dart
│   │   ├── app_loading_indicator.dart
│   │   ├── empty_state_view.dart
│   │   ├── error_view.dart
│   │   ├── form_action_bar.dart
│   │   ├── form_app_bar.dart
│   │   ├── form_card.dart
│   │   ├── form_field_label.dart
│   │   ├── initials_avatar.dart
│   │   ├── loading_button.dart
│   │   ├── numeric_stepper_row.dart
│   │   └── widgets.dart                   # Barrel export
│   └── app.dart
│
├── features/                              # All role-based features
│   │
│   ├── shared_domain/                     # Entities & models shared across roles
│   │   ├── entities/
│   │   │   ├── organization_entity.dart
│   │   │   ├── service_entity.dart
│   │   │   ├── working_hours_entity.dart
│   │   │   ├── appointment_entity.dart
│   │   │   ├── appointment_status.dart    # enum
│   │   │   ├── queue_entity.dart
│   │   │   └── queue_status.dart          # enum
│   │   └── models/                        # Firestore serialization models
│   │       ├── organization_model.dart
│   │       ├── service_model.dart
│   │       ├── working_hours_model.dart
│   │       ├── appointment_model.dart
│   │       └── queue_model.dart
│   │
│   ├── authentication/                    # ✅ Complete
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── firebase_auth_datasource.dart
│   │   │   │   └── firestore_user_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── user_role.dart         # enum: admin, customer
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── sign_up_page.dart
│   │       └── widgets/
│   │           ├── auth_divider.dart
│   │           ├── auth_footer_panel.dart
│   │           ├── auth_header.dart
│   │           ├── auth_role_selector.dart
│   │           ├── auth_text_field.dart
│   │           ├── forgot_password_bottom_sheet.dart
│   │           └── google_sign_in_button.dart
│   │
│   ├── onboarding/                        # ✅ Complete
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── onboarding_content_model.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── onboarding_page.dart
│   │       └── widgets/
│   │           ├── fair_turns_illustration.dart
│   │           ├── onboarding_content.dart
│   │           ├── real_time_tracking_illustration.dart
│   │           └── skip_the_wait_illustration.dart
│   │
│   ├── admin/
│   │   ├── organization_management/       # ✅ Complete
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── admin_organization_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── admin_organization_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── admin_organization_repository.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── organization_cubit.dart
│   │   │       │   └── organization_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── organization_profile_page.dart
│   │   │       │   ├── organization_profile_edit_page.dart
│   │   │       │   └── organization_setup_page.dart
│   │   │       └── widgets/
│   │   │           └── organization_profile_form.dart
│   │   │
│   │   ├── service_management/            # ✅ Complete
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── admin_service_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── admin_service_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── admin_service_repository.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── service_cubit.dart
│   │   │       │   ├── service_state.dart
│   │   │       │   ├── service_form_cubit.dart
│   │   │       │   └── service_form_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── service_list_page.dart
│   │   │       │   └── service_form_page.dart
│   │   │       └── widgets/
│   │   │           ├── service_list_tile.dart
│   │   │           ├── service_main_card.dart
│   │   │           └── service_settings_card.dart
│   │   │
│   │   ├── working_hours_management/      # ✅ Complete
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── admin_working_hours_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── admin_working_hours_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── admin_working_hours_repository.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── working_hours_cubit.dart
│   │   │       │   └── working_hours_state.dart
│   │   │       ├── pages/
│   │   │       │   └── working_hours_page.dart
│   │   │       └── widgets/
│   │   │           ├── break_time_section.dart
│   │   │           ├── day_working_hours_tile.dart
│   │   │           ├── working_hours_app_bar.dart
│   │   │           └── working_hours_body.dart
│   │   │
│   │   ├── share_access/                  # ✅ Complete
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── share_access_cubit.dart
│   │   │       │   └── share_access_state.dart
│   │   │       ├── pages/
│   │   │       │   └── share_access_page.dart
│   │   │       └── widgets/
│   │   │           ├── qr_code_display.dart
│   │   │           └── share_action_buttons.dart
│   │   │
│   │   ├── tutorial/                      # ✅ Complete
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── tutorial_cubit.dart
│   │   │       │   └── tutorial_state.dart
│   │   │       └── widgets/
│   │   │           └── tutorial_overlay.dart
│   │   │
│   │   ├── dashboard/                     # ✅ Complete
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── admin_dashboard_tab.dart
│   │   │       └── widgets/
│   │   │           ├── management_card.dart
│   │   │           ├── management_grid.dart
│   │   │           └── now_serving_card.dart
│   │   │
│   │   └── queue_management/              # ⏳ Interface only (Sprint 5)
│   │       └── domain/
│   │           └── repositories/
│   │               └── admin_appointment_repository.dart
│   │
│   └── customer/
│       └── booking/                       # ✅ Complete
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── customer_appointment_datasource.dart
│           │   │   ├── customer_organization_datasource.dart
│           │   │   ├── customer_service_datasource.dart
│           │   │   └── customer_working_hours_datasource.dart
│           │   └── repositories/
│           │       ├── customer_appointment_repository_impl.dart
│           │       ├── customer_organization_repository_impl.dart
│           │       ├── customer_service_repository_impl.dart
│           │       └── customer_working_hours_repository_impl.dart
│           ├── domain/
│           │   ├── repositories/
│           │   │   ├── customer_appointment_repository.dart
│           │   │   ├── customer_organization_repository.dart
│           │   │   ├── customer_service_repository.dart
│           │   │   └── customer_working_hours_repository.dart
│           │   └── use_cases/
│           │       ├── calculate_available_slots_use_case.dart
│           │       ├── create_booking_use_case.dart
│           │       ├── get_active_services_use_case.dart
│           │       └── get_organization_by_slug_use_case.dart
│           └── presentation/
│               ├── cubit/
│               │   ├── booking_form_cubit.dart
│               │   ├── booking_form_state.dart
│               │   ├── organization_landing_cubit.dart
│               │   ├── organization_landing_state.dart
│               │   ├── service_selection_cubit.dart
│               │   ├── service_selection_state.dart
│               │   ├── slot_picker_cubit.dart
│               │   └── slot_picker_state.dart
│               ├── pages/
│               │   ├── booking_confirmation_page.dart
│               │   ├── booking_form_page.dart
│               │   ├── organization_landing_page.dart
│               │   ├── service_details_page.dart
│               │   ├── service_selection_page.dart
│               │   └── slot_picker_page.dart
│               └── widgets/
│                   ├── booking_action_bar.dart
│                   ├── booking_summary_card.dart
│                   ├── continue_footer.dart
│                   ├── date_selector.dart
│                   ├── open_closed_badge.dart
│                   ├── org_info_card.dart
│                   ├── org_profile_header.dart
│                   ├── service_card.dart
│                   └── time_slot_grid.dart
│
├── admin/                                 # Legacy shell (presentation only)
│   ├── presentation/
│   │   └── pages/
│   │       ├── admin_main_page.dart       # Bottom-nav shell
│   │       └── settings_page.dart
│   ├── queue_management/
│   │   └── presentation/
│   │       └── pages/
│   │           └── queue_management_page.dart  # Placeholder (Sprint 5)
│   └── daily_summary/                     # Placeholder (Sprint 7)
│
├── customer/                              # Legacy shell (presentation only)
│   ├── entry/
│   │   └── presentation/
│   │       └── pages/
│   │           └── customer_home_page.dart
│   └── queue_status/                      # Placeholder (future)
│
├── firebase_options.dart
├── main_dev.dart
└── main_prod.dart

test/                                      # Mirrors lib/ structure
├── core/
│   └── error/
│       ├── result_test.dart
│       └── app_exception_test.dart
├── shared/
│   ├── auth/
│   │   ├── auth_cubit_test.dart
│   │   └── data/models/user_model_test.dart
│   ├── onboarding/
│   │   └── onboarding_integration_test.dart
│   ├── organization/
│   │   ├── data/models/
│   │   │   ├── organization_model_test.dart
│   │   │   └── working_hours_model_test.dart
│   │   └── domain/entities/
│   │       ├── organization_entity_test.dart
│   │       ├── service_entity_test.dart
│   │       └── working_hours_entity_test.dart
│   ├── booking/
│   │   ├── data/models/appointment_model_test.dart
│   │   └── domain/entities/appointment_entity_test.dart
│   └── queue/
│       ├── data/models/queue_model_test.dart
│       └── domain/entities/queue_entity_test.dart
└── firebase_mocks.dart
```

> **Note on `admin/` and `customer/` shell folders**: These contain the remaining presentation-only shell code (navigation scaffold, settings, placeholders) that has not yet been moved into `features/`. The full domain and data logic for all implemented features lives exclusively under `features/`.

---

## Layer Responsibilities

### 1. Presentation Layer

**Location**: `lib/features/{feature}/presentation/`

**Responsibilities**:
- UI rendering (Pages, Widgets)
- User interaction handling
- State management (Cubit)
- Navigation
- Displaying data from domain layer

**Rules**:
- ✅ Depend on domain layer (entities, use cases, repository interfaces)
- ✅ Use dependency injection for cubits
- ❌ Never import the data layer directly
- ❌ No business logic — delegate to use cases or repository
- ❌ No direct Firebase/HTTP calls

### 2. Domain Layer

**Location**: `lib/features/{feature}/domain/`

**Responsibilities**:
- Define business entities (pure Dart classes, Equatable)
- Define repository interfaces (abstract contracts)
- Define use cases (orchestrate repository calls)
- Business rules and validation logic

**Rules**:
- ✅ Pure Dart — no Flutter, Firebase, or HTTP imports
- ✅ Entities extend `Equatable` for value comparison
- ✅ Enums for typed status values
- ❌ No implementation details
- ❌ No framework dependencies

### 3. Data Layer

**Location**: `lib/features/{feature}/data/`

**Responsibilities**:
- Implement domain repository interfaces
- Firestore serialization via models in `features/shared_domain/models/`
- Manage data sources
- Map platform exceptions to `AppException` subtypes

**Rules**:
- ✅ Implement domain repository interfaces
- ✅ Models expose `toEntity()` to hand a clean domain type upward
- ✅ Models do not extend domain entities (preserves layer boundary)
- ✅ Map all platform exceptions to typed `AppException` subtypes
- ❌ No UI/presentation logic

### 4. Shared Domain

**Location**: `lib/features/shared_domain/`

Houses entities and Firestore models that are referenced by both admin and customer features. It is a **read-only supply layer** — no cubits, no repositories, no business logic.

---

## Feature Modules

### Authentication (`features/authentication/`) — ✅ Complete

- Email/password login and signup
- Google Sign-In
- Password reset
- User session persistence
- Role-based routing (`UserRole.admin` / `UserRole.customer`)

**Key components**: `AuthCubit`, `AuthRepository`, `UserEntity`, `UserRole`

---

### Onboarding (`features/onboarding/`) — ✅ Complete

- First-launch 3-screen PageView
- Completion state persisted via `OnboardingService`
- Custom SVG-style illustrations per screen

**Key components**: `OnboardingPage`, `OnboardingContentModel`

---

### Admin: Organization Management (`features/admin/organization_management/`) — ✅ Complete

- Organization profile (name, address, logo, description)
- `bookingLinkSlug` for customer deep-link URL generation
- Setup wizard for first-time admins

**Key components**: `AdminOrganizationRepository` (watch + CRUD), `OrganizationCubit`

---

### Admin: Service Management (`features/admin/service_management/`) — ✅ Complete

- Real-time service list (Firestore stream)
- Add / edit / delete services with duration and active flag
- Form validation

**Key components**: `AdminServiceRepository`, `ServiceCubit`, `ServiceFormCubit`

---

### Admin: Working Hours Management (`features/admin/working_hours_management/`) — ✅ Complete

- 7-day schedule configuration (open time, close time, optional break)
- Atomic batch save for all days
- Default initialization (Mon–Fri 09:00–17:00, Sat–Sun closed)
- Schedule validation (open < close, break within working hours)

**Key components**: `AdminWorkingHoursRepository`, `WorkingHoursCubit`

---

### Admin: Share Access (`features/admin/share_access/`) — ✅ Complete

- QR code display from `bookingLinkSlug`
- Native share sheet (URL + PNG file)
- Copy booking link to clipboard
- Download QR code to device gallery

**Key components**: `ShareAccessCubit`, `QrCodeDisplay`, `ShareActionButtons`

---

### Admin: Tutorial (`features/admin/tutorial/`) — ✅ Complete

- First-time admin overlay surfaced from `AdminDashboardTab`
- 3-step guided flow: confirm profile → add service → acknowledge ready
- Completion persisted in Firestore via `FirestoreUserDatasource`

**Key components**: `TutorialCubit`, `TutorialOverlay`, `TutorialStep`

---

### Admin: Dashboard (`features/admin/dashboard/`) — ✅ Complete

- Greeting header with date and time-of-day salutation
- Stats strip (in-queue / served / no-shows — hardcoded, live data Sprint 5)
- Now Serving card (placeholder, Sprint 5)
- Management grid (Services, Working Hours, Full Queue, Daily Summary)
- Share Access quick-action card
- Hosts `TutorialOverlay` as topmost Stack child

**Key components**: `AdminDashboardTab`, `ManagementGrid`, `NowServingCard`

---

### Admin: Queue Management (`features/admin/queue_management/`) — ⏳ Sprint 5

Interface only. `AdminAppointmentRepository` is defined; UI and cubit are pending.

---

### Customer: Booking (`features/customer/booking/`) — ✅ Complete

Full end-to-end customer booking flow:

1. **Organization landing** — org hero, open/closed status, services summary
2. **Service selection** — active services list
3. **Service details** — duration, description
4. **Slot picker** — date selector + available time slots (FR-010 algorithm)
5. **Booking form** — customer name, phone, notes
6. **Confirmation** — booking summary

**Domain repositories** (read-only):
- `CustomerOrganizationRepository` — `getOrganizationBySlug`
- `CustomerServiceRepository` — `getActiveServices`
- `CustomerWorkingHoursRepository` — `getWorkingHours`, `getWorkingHoursForDay`
- `CustomerAppointmentRepository` — `getAppointmentsForDate`, `createAppointment`

**Use cases**:
- `GetOrganizationBySlugUseCase`
- `GetActiveServicesUseCase`
- `CalculateAvailableSlotsUseCase` — FR-010 slot generation algorithm
- `CreateBookingUseCase`

**Key cubits**: `OrganizationLandingCubit`, `ServiceSelectionCubit`, `SlotPickerCubit`, `BookingFormCubit`

---

### Customer: Queue Status — ⏳ Future

Placeholder. Real-time queue position tracking.

---

### Admin: Daily Summary — ⏳ Sprint 7

Placeholder. Performance reports.

---

## Dependency Injection

### Setup: GetIt + Injectable

**Configuration**: `lib/core/di/injection.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
void configureDependencies({String? environment}) =>
    getIt.init(environment: environment);
```

### Registration Annotations

```dart
// Singleton (created eagerly at startup)
@singleton
class AppLogger { ... }

// Lazy Singleton (created on first access)
@lazySingleton
class AdminServiceRepositoryImpl implements AdminServiceRepository { ... }

// Factory (new instance on each request)
@injectable
class ServiceCubit { ... }

// Interface binding
@LazySingleton(as: AdminServiceRepository)
class AdminServiceRepositoryImpl implements AdminServiceRepository { ... }
```

### Initialization

```dart
// main_dev.dart / main_prod.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies(environment: Environment.dev);
  runApp(const QueueEaseApp());
}
```

### Usage

```dart
// In router / widget
BlocProvider(
  create: (_) => getIt<ServiceCubit>(),
  child: ServiceListPage(),
)
```

---

## Error Handling

### Exception Hierarchy

**Base**: `AppException` (sealed class)

**Subtypes**:
- `AuthException`: Firebase Auth errors
- `DatabaseException`: Firestore errors
- `StorageException`: Local storage errors
- `ValidationException`: Input validation errors
- `UnknownException`: Unexpected errors

### Result Type

```dart
sealed class Result<T> {
  static Future<Result<T>> guard<T>(Future<T> Function() body);

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  });

  T? getOrNull();
  T getOrElse(T fallback);
  Result<U> map<U>(U Function(T data) transform);
}
```

### Usage Pattern

```dart
// In cubit
Future<void> loadOrganization(String slug) async {
  emit(OrganizationLandingLoading());
  final result = await _getOrgBySlugUseCase(slug);
  result.when(
    success: (org) => emit(org != null
        ? OrganizationLandingLoaded(org)
        : const OrganizationLandingNotFound()),
    failure: (e) => emit(OrganizationLandingError(e.message)),
  );
}
```

---

## Navigation Architecture

### Router: GoRouter with RBAC

**Configuration**: `lib/core/router/app_router.dart`

**Route convention**:
- `/onboarding`: First-launch flow
- `/login`, `/signup`: Unauthenticated entry points
- `/a/*`: Admin-only routes
- `/c/*`: Customer-only routes
- `/debug/logs`: Dev-only log viewer (Talker)

### Route Table

| Route | Description |
|-------|-------------|
| `/onboarding` | Onboarding PageView |
| `/login` | Login page |
| `/signup` | Sign-up page |
| `/a/dashboard` | Admin shell (bottom-nav) |
| `/a/setup` | Organization setup wizard |
| `/a/org/profile` | Organization profile |
| `/a/org/edit` | Organization profile editor |
| `/a/services` | Service list |
| `/a/services/form` | Add / edit service |
| `/a/working-hours` | Working hours configuration |
| `/a/share-access` | QR code & link sharing |
| `/c/home` | Customer home |
| `/c/org/:slug` | Organization landing |
| `/c/org/:slug/services` | Service selection |
| `/c/org/:slug/service-details` | Service details |
| `/c/org/:slug/slots` | Slot picker |
| `/c/org/:slug/book` | Booking form |
| `/c/org/:slug/confirmation` | Booking confirmation |

### Route Protection

```dart
redirect: (context, state) async {
  final authState = authCubit.state;
  if (authState is Authenticated) {
    // Cross-role guard
    if (user.role == UserRole.admin && location.startsWith('/c/')) return Routes.adminDashboard;
    if (user.role == UserRole.customer && location.startsWith('/a/')) return Routes.customerHome;
  }
  if (authState is Unauthenticated) {
    final isProtected = location.startsWith('/a/') || location.startsWith('/c/');
    return isProtected ? Routes.login : null;
  }
  return null;
}
```

### Route Refresh on Auth State Change

```dart
refreshListenable: GoRouterRefreshStream(authCubit.stream),
```

---

## State Management

### Pattern: Cubit (from flutter_bloc)

All state in this project is managed with Cubit. Sealed classes are used for states to allow exhaustive pattern matching.

### State Class Conventions

```dart
// Sealed state hierarchy
sealed class ServiceState extends Equatable {
  const ServiceState();
}

final class ServiceInitial extends ServiceState { ... }
final class ServiceLoading extends ServiceState { ... }
final class ServiceLoaded extends ServiceState {
  final List<ServiceEntity> services;
  ...
}
final class ServiceError extends ServiceState {
  final String message;
  ...
}
```

### Cubit Implementation Pattern

```dart
@injectable
class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit(this._repository) : super(const ServiceInitial());

  final AdminServiceRepository _repository;
  StreamSubscription<Result<List<ServiceEntity>>>? _subscription;

  void watchServices(String orgId) {
    _subscription?.cancel();
    emit(const ServiceLoading());
    _subscription = _repository.watchServices(orgId).listen(
      (result) => result.when(
        success: (services) => emit(ServiceLoaded(services)),
        failure: (e) => emit(ServiceError(e.message)),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

---

## Platform-Specific Configurations

### Android

- `minSdkVersion`: 21
- `targetSdkVersion`: 34
- Firebase via `google-services.json`
- Gallery permissions for QR download (`WRITE_EXTERNAL_STORAGE` maxSdkVersion 32, `READ_MEDIA_IMAGES`)

### iOS

- Deployment Target: 12.0
- Firebase via `GoogleService-Info.plist`
- `NSPhotoLibraryAddUsageDescription` for QR code gallery save

### Third-Party Package Notes

| Package | Version | Usage |
|---------|---------|-------|
| `qr_flutter` | ^4.1.0 | QR code generation in `ShareAccessPage` |
| `share_plus` | ^12.0.1 | Native share sheet (URL + PNG) |
| `gal` | ^2.3.0 | Save QR PNG to device gallery |

---

## Testing Strategy

### Priority Order

1. **Unit tests** — all use cases and domain logic (mandatory)
2. **Integration tests** — critical user flows (auth, booking)
3. **Widget tests** — complex stateful widget behavior

### Test Structure

```
test/
├── core/
│   └── error/
│       ├── result_test.dart
│       └── app_exception_test.dart
├── shared/
│   ├── auth/
│   │   ├── auth_cubit_test.dart
│   │   └── data/models/user_model_test.dart
│   ├── onboarding/
│   │   └── onboarding_integration_test.dart
│   ├── organization/
│   │   ├── data/models/
│   │   │   ├── organization_model_test.dart
│   │   │   └── working_hours_model_test.dart
│   │   └── domain/entities/
│   │       ├── organization_entity_test.dart
│   │       ├── service_entity_test.dart
│   │       └── working_hours_entity_test.dart
│   ├── booking/
│   │   ├── data/models/appointment_model_test.dart
│   │   └── domain/entities/appointment_entity_test.dart
│   └── queue/
│       ├── data/models/queue_model_test.dart
│       └── domain/entities/queue_entity_test.dart
└── firebase_mocks.dart
```

### Testing Patterns

**Entity tests** — verify `Equatable` props and equality

**Model tests** — Firestore deserialization, serialization, `toEntity()` round-trip

**Cubit tests** — state transitions with `bloc_test` and `mocktail`

```dart
blocTest<ServiceCubit, ServiceState>(
  'emits [Loading, Loaded] when watchServices succeeds',
  build: () {
    when(() => mockRepo.watchServices(any()))
        .thenAnswer((_) => Stream.value(Success([testService])));
    return ServiceCubit(mockRepo);
  },
  act: (cubit) => cubit.watchServices('org1'),
  expect: () => [const ServiceLoading(), ServiceLoaded([testService])],
);
```

---

## Code Organization Guidelines

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | `snake_case.dart` | `auth_repository.dart` |
| Classes | `PascalCase` | `AuthRepository` |
| Variables/Methods | `camelCase` | `getUserById()` |
| Constants | `SCREAMING_SNAKE_CASE` | `const MAX_RETRIES = 3` |
| Private | Leading `_` | `_privateMethod()` |
| Enums | `PascalCase` values | `UserRole.admin` |

### Import Ordering (Effective Dart)

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. External packages (alphabetical)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Internal imports (relative when in same feature)
import '../../../../../core/error/result.dart';
import '../../domain/repositories/admin_service_repository.dart';
import 'service_state.dart';
```

### File Size Guidelines

- Functions over **30 lines** should be split
- Files over **200–300 lines** should be split
- These are warning signs, not hard rules — use judgment
