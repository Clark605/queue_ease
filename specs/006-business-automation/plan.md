# Implementation Plan: Business Logic & Automation

**Branch**: `006-business-automation` | **Date**: 2026-03-15 | **Spec**: `/specs/006-business-automation/spec.md`
**Input**: Feature specification from `/specs/006-business-automation/spec.md`

**Note**: This plan is generated from the clarified Sprint 6 business-automation spec and grounded in the existing Flutter + Firebase queue-management implementation.

## Summary

Implement booking-time-based queue automation for admin and customer flows by replacing the current implicit-serving queue behavior with derived front-of-queue automation state, pre-booking action locks, a 2-minute fallback time margin, explicit attendance handling, Firestore-validated transaction rules, and no-show-aware customer status messaging. The work spans shared appointment/service projections, admin queue repository/datasource logic, admin Cubit/UI timer behavior, Firestore rules, and targeted domain/data/presentation tests.

## Technical Context

**Language/Version**: Dart `^3.9.0`, Flutter stable `3.9.x`  
**Primary Dependencies**: `flutter_bloc`, `equatable`, `go_router`, `cloud_firestore`, `firebase_core`, `firebase_crashlytics`, `get_it`, `injectable`, `intl`, `talker`  
**Storage**: Firebase Firestore for appointments/queues/services, SharedPreferences for existing local flags, no new storage layer planned  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`, Firebase mocks in `test/firebase_mocks.dart`, Firestore rules tests under `test/firestore_rules/`  
**Target Platform**: Flutter mobile app for Android and iOS (web remains out of scope for this sprint)  
**Project Type**: Mobile app  
**Performance Goals**: Queue UI remains 60 fps, countdown updates every second without jank, auto no-show plus queue advancement completes within 3 seconds, real-time updates continue propagating within the existing sub-second Firestore listener budget  
**Constraints**: Strict Clean Architecture, no Cloud Functions in Sprint 6, no new external packages unless justified, business rules live outside widgets, pre-booking queue actions must be locked, service margin fallback is fixed at 2 minutes, Firestore transaction and rule consistency required  
**Scale/Scope**: One admin feature slice plus shared-domain and customer queue-status adjustments; expected changes in `queue_management`, `shared_domain`, `firestore.rules`, DI-generated code, and mirrored tests under `test/admin`, `test/shared`, `test/customer`, and `test/firestore_rules`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Phase 0 Gate

- PASS: Architecture remains compliant by keeping automation evaluation in repository/use-case/Cubit layers, not in widgets.
- PASS: Existing Flutter + Firebase stack is sufficient; no new package or backend service is required.
- PASS: Testing obligations are identified across domain, data, presentation, and Firestore rules.
- PASS: UX consistency is preserved through explicit queue-entry states and actionable feedback, not hidden behavior.
- PASS: Performance remains within existing budgets because countdowns are local and writes stay transactional.

### Post-Phase 1 Re-Check

- PASS: Design keeps shared business rules in derived queue projections and transaction guards.
- PASS: Planned source changes remain feature-contained with limited shared-domain and rules updates.
- PASS: No constitution violations or unjustified complexity are introduced.

## Project Structure

### Documentation (this feature)

```text
specs/006-business-automation/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── admin_queue_automation_contract.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── di/
│   │   ├── injection.dart
│   │   └── injection.config.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── app_logger.dart
│       └── app_snack_bar.dart
├── features/
│   ├── shared_domain/
│   │   ├── entities/
│   │   │   ├── appointment_entity.dart
│   │   │   ├── appointment_status.dart
│   │   │   ├── queue_entity.dart
│   │   │   └── service_entity.dart
│   │   └── models/
│   │       ├── appointment_model.dart
│   │       └── service_model.dart
│   ├── admin/
│   │   └── queue_management/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   └── admin_queue_datasource.dart
│   │       │   └── repositories/
│   │       │       └── admin_queue_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── repositories/
│   │       │   │   └── admin_appointment_repository.dart
│   │       │   └── use_cases/
│   │       │       ├── advance_queue_use_case.dart
│   │       │       ├── generate_daily_queue_use_case.dart
│   │       │       ├── mark_no_show_use_case.dart
│   │       │       ├── rejoin_skipped_use_case.dart
│   │       │       ├── skip_queue_entry_use_case.dart
│   │       │       └── watch_daily_queue_use_case.dart
│   │       └── presentation/
│   │           ├── cubit/
│   │           │   ├── queue_management_cubit.dart
│   │           │   └── queue_management_state.dart
│   │           ├── pages/
│   │           │   └── queue_management_page.dart
│   │           └── widgets/
│   │               ├── current_queue_card.dart
│   │               ├── current_entry_header.dart
│   │               ├── queue_action_bar.dart
│   │               └── queue_content.dart
│   └── customer/
│       └── entry/
│           └── presentation/
│               └── ... existing queue-status widgets/pages
├── main_dev.dart
└── main_prod.dart

