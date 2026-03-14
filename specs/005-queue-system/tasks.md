# Tasks: Queue System (Sprint 5)

**Input**: Design documents from `/specs/005-queue-system/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare queue feature scaffolding and integration points used by all stories.

- [ ] T001 Create admin queue datasource scaffold in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [ ] T002 Create admin queue repository implementation scaffold in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [ ] T003 Create admin queue use case folder and skeleton files in `lib/features/admin/queue_management/domain/use_cases/`
- [ ] T004 Create admin queue cubit/state skeleton files in `lib/features/admin/queue_management/presentation/cubit/`
- [ ] T005 Create customer queue status cubit/page/widget skeleton files in `lib/features/customer/entry/presentation/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Complete core constraints and shared plumbing required before story implementation.

**⚠️ CRITICAL**: No user story work should be finalized before this phase is complete.

- [ ] T006 Update queue and appointment access rules in `firestore.rules`
- [ ] T007 Update queue-related indexes in `firestore.indexes.json`
- [ ] T008 Extend admin queue domain contract in `lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart`
- [ ] T009 [P] Extend customer appointment domain contract for queue status in `lib/features/customer/booking/domain/repositories/customer_appointment_repository.dart`
- [ ] T010 Register queue dependencies in `lib/core/di/injection.dart`
- [ ] T011 Regenerate dependency graph file in `lib/core/di/injection.config.dart`
- [ ] T012 [P] Add queue status navigation entry in `lib/core/router/app_router.dart`

**Checkpoint**: Foundation complete — user stories can now be implemented independently.

---

## Phase 3: User Story 1 - Admin manages daily queue progression (Priority: P1) 🎯 MVP

**Goal**: Admin can view current/waiting queue and execute next/skip/no-show/rejoin actions safely.

**Independent Test**: With pre-existing queue data, admin opens queue screen and runs actions; state changes are reflected correctly and idempotently.

- [ ] T013 [US1] Implement queue watch + action transactions in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [ ] T014 [US1] Implement repository action methods in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [ ] T015 [P] [US1] Implement action use cases (`advance`, `skip`, `mark_no_show`, `rejoin`) in `lib/features/admin/queue_management/domain/use_cases/`
- [ ] T016 [US1] Implement queue management cubit/state behavior in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [ ] T017 [P] [US1] Add current queue card widget in `lib/features/admin/queue_management/presentation/widgets/current_queue_card.dart`
- [ ] T018 [P] [US1] Add waiting queue list widget in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`
- [ ] T019 [P] [US1] Add queue action bar widget in `lib/features/admin/queue_management/presentation/widgets/queue_action_bar.dart`
- [ ] T020 [US1] Replace placeholder UI with live queue screen integration in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`

**Checkpoint**: User Story 1 is independently functional for admin queue progression.

---

## Phase 4: User Story 2 - Customer tracks live queue status (Priority: P2)

**Goal**: Customer sees own live queue position, turn indicator, and privacy-safe status updates.

**Independent Test**: Customer with active queue entry sees live updates after admin actions, with no other customer identity exposure.

- [ ] T021 [US2] Implement customer queue status watch queries in `lib/features/customer/booking/data/datasources/customer_appointment_datasource.dart`
- [ ] T022 [US2] Implement customer repository queue status stream in `lib/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart`
- [ ] T023 [US2] Implement customer queue status use case in `lib/features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart`
- [ ] T024 [US2] Implement customer queue status cubit/state in `lib/features/customer/entry/presentation/cubit/`
- [ ] T025 [P] [US2] Create queue position card widget in `lib/features/customer/entry/presentation/widgets/queue_position_card.dart`
- [ ] T026 [US2] Create customer queue status page in `lib/features/customer/entry/presentation/pages/customer_queue_status_page.dart`
- [ ] T027 [US2] Add queue status entry point from home in `lib/features/customer/entry/presentation/pages/customer_home_page.dart`
- [ ] T028 [US2] Wire customer queue status route in `lib/core/router/app_router.dart`

**Checkpoint**: User Story 2 is independently functional for privacy-safe customer queue tracking.

---

## Phase 5: User Story 3 - System generates queue from appointments (Priority: P3)

**Goal**: System generates daily queue from today's `booked` appointments in deterministic, duplicate-free order.

**Independent Test**: Re-running generation for same org/date keeps a stable, duplicate-free queue ordered by `scheduledAt`.

