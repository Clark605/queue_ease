# Queue Ease Development Guidelines

Auto-generated project context for .specify agents. Last updated: February 25, 2026

## Project Overview

**Name**: Queue Ease (Appointment & Queue Manager)  
**Version**: 1.1.0+1  
**Repository**: Clark605/queue_ease  
**Default Branch**: main  
**Active Branch**: develop  
**Timeline**: 5-6 weeks remaining for MVP (target: mid-May 2026)  
**Progress**: ~35-40% complete (Phase 1 Foundation + Data Models ✅)

**Governance**: All development must align with [Constitution v1.0.0](constitution.md)

---

## Active Technologies

### Core Framework
- **Flutter**: 3.9.0+ (Mobile UI framework)
- **Dart**: 3.9.0+ (with sealed classes, pattern matching, records)

### Architecture & Patterns
- **Clean Architecture**: 3-layer separation (Domain → Data → Presentation)
- **State Management**: flutter_bloc (Cubit pattern, NOT full BLoC)
- **Dependency Injection**: GetIt singleton + Injectable code generation
- **Navigation**: GoRouter 17.1.0 with RBAC guards
- **Error Handling**: Result<T> monad with sealed AppException hierarchy

### Backend & Services
- **Firebase Authentication**: Email/password, Google Sign-In
- **Cloud Firestore**: NoSQL database (5 collections)
- **Firebase Crashlytics**: Error reporting integrated with Talker
- **Firebase Cloud Messaging**: Planned for push notifications

### Testing & Quality
- **Unit Testing**: flutter_test (target: 80%+ coverage)
- **Widget Testing**: flutter_test (target: 70%+ coverage)
- **Mocking**: mocktail
- **BLoC Testing**: bloc_test
- **Pattern**: Given-When-Then with AAA (Arrange-Act-Assert)

### Code Generation
- **Injectable**: @injectable, @lazySingleton for DI
- **Freezed**: Not used (manual sealed classes preferred)
- **JSON Serialization**: Manual fromDoc()/toMap()/toEntity()

---

## Project Structure

```text
lib/
├── core/                           # Shared infrastructure
│   ├── di/                        # GetIt DI setup (injection.config.dart)
│   ├── error/                     # Result<T> & AppException hierarchy
│   │   ├── result.dart            # Sealed Result with guard(), when()
│   │   └── app_exception.dart     # 5 sealed subtypes (Auth, Database, Storage, Validation, Unknown)
│   ├── logging/                   # AppLogger with Talker integration
│   ├── navigation/                # GoRouter config with RBAC
│   └── theme/                     # AppTheme & design tokens
│
├── shared/                        # Role-agnostic domain logic
│   ├── auth/                      # Authentication module
│   │   ├── data/                  # AuthRepository impl, datasources
│   │   ├── domain/                # UserEntity
│   │   └── presentation/          # AuthCubit, login/signup pages
│   │
│   ├── organization/              # Organization domain
│   │   ├── domain/entities/       # OrganizationEntity, ServiceEntity, WorkingHoursEntity
│   │   └── data/models/           # Firestore models with serialization
│   │
│   ├── booking/                   # Booking domain
│   │   ├── domain/entities/       # AppointmentEntity + AppointmentStatus enum
│   │   └── data/models/           # AppointmentModel
│   │
│   ├── queue/                     # Queue domain
│   │   ├── domain/entities/       # QueueEntity + QueueStatus enum
│   │   └── data/models/           # QueueModel
│   │
│   └── onboarding/                # Onboarding flow (COMPLETE)
│       └── presentation/          # 3-screen swipeable UI with illustrations
│
├── admin/                         # Admin-specific features
│   └── dashboard/                 # Basic admin dashboard (COMPLETE)
│
└── customer/                      # Customer-specific features
    └── dashboard/                 # Basic customer dashboard (COMPLETE)

test/                              # Mirror of lib/ structure
├── core/error/                    # Result & AppException tests
├── shared/auth/                   # AuthCubit tests (✅ complete)
├── shared/organization/           # Entity + Model tests (✅ complete)
├── shared/booking/                # Entity + Model tests (✅ complete)
└── shared/queue/                  # Entity + Model tests (✅ complete)

docs/                              # Technical documentation
├── ARCHITECTURE.md                # Comprehensive architecture guide
├── PRD.md                         # Product requirements
├── ENTITIES.md                    # Domain model specifications
├── FEATURE_CHECKLIST.md           # Implementation status tracker
├── PROJECT_TIMELINE.md            # Gantt chart & timeline
└── README.md                      # Documentation index

.specify/                          # Specify.ai agent files
├── memory/
│   ├── constitution.md            # Project governance (6 core principles)
│   └── agent.md                   # This file
└── templates/                     # .specify templates for planning
```

