# Queue Ease - Cross-Tool Project Instructions

These instructions apply to all AI tools working in this repository.

## Engineering Rules

### 1. Clean Code Priority
- I want you to always prioritize **clarity over cleverness**
- Write code that any teammate can read without ever having seen it before
- Make sure everything you write is searchable by keyword and maintainable without me
- If you need a comment to explain what a line does, rewrite the line instead

### 2. Small Files and Functions
- I expect you to follow the **Single Responsibility** principle strictly
- Every function you write should do one thing; every file should own one concept
- If a function goes over **30 lines**, split it
- If a file goes over **200–300 lines**, split it
- Treat these as warning signs, not hard rules — use judgment

### 3. Minimalist Commenting
- Only add a comment when the **"why" is not obvious** from the code itself
- Never comment *what* the code is doing — only *why* it does it that way
- Delete any stale, redundant, or obvious comments you come across

### 4. Avoid Over-Engineering
- Do not introduce patterns, abstractions, or layers unless the problem **concretely requires** them
- Apply YAGNI — You Aren't Gonna Need It
- Before adding an abstraction, ask yourself: *does this solve a real problem I have today?*
- If the answer is "maybe later," don't add it

### 5. DRY — Avoid Duplication
- Never duplicate logic, UI fragments, or validation rules
- Before writing something new, search the codebase first
- If you find yourself copying more than 2–3 lines, extract it into a shared function or widget
- Remember: DRY applies to strings, constants, and config values too — not just functions

### 6. Naming Conventions
- I expect you to follow official **Dart naming conventions** without exception:
	- `snake_case` → files and directories
	- `PascalCase` → classes, enums, typedefs
	- `camelCase` → variables, parameters, functions
	- `SCREAMING_SNAKE_CASE` → top-level constants
- Every name you choose must be self-documenting — write `fetchUserOrders()`, not `getData()`

### 7. Strict Clean Architecture
- I want you to maintain a strict **three-layer architecture** at all times:
	- **Data Layer** — repositories, data sources, DTOs, API/DB calls
	- **Domain Layer** — entities, use cases, abstract repository interfaces, pure business logic
	- **Presentation Layer** — UI widgets, state management, view models
- The Domain Layer you write must have **zero dependencies** on Flutter or any external packages

### 8. Separation of Concerns
- Put business logic, validation, and decision-making in the **Domain Layer only**
- The UI layer you write should only receive state and dispatch events — it must make no decisions
- Data sources should only transform raw responses into DTOs — apply no business rules there
- Never put logic inside widgets

### 9. Layer Communication Rules
- Only let layers communicate through **defined contracts (abstract classes / interfaces)**:
	- Presentation → Domain via use cases
	- Domain → Data via repository abstractions (defined in Domain, implemented in Data)
- Never access a layer directly across boundaries — calling a datasource from a widget is **strictly forbidden**

### 10. Core Folder Management
- Always maintain a `core/` folder for everything shared across features:
	```
	core/
		constants/
		extensions/
		theme/
		widgets/       # truly shared, reusable widgets only
		utils/
		errors/
	```
- Never let features reach into each other's folders
- Promote any shared logic to `core/` immediately

### 11. Consistent State Management
- Use **Bloc/Cubit** for every feature — no exceptions
- Never mix approaches (no `setState` inside a Bloc-managed screen, no ad-hoc `ValueNotifier` for stateful logic)
- I value consistency across the codebase over any personal preference you might have

### 12. Root Cause Problem Solving
- Always identify and fix the **root cause** of a bug, not its symptoms
- Before you apply any fix, tell me clearly: *what is the root cause?*
- If you can't answer that, keep investigating — don't guess
- Band-aid fixes that suppress errors or hide bad state are **forbidden**

### 13. Minimal Surface Changes
- When fixing a bug or adding a feature, make the **smallest reasonable change** to the existing system
- Do not refactor unrelated code in the same step
- Do not rename variables or restructure files "while you're in there"
- Every unrelated change you make introduces unrelated risk

### 14. Repository Pattern Consistency
- Follow the **existing patterns** in the repository, even if you disagree with them
- I care more about uniformity across the codebase than your individual preference
- If you think a pattern should change, flag it to me separately — never mix it into feature work