- [ ] T029 [US3] Implement generation candidate query (`booked` + today) in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [ ] T030 [US3] Implement idempotent generation logic in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [ ] T031 [US3] Implement generate daily queue use case in `lib/features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart`
- [ ] T032 [US3] Trigger queue generation from queue management flow in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [ ] T033 [US3] Surface generation action/status in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`

**Checkpoint**: User Story 3 is independently functional for repeatable queue generation.

---

## Phase 6: User Story 4 - Wait time estimate is understandable and stable (Priority: P4)

**Goal**: Wait estimate is computed from durations ahead and updates consistently as queue changes.

**Independent Test**: With mixed service durations, customer/admin estimates update correctly after each queue action.

- [ ] T034 [US4] Implement wait-time calculation use case in `lib/features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart`
- [ ] T035 [US4] Integrate wait-time computation into customer queue status use case in `lib/features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart`
- [ ] T036 [US4] Add wait-time chip widget in `lib/features/customer/entry/presentation/widgets/wait_time_chip.dart`
- [ ] T037 [US4] Render wait-time UI in customer queue status page in `lib/features/customer/entry/presentation/pages/customer_queue_status_page.dart`
- [ ] T038 [US4] Update admin waiting list display to show estimated wait metadata in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`

**Checkpoint**: User Story 4 is independently functional with deterministic wait-time updates.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening across all stories.

- [ ] T039 [P] Add structured queue logging and sanitize PII in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [ ] T040 [P] Add structured queue logging and sanitize PII in `lib/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart`
- [ ] T041 Align user-facing queue error messages across cubits in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [ ] T042 Align user-facing queue error messages across cubits in `lib/features/customer/entry/presentation/cubit/customer_queue_status_cubit.dart`
- [ ] T043 Run quickstart flow validation updates in `specs/005-queue-system/quickstart.md`
- [ ] T044 Run static analysis and resolve queue-scope issues in `lib/features/admin/queue_management/` and `lib/features/customer/entry/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Starts immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks story completion.
- **Phase 3–6 (User Stories)**: Depend on Phase 2 completion.
- **Phase 7 (Polish)**: Depends on all selected user stories being complete.

### User Story Dependencies

- **US1 (P1)**: Starts after foundational phase; does not require US2/US3/US4 for independent admin action testing with prepared queue data.
- **US2 (P2)**: Starts after foundational phase; can run independently with prepared queue data.
- **US3 (P3)**: Starts after foundational phase; improves automation of queue creation for US1/US2 flows.
- **US4 (P4)**: Depends on basic queue status plumbing from US2 and action transitions from US1.

### Within Each User Story

- Data source/repository updates before use cases.
- Use cases before cubits/pages.
- Widgets can be parallelized when files are independent.
- Integration task closes each story phase.

---

## Parallel Execution Examples

### User Story 1

- [ ] T017 [P] [US1] Add current queue card widget in `lib/features/admin/queue_management/presentation/widgets/current_queue_card.dart`
- [ ] T018 [P] [US1] Add waiting queue list widget in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`
- [ ] T019 [P] [US1] Add queue action bar widget in `lib/features/admin/queue_management/presentation/widgets/queue_action_bar.dart`

### User Story 2

- [ ] T025 [P] [US2] Create queue position card widget in `lib/features/customer/entry/presentation/widgets/queue_position_card.dart`
- [ ] T028 [US2] Wire customer queue status route in `lib/core/router/app_router.dart`

### User Story 3

- [ ] T031 [US3] Implement generate daily queue use case in `lib/features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart`
- [ ] T033 [US3] Surface generation action/status in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`

### User Story 4

- [ ] T036 [US4] Add wait-time chip widget in `lib/features/customer/entry/presentation/widgets/wait_time_chip.dart`
- [ ] T038 [US4] Update admin waiting list display to show estimated wait metadata in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`

---

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 + Phase 2.
2. Complete Phase 3 (US1).
3. Validate admin queue progression independently.
4. Demo/deploy MVP increment.

### Incremental Delivery

1. Add US2 for customer live visibility.
2. Add US3 for generation automation.
3. Add US4 for wait-time accuracy.
4. Apply Phase 7 polish and final validation.

### Team Parallelization

1. One developer handles admin data/domain (US1/US3).
2. One developer handles customer presentation flow (US2/US4).
3. Shared reviewer handles Firestore rules/indexes + DI/router integration.
