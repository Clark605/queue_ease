# Queue Ease - Architecture Documentation

**Last Updated:** February 21, 2026  
**Version:** 1.1.0+1  
**Architecture Pattern:** Clean Architecture with Feature-Based Modularization

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
10. [Testing Strategy](#testing-strategy)
11. [Code Organization Guidelines](#code-organization-guidelines)

---

## Overview

Queue Ease is built using **Clean Architecture** principles with a **feature-based modular structure**. The app is divided into three main organizational layers:

- **Core**: Shared infrastructure, utilities, and configuration
- **Shared**: Domain logic and UI components shared across user roles
- **Features**: Role-specific implementations (Admin & Customer)

### Technology Stack

- **Framework**: Flutter 3.9.0+
- **Language**: Dart 3.9.0+
- **State Management**: flutter_bloc (Cubit pattern)
- **Dependency Injection**: GetIt + Injectable
- **Navigation**: GoRouter 17.1.0
- **Backend**: Firebase (Auth, Firestore, Crashlytics)
- **Logging**: Talker + Talker BLoC Logger
- **Testing**: flutter_test, bloc_test, mocktail

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
│     (Entities, Repositories Interface)  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│   (Models, Datasources, Repositories)   │
└─────────────────────────────────────────┘
```

**Dependency Rule**: Dependencies flow **inward** only. Domain layer has no dependencies on external frameworks.

### 2. SOLID Principles

- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Clients depend on abstractions they use
- **Dependency Inversion**: Depend on abstractions, not concretions

### 3. Feature-Based Organization

Each feature is self-contained with its own data/domain/presentation layers:

```
feature_name/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── widgets/
    └── cubit/ (or bloc/)
```

---

## Project Structure

```
lib/
├── core/                           # Shared infrastructure
│   ├── app/                        # Application-level setup
│   │   ├── di/                     # Dependency injection
│   │   │   ├── injection.dart      # GetIt configuration
│   │   │   └── injection.config.dart
│   │   └── router/                 # Navigation
│   │       ├── app_router.dart     # GoRouter setup with RBAC
│   │       └── go_router_refresh_stream.dart
│   ├── config/                     # Configuration
│   │   ├── flavor_config.dart      # Dev/Prod environment config
│   │   └── app_constants.dart      # App-wide constants
│   ├── error/                      # Error handling framework
│   │   ├── result.dart             # Result<T> type
│   │   ├── app_exception.dart      # Exception hierarchy
│   │   └── error.dart              # Exports
│   ├── services/                   # Core services
│   │   ├── onboarding_service.dart # Onboarding state
│   │   └── user_session_service.dart # Session persistence
│   ├── utils/                      # Utilities
│   │   ├── app_logger.dart         # Logging with Talker
│   │   └── validators.dart         # Input validation
│   └── widgets/                    # Reusable UI components
│       ├── app_error_widget.dart
│       └── app_loading_indicator.dart
│
├── shared/                         # Shared domain logic (role-agnostic)
│   ├── auth/                       # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── firebase_auth_datasource.dart
│   │   │   │   ├── firestore_user_datasource.dart
│   │   │   │   └── google_sign_in_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── user_role.dart (enum: admin, customer)
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
│   │           ├── auth_header.dart
│   │           ├── auth_text_field.dart
│   │           ├── password_field.dart
│   │           ├── google_sign_in_button.dart
│   │           ├── auth_role_selector.dart
│   │           └── forgot_password_bottom_sheet.dart
│   │
│   ├── onboarding/                 # First-time user experience
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── onboarding_content_model.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── onboarding_page.dart
│   │       └── widgets/
│   │           ├── onboarding_content_widget.dart
│   │           └── page_indicator.dart
│   │
│   ├── organization/               # Organization management
│   │   ├── data/
│   │   │   └── models/
│   │   │       ├── organization_model.dart
│   │   │       ├── service_model.dart
│   │   │       └── working_hours_model.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── organization_entity.dart
│   │   │       ├── service_entity.dart
│   │   │       └── working_hours_entity.dart
│   │   └── presentation/           # (Future: Shared org widgets)
│   │
│   ├── booking/                    # Appointment booking
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── appointment_model.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── appointment_entity.dart
│   │   │       └── appointment_status.dart (enum)
│   │   └── presentation/           # (Future: Shared booking widgets)
│   │
│   └── queue/                      # Queue management
│       ├── data/
│       │   └── models/
│       │       └── queue_model.dart
│       ├── domain/
│       │   └── entities/
│       │       ├── queue_entity.dart
│       │       └── queue_status.dart (enum)
│       └── presentation/           # (Future: Shared queue widgets)
│
├── admin/                          # Admin-specific features
│   ├── dashboard/
│   │   └── presentation/
│   │       └── pages/
│   │           └── admin_dashboard_page.dart
│   ├── services/                   # (Future: Service CRUD)
│   ├── working_hours/              # (Future: Hours configuration)
│   ├── queue_management/           # (Future: Live queue control)
│   ├── share_access/               # (Future: QR & link generation)
│   └── daily_summary/              # (Future: Daily reports)
│
├── customer/                       # Customer-specific features
│   ├── entry/
│   │   └── presentation/
│   │       └── pages/
│   │           └── customer_home_page.dart
│   ├── booking_flow/               # (Future: Booking UI)
│   └── queue_status/               # (Future: Queue tracking)
│
├── firebase_options.dart           # Firebase configuration
├── main_dev.dart                   # Dev entrypoint
└── main_prod.dart                  # Prod entrypoint

test/                               # Mirror of lib/ structure
├── core/
│   └── error/
│       ├── result_test.dart
│       └── app_exception_test.dart
└── shared/
    ├── auth/
    │   └── auth_cubit_test.dart
    ├── onboarding/
    │   └── onboarding_integration_test.dart
    ├── organization/
    │   ├── data/models/
    │   │   ├── organization_model_test.dart
    │   │   ├── service_model_test.dart
    │   │   └── working_hours_model_test.dart
    │   └── domain/entities/
    │       ├── organization_entity_test.dart
    │       ├── service_entity_test.dart
    │       └── working_hours_entity_test.dart
    ├── booking/
    │   ├── data/models/
    │   │   └── appointment_model_test.dart
    │   └── domain/entities/
    │       └── appointment_entity_test.dart
    └── queue/
        ├── data/models/
        │   └── queue_model_test.dart
        └── domain/entities/
            └── queue_entity_test.dart
```

---

## Layer Responsibilities

### 1. Presentation Layer

**Location**: `lib/{shared,admin,customer}/*/presentation/`

**Responsibilities**:
- UI rendering (Pages, Widgets)
- User interaction handling
- State management (Cubit/BLoC)
- Navigation
- Displaying data from domain layer

**Rules**:
- ✅ Depend on domain layer (entities, repositories)
- ✅ Use dependency injection for repositories/cubits
- ❌ Never import data layer
- ❌ No business logic (delegate to domain)
- ❌ No direct Firebase/HTTP calls

**Example**:
```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository; // Domain interface

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await Result.guard(
      () => _repository.login(email, password),
    );
    result.when(
      success: (user) => emit(Authenticated(user)),
      failure: (e) => emit(AuthError(e.message)),
    );
  }
}
```

### 2. Domain Layer

**Location**: `lib/shared/*/domain/`

**Responsibilities**:
- Define business entities (pure Dart classes)
- Define repository interfaces (abstractions)
- Define use cases (future, not yet implemented)
- Business rules and validation logic

**Rules**:
- ✅ Pure Dart (no Flutter, Firebase, HTTP imports)
- ✅ Entities are `Equatable` for value comparison
- ✅ Enums for typed status values
- ❌ No implementation details
- ❌ No framework dependencies

**Example**:
```dart
// Entity
class OrganizationEntity extends Equatable {
  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.adminUid,
    required this.bookingLinkSlug,
    required this.isOpen,
    required this.createdAt,
    this.qrCodeUrl,
    this.address,
    this.logoUrl,
    this.description,
  });

  final String id;
  final String name;
  final String adminUid;
  final String bookingLinkSlug;
  final bool isOpen;
  final DateTime createdAt;
  final String? qrCodeUrl;
  final String? address;
  final String? logoUrl;
  final String? description;

  @override
  List<Object?> get props => [
    id, name, adminUid, bookingLinkSlug, isOpen, createdAt,
    qrCodeUrl, address, logoUrl, description,
  ];
}