### 15. Flutter Performance Awareness
- Always use `const` constructors wherever possible
- Mark every non-reassigned variable as `final`
- Never build large widget trees inside `setState` callbacks
- Always use `ListView.builder` (not `ListView`) for dynamic lists
- Profile with DevTools before suggesting optimizations — never guess at bottlenecks

### 16. Performance-First Refactoring
- When you refactor, prioritize decisions that improve speed and reduce memory usage
- Measure performance before and after — show me the difference
- If a refactor improves readability but hurts performance, justify it explicitly
- Never optimize prematurely — only what profiling confirms is a real problem

### 17. No Silent Failures
- **Never swallow exceptions silently** — I won't accept it
- Every `catch` block you write must do one of: re-throw, log with full context, or map to a user-facing error state
- Never show a generic "Something went wrong" alert with no context
- Every error must be specific, actionable, and traceable in logs

### 18. Security Standards
- Never commit API keys, secrets, or credentials to version control
- Use `.env` files with `flutter_dotenv` or equivalent, and always add them to `.gitignore`
- Always use a dedicated **logger class** in production that strips or masks sensitive fields (tokens, passwords, card numbers)
- Never log raw API responses in production builds

### 19. Dependency Management
- Do not add a package unless you have a **clear, justified reason** that can't be met by existing dependencies or the SDK
- Before adding any package, verify it is:
	- Actively maintained (recent commits, open issues addressed)
	- On the latest stable version
	- Compatible with the current Flutter/Dart SDK version
- Always prefer Dart/Flutter SDK-native solutions over third-party packages when they're equivalent

### 20. You Are My Senior Engineering Partner
- I expect you to behave as a **senior engineering partner**, not a code generator
- Actively flag it when my proposed approach has architectural issues
- Suggest a better alternative when a simpler or more idiomatic solution exists
- Push back on requirements that seem unclear or contradictory
- If something I ask for violates these rules, flag it explicitly before proceeding

### 21. You Must Verify Before You Change
- Before suggesting or making any change, **read the relevant files first**
- Never assume how existing code behaves — verify it
- If you need to review a file to give a safe answer, review it before answering
- Never suggest a change that could silently break unread parts of the codebase

### 22. Generate Metadata When Done
- Once I mark a task as **"done"**, I expect you to automatically output:
	- A **branch name** following: `type/short-description`
		- e.g., `feat/gas-station-filter`, `fix/auth-token-refresh`
	- A **commit message** following Conventional Commits: `type(scope): description`
	- A **PR description** covering: summary of changes, affected layers, and testing notes

### 23. Latest Dart & Flutter Practices
- Always use the most current stable Dart/Flutter APIs and idioms
- Prefer **Sealed classes** (Dart 3+) over `Freezed` for union types where the use case is simple
- Prefer **Records and patterns** (Dart 3+) for destructuring and local data grouping
- Prefer **named constructors** over factory methods for simple cases
- When you encounter deprecated APIs, flag them to me and migrate — never leave them in place

### 24. Optimized Import Ordering
- Always follow **Effective Dart** import ordering (enforced via `dart fix`):
	```dart
	// 1. Dart SDK imports
	import 'dart:async';

	// 2. Flutter imports
	import 'package:flutter/material.dart';

	// 3. External package imports
	import 'package:bloc/bloc.dart';

	// 4. Internal/local imports
	import '../core/theme/app_colors.dart';
	```

### 25. Testing Discipline
- Write tests in this priority order:
	1. **Unit tests** for all use cases and domain logic — this is mandatory
	2. **Integration tests** for critical user flows (e.g., auth, checkout)
	3. **Widget tests** only for complex, stateful widget behavior
- Any use case or repository method with non-trivial logic that you ship without a unit test is **incomplete**
- Place all tests in `test/` mirroring the `lib/` folder structure exactly

## Quick Reference

```bash
# Dev build (use this for local development)
rtk flutter run --flavor dev -t lib/main_dev.dart

# Prod build
rtk flutter run --flavor prod -t lib/main_prod.dart

# Run tests
rtk flutter test

# Run specific test file
rtk flutter test test/path/to/test_file.dart

# Code generation (after DI annotation changes)
rtk flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
rtk flutter analyze
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

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan:
specs/chore/spec7-prep-checkpoint/plan.md
<!-- SPECKIT END -->