---

## Domain Model (5 Core Entities)

### 1. OrganizationEntity
**Path**: `lib/shared/organization/domain/entities/organization_entity.dart`  
**Firestore**: `organizations/{orgId}`  
**Fields**: `id`, `name`, `adminUserId`, `services`, `workingHours`, `createdAt`  
**Status**: ✅ Complete (entity, model, tests)

### 2. ServiceEntity
**Path**: `lib/shared/organization/domain/entities/service_entity.dart`  
**Firestore**: Embedded in Organization  
**Fields**: `id`, `name`, `durationMinutes`, `timeMarginMinutes`, `isActive`  
**Status**: ✅ Complete (entity, model, tests)

### 3. WorkingHoursEntity
**Path**: `lib/shared/organization/domain/entities/working_hours_entity.dart`  
**Firestore**: Embedded in Organization  
**Fields**: `dayOfWeek`, `startTime`, `endTime`, `isOpen`  
**Status**: ✅ Complete (entity, model, tests)

### 4. AppointmentEntity
**Path**: `lib/shared/booking/domain/entities/appointment_entity.dart`  
**Firestore**: `appointments/{appointmentId}`  
**Fields**: `id`, `orgId`, `serviceId`, `customerUserId`, `scheduledTime`, `durationMinutes`, `status`, `createdAt`  
**Enums**: `AppointmentStatus` (scheduled, inProgress, completed, cancelled, noShow)  
**Status**: ✅ Complete (entity, model, tests)

### 5. QueueEntity
**Path**: `lib/shared/queue/domain/entities/queue_entity.dart`  
**Firestore**: `queues/{orgId-date}`  
**Fields**: Composite `id` (orgId-date), `orgId`, `date`, `orderedAppointmentIds`, `currentServingIndex`, `status`, `generatedAt`  
**Enums**: `QueueStatus` (pending, active, paused, completed)  
**Status**: ✅ Complete (entity, model, tests)

---

## Commands

### Development
```bash
# Run with dev environment
flutter run --debug -t lib/main_dev.dart --flavor dev

# Run with prod environment
flutter run --release -t lib/main_prod.dart --flavor prod

# Generate DI code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test
flutter test --coverage
flutter test test/shared/auth/auth_cubit_test.dart  # Single test file

# Analyze code
flutter analyze
dart format lib/ test/ --set-exit-if-changed
```

### Firebase
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Start emulators (ports: Auth 9099, Firestore 8080)
firebase emulators:start