// Repository interface
abstract interface class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
  });
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
```

### 3. Data Layer

**Location**: `lib/shared/*/data/`

**Responsibilities**:
- Implement domain repository interfaces
- Define data models (with Firestore mapping)
- Manage data sources (API, database, local storage)
- Map between models and entities
- Handle platform-specific exceptions

**Rules**:
- ✅ Implement domain repository interfaces
- ✅ Models extend domain entities
- ✅ Datasources handle platform APIs
- ✅ Map exceptions to `AppException` subtypes
- ❌ No UI/presentation logic

**Example**:
```dart
// Model (extends entity)
class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.adminUid,
    required super.bookingLinkSlug,
    required super.isOpen,
    required super.createdAt,
    super.qrCodeUrl,
    super.address,
    super.logoUrl,
    super.description,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] as String,
      adminUid: data['adminUid'] as String,
      bookingLinkSlug: data['bookingLinkSlug'] as String,
      isOpen: data['isOpen'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      qrCodeUrl: data['qrCodeUrl'] as String?,
      address: data['address'] as String?,
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'adminUid': adminUid,
      'bookingLinkSlug': bookingLinkSlug,
      'isOpen': isOpen,
      'createdAt': Timestamp.fromDate(createdAt),
      'qrCodeUrl': qrCodeUrl,
      'address': address,
      'logoUrl': logoUrl,
      'description': description,
    };
  }
}

// Repository implementation
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final FirestoreUserDatasource _userDatasource;
  final GoogleSignInDatasource _googleSignInDatasource;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final uid = await _authDatasource.signInWithEmail(email, password);
      return await _userDatasource.getUserById(uid);
    } on FirebaseAuthException catch (e, st) {
      throw AuthException.fromFirebase(e.code, stackTrace: st);
    }
  }
}
```

---

## Feature Modules

### Shared Features (Role-Agnostic)

#### 1. Authentication (`shared/auth`)

**Status**: ✅ Complete

**Responsibilities**:
- Email/password authentication
- Google Sign-In
- Password reset
- User session management
- Role-based access control

**Key Components**:
- `AuthCubit`: Manages authentication state
- `AuthRepository`: Auth operations interface
- `UserEntity`: User domain model with role
- `FirebaseAuthDatasource`: Firebase Auth integration
- `GoogleSignInDatasource`: Google Sign-In SDK integration

#### 2. Onboarding (`shared/onboarding`)

**Status**: ✅ Complete

**Responsibilities**:
- First-time user experience
- Feature introduction (3 screens)
- Completion state persistence

**Key Components**:
- `OnboardingPage`: PageView-based flow
- `OnboardingService`: Tracks completion status
- Custom illustrations for each screen

#### 3. Organization (`shared/organization`)

**Status**: 🚧 Data models complete, repositories pending

**Responsibilities**:
- Organization profile management
- Service definition and configuration
- Working hours setup

**Key Entities**:
- `OrganizationEntity`: Business profile
- `ServiceEntity`: Bookable services
- `WorkingHoursEntity`: Day-specific schedules

#### 4. Booking (`shared/booking`)

**Status**: 🚧 Data models complete, booking flow pending

**Responsibilities**:
- Appointment creation and management
- Time slot availability
- Booking conflict prevention

**Key Entities**:
- `AppointmentEntity`: Customer appointment
- `AppointmentStatus`: Enum (booked, inQueue, serving, completed, noShow)

#### 5. Queue (`shared/queue`)

**Status**: 🚧 Data models complete, queue logic pending

**Responsibilities**:
- Daily queue generation
- Queue order management
- Real-time queue updates

**Key Entities**:
- `QueueEntity`: Daily queue state
- `QueueStatus`: Enum (active, paused, closed)

### Role-Specific Features

#### Admin Features (`admin/`)

**Status**: ⏳ Basic dashboard only

**Planned Modules**:
- `services/`: Service CRUD operations
- `working_hours/`: Hours configuration
- `queue_management/`: Live queue control
- `share_access/`: QR code & link generation
- `daily_summary/`: Performance reports

#### Customer Features (`customer/`)

**Status**: ⏳ Basic home page only

**Planned Modules**:
- `booking_flow/`: Service selection & booking
- `queue_status/`: Real-time queue tracking

---

## Dependency Injection

### Setup: GetIt + Injectable

**Configuration**: `lib/core/app/di/injection.dart`

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
class AuthRepository { ... }

// Factory (new instance on each request)
@injectable
class AuthCubit { ... }

// Interface implementation
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository { ... }
```

### Initialization

```dart
// main_dev.dart / main_prod.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  configureDependencies(environment: Environment.dev); // or Environment.prod
  
  runApp(const QueueEaseApp());
}
```

### Usage

```dart
// In widget
final authCubit = getIt<AuthCubit>();

// In provider
BlocProvider(
  create: (_) => getIt<AuthCubit>(),
  child: LoginPage(),
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
  // Factory: wraps async calls
  static Future<Result<T>> guard<T>(Future<T> Function() body);
  
  // Pattern matching
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  });
  
  // Utilities
  T? getOrNull();
  T getOrElse(T fallback);
  Result<U> map<U>(U Function(T data) transform);
}
```

### Usage Pattern

```dart
// In repository
Future<UserEntity> login(String email, String password) async {
  try {
    final uid = await _authDatasource.signInWithEmail(email, password);
    return await _userDatasource.getUserById(uid);
  } on FirebaseAuthException catch (e, st) {
    throw AuthException.fromFirebase(e.code, stackTrace: st);
  } catch (e, st) {
    throw UnknownException('Login failed', cause: e, stackTrace: st);
  }
}

// In cubit
Future<void> login(String email, String password) async {
  emit(AuthLoading());
  final result = await Result.guard(
    () => _repository.login(email, password),
  );
  result.when(
    success: (user) => emit(Authenticated(user)),
    failure: (e) => emit(AuthError(e.message)),
  );
}
```

---

## Navigation Architecture

### Router: GoRouter with RBAC

**Configuration**: `lib/core/app/router/app_router.dart`

**Route Convention**:
- `/onboarding`: First-launch flow
- `/login`, `/signup`: Unauthenticated entry points
- `/a/*`: Admin-only routes
- `/c/*`: Customer-only routes
- `/debug/logs`: Dev-only log viewer

### Route Protection

```dart
redirect: (context, state) async {
  final authState = authCubit.state;
  final location = state.matchedLocation;
  
  // Authenticated guard
  if (authState is Authenticated) {
    final user = authState.user;
    
    // Cross-role guard
    if (user.role == UserRole.admin && location.startsWith('/c/')) {
      return Routes.adminDashboard;
    }
    if (user.role == UserRole.customer && location.startsWith('/a/')) {
      return Routes.customerHome;
    }
  }
  
  // Unauthenticated guard
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

This ensures the router re-evaluates guards whenever `AuthCubit` emits a new state.

---

## State Management

### Pattern: Cubit (from flutter_bloc)

**Why Cubit over Bloc?**
- Simpler API (direct methods vs. events)
- Sufficient for current use cases
- Easier to test

### State Classes

```dart
// Base sealed class for exhaustive pattern matching
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserEntity user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### Cubit Implementation

```dart
@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final UserSessionService _sessionService;

  AuthCubit(this._repository, this._sessionService) : super(AuthInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(AuthLoading());
    final user = await _sessionService.getStoredUser();
    emit(user != null ? Authenticated(user) : Unauthenticated());
  }

  Future<void> login(String email, String password) async { ... }
  Future<void> signOut() async { ... }
}
```

### BLoC Provider Setup

```dart
// In main.dart
BlocProvider<AuthCubit>(
  create: (_) => getIt<AuthCubit>(),
  child: MaterialApp.router(...),
)

// In widget
context.read<AuthCubit>().login(email, password);

// Listener
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      // Navigate to dashboard
    }
  },
  builder: (context, state) { ... },
)
```

---

## Testing Strategy

### Test Categories

1. **Unit Tests**: Domain entities, error handling, utilities
2. **Repository Tests**: Data layer with mocked datasources
3. **Cubit Tests**: State management with mocked repositories
4. **Integration Tests**: End-to-end flows
5. **Widget Tests**: UI components (future)

### Test Structure

```
test/
├── core/
│   └── error/
│       ├── result_test.dart         # Result type behavior
│       └── app_exception_test.dart   # Exception hierarchy
├── shared/
│   ├── auth/
│   │   └── auth_cubit_test.dart      # Auth state transitions
│   ├── organization/
│   │   ├── domain/entities/
│   │   │   ├── organization_entity_test.dart  # Equatable props
│   │   │   ├── service_entity_test.dart
│   │   │   └── working_hours_entity_test.dart
│   │   └── data/models/
│   │       ├── organization_model_test.dart   # Firestore mapping
│   │       ├── service_model_test.dart
│   │       └── working_hours_model_test.dart
│   ├── booking/
│   │   └── ...
│   └── queue/
│       └── ...
└── firebase_mocks.dart               # Shared test helpers
```

### Testing Approach

**Entity Tests**: Verify `Equatable` props and equality

```dart
test('should have correct equality', () {
  final entity1 = OrganizationEntity(/* ... */);
  final entity2 = OrganizationEntity(/* ... */); // same values
  expect(entity1, equals(entity2));
});
```

**Model Tests**: Round-trip Firestore serialization

```dart
test('fromFirestore -> toFirestore round trip', () {
  final doc = FakeDocumentSnapshot(/* ... */);
  final model = OrganizationModel.fromFirestore(doc);
  final map = model.toFirestore();
  expect(map['name'], equals('Test Org'));
});
```

**Cubit Tests**: State transitions with `bloc_test`

```dart
blocTest<AuthCubit, AuthState>(
  'emits [Loading, Authenticated] on successful login',
  build: () {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => testUser);
    return AuthCubit(mockRepository, mockSessionService);
  },
  act: (cubit) => cubit.login('test@example.com', 'password'),
  expect: () => [
    AuthLoading(),
    Authenticated(testUser),
  ],
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
| Constants | `camelCase` | `const apiTimeout = ...` |
| Private | Leading `_` | `_privateMethod()` |
| Enums | `PascalCase` values | `UserRole.admin` |

