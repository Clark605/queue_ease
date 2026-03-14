# Queue Ease - Claude Code Instructions

## Engineering Rules

Follow all rules in [.github/copilot-instructions.md](../.github/copilot-instructions.md). Those 25 rules are the supreme authority for code quality, architecture, performance, security, and AI collaboration patterns.

## Quick Reference

```bash
# Dev build (use this for local development)
flutter run --flavor dev -t lib/main_dev.dart

# Prod build
flutter run --flavor prod -t lib/main_prod.dart

# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Code generation (after DI annotation changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze
```

## Project Overview

**Queue Ease** is a smart queue management app for businesses and customers. Two user roles: **Admin** (manages organization, services, queues) and **Customer** (books appointments, tracks queue position). Backend is Firebase (Auth, Firestore, Crashlytics).

**Version**: 1.3.0+1 | **Dart SDK**: ^3.9.0 | **Flutter**: Stable channel

## Architecture

Feature-first Clean Architecture with three layers per feature: `data/`, `domain/`, `presentation/`.

```
lib/
  core/                          # Shared infrastructure
    config/                      # FlavorConfig, AuthModule, ConfigModule
    di/                          # GetIt + Injectable (injection.dart)
    error/                       # Sealed AppException + Result<T>
    router/                      # GoRouter with RBAC guards
    services/                    # OnboardingService, UserSessionService
    theme/                       # AppTheme, AppColors, AppTextStyles
    utils/                       # AppLogger (Talker), AppSnackBar
    widgets/                     # Shared reusable widgets
  features/
    admin/
      app_section/               # Admin shell (main page, settings)
      dashboard/                 # Admin home tab
      daily_summary/             # Daily queue summary
      organization_management/   # Org CRUD (data/domain/presentation)
      service_management/        # Service CRUD (data/domain/presentation)
      working_hours_management/  # Weekly hours config
      queue_management/          # Queue operations
      share_access/              # QR code + link sharing
      tutorial/                  # Admin onboarding tutorial
    authentication/              # Login, signup, auth state (shared across roles)
    customer/
      booking/                   # Full booking flow with use cases
      entry/                     # Customer home
    onboarding/                  # First-launch intro screens
    shared_domain/               # Cross-feature entities and models
      entities/                  # OrganizationEntity, ServiceEntity, AppointmentEntity, QueueEntity, WorkingHoursEntity
      models/                    # Firestore serialization (fromDoc/toMap/toEntity)
  main_dev.dart                  # Dev entry point (.env.dev, verbose logging, device preview)
  main_prod.dart                 # Prod entry point (.env.prod, Crashlytics, error-only logging)
```

## Key Patterns

### Error Handling (MANDATORY)

All async operations return `Result<T>` (sealed class in `lib/core/error/result.dart`):

```dart
// In repository
Future<Result<List<ServiceEntity>>> getServices(String orgId) async {
  return Result.guard(() async {
    // ... Firestore call, map to entities
  });
}

// In cubit - pattern match with switch
final result = await _repository.getServices(orgId);
switch (result) {
  case Success(:final data):
    emit(ServiceLoaded(data));
  case Failure(:final exception):
    emit(ServiceError(exception.message));
}
```

`AppException` hierarchy (sealed class in `lib/core/error/app_exception.dart`):
- `AuthException` - Firebase Auth errors (has `factory AuthException.fromFirebase(code)`)
- `DatabaseException` - Firestore/remote data errors
- `StorageException` - SharedPreferences/local storage errors
- `ValidationException` - Client-side validation (has optional `field`)
- `UnknownException` - Catch-all (has optional `cause`)

### State Management

Cubit pattern exclusively (never full BLoC). States use sealed class hierarchy with Equatable:

```dart
sealed class FeatureState extends Equatable { const FeatureState(); }
final class FeatureInitial extends FeatureState { ... }
final class FeatureLoading extends FeatureState { ... }
final class FeatureLoaded extends FeatureState { final List<Entity> items; ... }
final class FeatureError extends FeatureState { final String message; ... }
```

Cubits are `@injectable` (factory for screen-scoped, lazy singleton for shared like `AuthCubit`).

### Dependency Injection

GetIt + Injectable. Modules provide Firebase instances (`AuthModule`) and config (`ConfigModule`).