# View Crashlytics
firebase crashlytics:report
```

---

## Code Style (Dart/Flutter)

### Required Patterns

1. **Error Handling**: ALL async operations MUST use Result<T>
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

2. **Entity Equality**: ALL entities extend Equatable
   ```dart
   class OrganizationEntity extends Equatable {
     const OrganizationEntity({required this.id, ...});
     
     @override
     List<Object?> get props => [id, name, adminUserId, ...];
   }
   ```

3. **Firestore Serialization**: ALL models have fromDoc(), toMap(), toEntity()
   ```dart
   class OrganizationModel {
     factory OrganizationModel.fromDoc(DocumentSnapshot doc);
     Map<String, dynamic> toMap();
     OrganizationEntity toEntity();
   }
   ```

4. **State Management**: Cubit pattern (NOT full BLoC)
   ```dart
   class AuthCubit extends Cubit<AuthState> {
     AuthCubit(this._repository) : super(AuthInitial());
     // Methods emit states directly, NO events
   }
   ```

5. **Dependency Injection**: Injectable annotations
   ```dart
   @injectable  // For dependencies
   @lazySingleton  // For singletons (repositories, services)
   ```

### Linter Rules (analysis_options.yaml)
- `prefer_single_quotes`: Use 'string' not "string"
- `camel_case_types`: PascalCase for classes
- `always_declare_return_types`: Explicit return types
- `avoid_print`: Use AppLogger instead
- Excludes: `**/*.g.dart`, `**/*.config.dart`, `build/`

---

## Recent Changes

### Phase 1: Foundation (COMPLETED February 25, 2026)
**What it added:**
- Authentication system with email/password + Google Sign-In
- RBAC with GoRouter guards (/admin/* vs /customer/*)
- Complete onboarding flow (3 screens with custom illustrations)
- Error handling framework (Result<T>, AppException, AppLogger)
- Basic admin & customer dashboards
- Firebase Crashlytics integration

**Key files:**
- `lib/core/error/`: result.dart, app_exception.dart
- `lib/core/navigation/`: app_router.dart with RBAC
- `lib/shared/auth/`: Complete auth module with tests
- `lib/shared/onboarding/`: Complete onboarding flow

### Data Models (COMPLETED February 25, 2026)
**What it added:**
- ALL 5 core domain entities (Organization, Service, WorkingHours, Appointment, Queue)
- ALL 5 Firestore models with serialization
- 15+ unit tests for entities and models
- Constitution v1.0.0 ratified with 6 core principles

**Key files:**
- `lib/shared/organization/domain/entities/`: organization_entity.dart, service_entity.dart, working_hours_entity.dart
- `lib/shared/booking/domain/entities/`: appointment_entity.dart
- `lib/shared/queue/domain/entities/`: queue_entity.dart
- `test/shared/*/`: All entity and model tests
- `.specify/memory/constitution.md`: Project governance

### Constitution v1.0.0 (Ratified February 25, 2026)
**What it added:**
- 6 Core Principles: Code Quality First, Flexibility, Testing NON-NEGOTIABLE, UX Consistency, Fast Delivery, Performance
- Technical Standards: Mandatory Result<T> pattern, AppException hierarchy extensibility rules
- Domain-Specific Rules: Time margin policy enforcement, MVP scope constraints
- Code Review Gates: 7 mandatory checks with auto-reject scenarios
- Amendment process: Major (BREAKING), Minor (additive), Patch (clarification)

**Key files:**
- `.specify/memory/constitution.md`: Full governance document
- `docs/README.md`: Updated to reference constitution

---

## Critical Business Rules

### Time Margin Policy (NON-NEGOTIABLE)
**Requirement**: Each service has a configurable time margin (e.g., 5-10 minutes). When a customer's turn starts, if they don't check in within the margin, the appointment automatically becomes `noShow` and the queue advances.

**Implementation**:
- Time margin stored in `ServiceEntity.timeMarginMinutes`
- Server-side enforcement via Firestore Functions (prevent client manipulation)
- Status: Defined in entities, enforcement NOT YET IMPLEMENTED

### RBAC Enforcement
**Requirement**: Admin and customer must have separate routes with strict access control.

**Implementation**:
- GoRouter with `AuthRedirect` wrapper
- Route guards check `UserEntity.role`
- Admin routes: `/admin/*`
- Customer routes: `/customer/*`
- Status: ✅ IMPLEMENTED in `lib/core/navigation/app_router.dart`

### MVP Scope Constraint
**Out of Scope**: DO NOT implement these features (per constitution §3.2):
- Online payments
- Multi-branch support
- Video calls
- Advanced analytics dashboards
- Multi-language support

---

## Next Steps (Phase 2 - Repository Layer)

**Priority 1: Repository Infrastructure (3 days)**
- [ ] Implement Firestore security rules (organizations, appointments, queues)
- [ ] Create OrganizationRepository with CRUD operations
- [ ] Create AppointmentRepository with CRUD operations
- [ ] Create QueueRepository with CRUD operations
- [ ] Write repository unit tests with mocktail

**Priority 2: Admin Service Management (4 days)**
- [ ] ServiceManagementCubit (create, update, delete services)
- [ ] Service list UI (admin dashboard)
- [ ] Service form UI (create/edit dialog)
- [ ] Working hours configuration UI
- [ ] Widget tests for service management

**Priority 3: Customer Booking Flow (5 days)**
- [ ] Organization landing page (via QR code/link)
- [ ] Service selection UI
- [ ] Time slot selection UI
- [ ] Appointment booking cubit
- [ ] Real-time availability checking

---

## Testing Strategy

### Unit Tests (Target: 80%+)
- Test ALL Cubit state transitions
- Test ALL repository methods (with mock datasources)
- Test ALL entity equality and props
- Test ALL model serialization (round-trip)
- Test ALL error scenarios (AuthException, DatabaseException, etc.)

### Widget Tests (Target: 70%+)
- Test ALL page renders without errors
- Test ALL form validations
- Test ALL user interactions (button taps, text input)
- Test ALL navigation flows
- Test ALL error displays

### Integration Tests
- Full authentication flow (login → dashboard)
- Appointment booking flow (select service → confirm → view queue)
- Queue management flow (admin marks next → customer notified)

### Current Coverage
- ✅ 15+ unit tests for entities, models, auth cubit
- ⏳ Repository tests (not yet implemented)
- ⏳ Widget tests (minimal coverage)

---

## Documentation References

**IMPORTANT**: Do NOT duplicate content from these docs. Reference them directly.

- **Constitution**: `.specify/memory/constitution.md` - Project governance and principles
- **Architecture**: `docs/ARCHITECTURE.md` - Comprehensive technical architecture
- **PRD**: `docs/PRD.md` - Product requirements and user flows
- **Entities**: `docs/ENTITIES.md` - Detailed domain model specifications
- **Feature Checklist**: `docs/FEATURE_CHECKLIST.md` - Implementation status
- **Timeline**: `docs/PROJECT_TIMELINE.md` - Gantt chart and schedule

---

## Common Pitfalls & Solutions

### ❌ DON'T: Use print() for logging
```dart
print('User logged in: $userId');  // WRONG
```

### ✅ DO: Use AppLogger
```dart
AppLogger.info('User logged in', data: {'userId': userId});
```

---

### ❌ DON'T: Handle errors with try-catch in Cubit
```dart
try {
  final user = await _repository.login(email, password);
  emit(Authenticated(user));
} catch (e) {
  emit(AuthError(e.toString()));  // WRONG
}
```

### ✅ DO: Use Result.guard()
```dart
final result = await Result.guard(() => _repository.login(email, password));
result.when(
  success: (user) => emit(Authenticated(user)),
  failure: (e) => emit(AuthError(e.message)),
);
```

---

### ❌ DON'T: Create new exception types without constitution update
```dart
class NetworkException extends AppException { ... }  // WRONG (violates sealed)
```

### ✅ DO: Follow constitution amendment process
1. Propose MINOR version bump (additive change)
2. Add new exception type to `lib/core/error/app_exception.dart`
3. Update constitution with new subtype
4. Document usage pattern in ARCHITECTURE.md

---

### ❌ DON'T: Embed business logic in UI widgets
```dart
if (appointment.scheduledTime.difference(now).inMinutes < service.timeMargin) {
  // Update appointment status to no-show
}  // WRONG (business logic in widget)
```

### ✅ DO: Centralize business logic in Cubit/Repository
```dart
// In AppointmentRepository or Cubit
Future<void> checkTimeMarginExpiry(Appointment appointment) async { ... }
```

---

## Constitution Compliance Checklist

Before implementing ANY new feature, verify:
- [ ] Feature aligns with MVP scope (§3.2)
- [ ] Error handling uses Result<T> pattern (§2.2)
- [ ] All async operations have proper exception mapping (§2.2)
- [ ] Unit tests written FIRST (TDD, §1.2)
- [ ] Code follows analysis_options.yaml rules (§2.1)
- [ ] No inline TODOs without tracking (§1.1)
- [ ] UI uses centralized theme (§4)
- [ ] Performance budgets met (<2s cold start, <100ms interactions, §6)
- [ ] Sensitive operations use AppLogger (§5.2)

---

**Maintained By**: Development Team (Auto-updated by .specify agents)  
**Last Updated**: February 25, 2026  
**Version**: 1.0.0  
**Related**: constitution.md (governance), docs/ARCHITECTURE.md (technical details)