### Import Organization

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. External packages (alphabetical)
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 4. Internal imports (alphabetical, relative when in same feature)
import '../../../core/error/app_exception.dart';
import '../domain/entities/user_entity.dart';
import 'auth_state.dart';
```

### File Size Guidelines

- **Maximum**: 300-400 lines
- **Widgets**: Under 200 lines
- **Repositories**: Under 300 lines
- If larger, split into multiple files

### Documentation Standards

```dart
/// Brief one-line summary.
///
/// Detailed explanation spanning multiple paragraphs if needed.
///
/// Example:
/// ```dart
/// final result = await repository.login(email, password);
/// ```
///
/// See also:
/// - [AuthRepository]
/// - [UserEntity]
class AuthRepositoryImpl implements AuthRepository {
  /// Firebase authentication datasource.
  final FirebaseAuthDatasource _authDatasource;
  
  // ...
}
```

---

## Firestore Data Structure

### Organizations Collection

**Path**: `organizations/{orgId}`

**Fields**:
```json
{
  "name": "string",
  "adminUid": "string",
  "bookingLinkSlug": "string",
  "qrCodeUrl": "string?",
  "address": "string?",
  "isOpen": "bool",
  "logoUrl": "string?",
  "description": "string?",
  "createdAt": "timestamp"
}
```

**Subcollections**:
- `services/{serviceId}`: Services offered
- `working_hours/{dayOfWeek}`: Hours (where `dayOfWeek` = 0-6)
- `appointments/{appointmentId}`: Customer appointments
- `queues/{date}`: Daily queues (where `date` = "YYYY-MM-DD")

### Users Collection

**Path**: `users/{uid}`

**Fields**:
```json
{
  "email": "string",
  "name": "string",
  "role": "string", // "admin" | "customer"
  "organizationId": "string?", // For admins
  "createdAt": "timestamp"
}
```

---

## Environment Configuration

### Flavors: Dev & Prod

**Files**:
- `lib/main_dev.dart`: Development entry point
- `lib/main_prod.dart`: Production entry point
- `lib/core/config/flavor_config.dart`: Flavor configuration

**Configuration**:
```dart
class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final bool enableDevicePreview;
  final LogLevel logLevel;

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
```

**Running**:
```bash
# Dev build
flutter run -t lib/main_dev.dart