firestore.rules

test/
├── admin/
│   └── queue_management/
├── customer/
├── firestore_rules/
└── shared/
    └── booking/
        ├── data/models/appointment_model_test.dart
        └── domain/entities/appointment_entity_test.dart
```

**Structure Decision**: Use the existing feature-first Flutter mobile app structure. Keep business-automation logic inside `admin/queue_management` and shared appointment/service definitions, mirror new tests under `test/`, and treat `firestore.rules` as a first-class implementation touchpoint for transaction safety.

## Phase 0: Research Output

- Completed in `/specs/006-business-automation/research.md`
- Key resolved topics:
  - reuse existing Flutter/Firebase stack
  - fix implicit-serving root cause in queue flow
  - derive automation state instead of storing new documents
  - use Firestore-backed inputs with local countdown rendering
  - formalize admin/customer UI behavior via a contract

## Phase 1: Design Output

- Data model: `/specs/006-business-automation/data-model.md`
- UI contract: `/specs/006-business-automation/contracts/admin_queue_automation_contract.md`
- Validation guide: `/specs/006-business-automation/quickstart.md`

## Implementation Outline

### 1. Shared domain and projections

- Extend `QueueEntryView` and `AdminQueueSnapshot` to carry booking-time automation fields.
- Add a domain-safe automation evaluation model or helper that derives `not_due_yet`, countdown, overdue, and serving states.
- Keep `AppointmentEntity` and `ServiceEntity` stable where possible; prefer derived values over new persisted fields.

### 2. Data and repository layer

- Update `AdminQueueDatasource.generateDailyQueue` so queue generation no longer puts customers into an invalid early `serving` state.
- Add transaction support for the clarified flow:
  - explicit start-serving transition
  - no-show before serving when overdue
  - skip/reorder behavior for the current due entry
  - guard rails that reject pre-booking actions
- Update `AdminQueueRepositoryImpl.watchDailyQueue` to join `scheduledAt`, effective margin, and derived action availability into the admin snapshot.
- Add fallback handling for invalid or missing service margins.

### 3. Firestore rules

- Update `isValidStatusTransition` and appointment update constraints to support the new clarified flow without allowing premature or unsafe writes.
- Ensure pre-booking updates to skip/served/no-show are rejected by rules as well as UI.
- Preserve idempotent rejoin and queue pointer updates.

### 4. Presentation layer

- Refactor `QueueManagementCubit` to own countdown ticking and automatic overdue evaluation without duplicating business rules in widgets.
- Update `CurrentQueueCard` and related widgets to render:
  - `Not due yet`
  - active countdown
  - overdue state
  - serving state
- Add the explicit attendance/start-serving flow required by the clarified spec.
- Update customer queue-status UI to show a clear no-show state and guidance.

### 5. Testing

- Unit tests:
  - automation evaluation logic
  - effective margin fallback
  - appointment/model mapping changes
- Cubit tests:
  - pre-booking lock behavior
  - countdown state transitions
  - auto no-show trigger and duplicate-trigger protection
- Firestore rules tests:
  - pre-booking action rejection
  - allowed transitions for start serving / no-show / rejoin
- Widget tests:
  - `CurrentQueueCard` state rendering and action availability
  - customer no-show status presentation

## Complexity Tracking

No constitution violations identified. No complexity exemptions are required.