- **Singletons**: `AppLogger`
- **Lazy singletons**: datasources, repositories, shared cubits (`AuthCubit`), services
- **Factory**: screen-scoped cubits

After adding/changing `@injectable` annotations, run: `flutter pub run build_runner build --delete-conflicting-outputs`

### Firestore Model Pattern

Subcollection models take `orgId` as a parameter in `fromDoc` (orgId is in the path, not the document):

```dart
factory ServiceModel.fromDoc(DocumentSnapshot doc, {required String orgId}) { ... }
Map<String, dynamic> toMap()    // excludes orgId (encoded in path)
ServiceEntity toEntity()        // converts to domain entity
```

### Routing

GoRouter with RBAC redirect guards in `lib/core/router/app_router.dart`. Route constants in `abstract final class Routes`:
- Admin routes: `/a/dashboard`, `/a/setup`, `/a/services`, `/a/working-hours`, etc.
- Customer routes: `/c/home`, `/c/org/:slug`, `/c/org/:slug/services`, `/c/org/:slug/book`, etc.
- Auth routes: `/login`, `/signup`, `/onboarding`
- Dev-only: `/debug/logs` (TalkerScreen, registered only when `FlavorConfig.instance.isDev`)

### Logging

Use `AppLogger` (singleton, backed by Talker). Never use `print()`.
- Dev: verbose logging, `TalkerBlocObserver` logs all BLoC events
- Prod: error-only, errors forwarded to Crashlytics

## Conventions to Follow

### When Adding a New Feature

1. Create under `lib/features/admin/<feature_name>/` or `lib/features/customer/<feature_name>/`
2. Add `data/`, `domain/`, `presentation/` subdirectories as needed
3. Domain layer: abstract repository interface, entities (if new)
4. Data layer: datasource (Firestore), repository impl, model (if new entity)
5. Presentation layer: cubit + state (sealed), pages, widgets
6. Register in DI with `@injectable` / `@lazySingleton` annotations
7. Run `build_runner` to regenerate `injection.config.dart`
8. Add route in `app_router.dart` with appropriate guards
9. Shared entities/models go in `lib/features/shared_domain/`

### When Adding a New Entity

1. Entity in `lib/features/shared_domain/entities/` - extend `Equatable`, use `const` constructor, add `copyWith()`
2. Model in `lib/features/shared_domain/models/` - implement `fromDoc()`, `toMap()`, `toEntity()`
3. Status enums in `lib/features/shared_domain/entities/`
4. Tests: entity equality tests + model round-trip serialization tests

### Test Structure

Tests mirror `lib/` structure under `test/`. Use `mocktail` for mocking, `bloc_test` for Cubit testing:

```dart
blocTest<ServiceCubit, ServiceState>(
  'emits [Loading, Loaded] when watchServices succeeds',
  build: () => ServiceCubit(mockRepository, mockLogger),
  act: (cubit) => cubit.watchServices('orgId'),
  expect: () => [const ServiceLoading(), ServiceLoaded(testServices)],
);
```

Firebase mocks available in `test/firebase_mocks.dart` - call `setupFirebaseCoreMocks()` in `setUpAll`.

### Branching

- `main`: production-ready, protected
- `develop`: integration branch
- `feature/###-name`: feature work
- `hotfix/###-description`: production fixes

## Gotchas

- **No `main.dart`**: use `main_dev.dart` or `main_prod.dart` as entry points
- **Generated DI file**: `lib/core/di/injection.config.dart` is auto-generated; never edit manually
- **Firebase options**: `lib/firebase_options.dart` uses `FirebaseOptionsFactory.getOptions(Flavor)` - two Firebase projects (dev: `ease-queue-dev`, prod: `ease-queue`)
- **Env files**: `.env.dev` and `.env.prod` loaded via `flutter_dotenv`; never commit these
- **Subcollection models**: `orgId` comes from the Firestore path, not the document fields; always pass it to `fromDoc`
- **AuthCubit is a lazy singleton**: shared across router and widget tree; don't create duplicate instances
- **FlavorConfig is a singleton**: initialized once at startup; throws `StateError` on double init
- **Admin routes start with `/a/`**, customer routes with `/c/`; cross-role guards prevent access