# Prod build
flutter run -t lib/main_prod.dart
```

---

## Logging

### AppLogger with Talker

**Setup**: `lib/core/utils/app_logger.dart`

```dart
@singleton
class AppLogger {
  late final Talker talker;

  AppLogger() {
    talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: FlavorConfig.instance.isDev,
      ),
    );
  }

  void debug(String message) => talker.debug(message);
  void info(String message) => talker.info(message);
  void warning(String message) => talker.warning(message);
  void error(String message, [Object? exception, StackTrace? stackTrace]) {
    talker.error(message, exception, stackTrace);
  }
}
```

**Usage**:
```dart
final logger = getIt<AppLogger>();
logger.info('User logged in: ${user.email}');
logger.error('Login failed', exception, stackTrace);
```

**Dev-Only Log Viewer**: Navigate to `/debug/logs` in dev builds to view in-app logs.

---

## Future Enhancements

### Architectural Improvements

1. **Use Cases Layer**: Extract business operations into dedicated use case classes
   - Example: `LoginUseCase`, `BookAppointmentUseCase`
   - Benefit: Better testability, cleaner cubits

2. **Repository Pattern for All Features**: Implement repositories for organization, booking, and queue

3. **Offline Support**: Add local caching with `sqflite` or `hive`

4. **Advanced Error Recovery**: Retry logic, exponential backoff

5. **Performance Monitoring**: Firebase Performance + custom metrics

6. **CI/CD Pipeline**: GitHub Actions for testing and deployment

---

## References

### Internal Documents

- [PRD.md](PRD.md) - Product requirements
- [entities.md](entities.md) - Domain model specification
- [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md) - Implementation tracking
- [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) - Development schedule

### External Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter & Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)
- [flutter_bloc Documentation](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

**Document Maintained By**: Architecture Team  
**Review Cycle**: Updated after each major feature implementation  
**Questions**: Open an issue or contact the tech lead
