# Tasks: Business Logic & Automation

**Input**: Design documents from `/specs/006-business-automation/`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the codebase for Sprint 6 automation work.

- [x] T001 Update sprint references and branch naming consistency in specs docs at specs/006-business-automation/spec.md and specs/006-business-automation/plan.md
- [x] T002 Run code generation prerequisites by validating Injectable annotations in lib/core/di/injection.dart
- [x] T003 [P] Create admin queue-management test file structure in test/admin/queue_management/ and customer queue-status test structure in test/customer/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core queue automation building blocks required before user-story implementation.

**⚠️ CRITICAL**: No user story work starts until this phase is complete.

- [x] T004 Create queue automation state value objects in lib/features/admin/queue_management/domain/models/queue_automation_state.dart
- [x] T005 Extend queue projection contract with automation fields in lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart
- [x] T006 Implement effective time-margin resolver with 2-minute fallback in lib/features/admin/queue_management/domain/services/effective_time_margin_resolver.dart
- [x] T007 Implement booking-time deadline evaluator in lib/features/admin/queue_management/domain/services/queue_deadline_evaluator.dart
- [ ] T008 [P] Add domain unit tests for margin fallback and deadline calculations in test/admin/queue_management/domain/services/effective_time_margin_resolver_test.dart
- [ ] T009 [P] Add domain unit tests for automation state derivation in test/admin/queue_management/domain/services/queue_deadline_evaluator_test.dart
- [x] T010 Align Firestore status-transition guard helpers with planned flow in firestore.rules
- [ ] T011 Add Firestore rules tests for pre-booking action rejection baseline in test/firestore_rules/queue_prebooking_action_rules_test.dart

> Note: T008, T009, and T011 were intentionally skipped per user request.

**Checkpoint**: Foundation ready — user stories can now be implemented.

---

## Phase 3: User Story 1 - Admin sees booking-time countdown and pre-booking lock (Priority: P1) 🎯 MVP

**Goal**: Admin sees `Not due yet` before booking time, then countdown from booking-time margin, with pre-booking action lock.

**Independent Test**: Open queue with front customer scheduled in future and verify `Not due yet` + disabled skip/served/no-show; once scheduled time is reached verify live countdown and valid action availability.

### Tests for User Story 1

- [ ] T012 [P] [US1] Add Cubit state-transition tests for `not_due_yet` to countdown behavior in test/admin/queue_management/presentation/cubit/queue_management_cubit_test.dart
- [ ] T013 [P] [US1] Add widget tests for current card rendering (`Not due yet`, countdown, action disabled states) in test/admin/queue_management/presentation/widgets/current_queue_card_test.dart
- [ ] T014 [P] [US1] Add repository projection tests for automation fields in queue entries in test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart

> Note: T012, T013, and T014 were intentionally skipped per user request.

### Implementation for User Story 1

- [x] T015 [US1] Add automation fields to queue entry view model in lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart
- [x] T016 [US1] Build automation state derivation and fallback margin mapping in lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart
- [x] T017 [US1] Add countdown tick orchestration and derived-state emission in lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart
- [x] T018 [US1] Update current queue card to show `Not due yet` and booking-time countdown in lib/features/admin/queue_management/presentation/widgets/current_queue_card.dart
- [x] T019 [US1] Update queue content action wiring to respect `allowedActions` in lib/features/admin/queue_management/presentation/widgets/queue_content.dart
- [x] T020 [US1] Update current entry header to display scheduled time and deadline context in lib/features/admin/queue_management/presentation/widgets/current_entry_header.dart
- [x] T021 [US1] Add/adjust queue state fields for automation display and action gating in lib/features/admin/queue_management/presentation/cubit/queue_management_state.dart

**Checkpoint**: US1 is independently functional and testable (MVP slice).

---

## Phase 4: User Story 2 - Auto no-show detection and queue advancement from booking time (Priority: P2)

**Goal**: System auto-marks overdue front entries as no-show on mount/countdown expiry and advances queue safely.

**Independent Test**: With overdue front entries, opening queue auto-processes no-show in order until a valid due/non-overdue entry or empty queue is reached.

### Tests for User Story 2

- [ ] T022 [P] [US2] Add datasource transaction tests for auto no-show eligibility and pointer advancement in test/admin/queue_management/data/datasources/admin_queue_datasource_test.dart
- [ ] T023 [P] [US2] Add Cubit tests for one-by-one overdue processing and duplicate-trigger protection in test/admin/queue_management/presentation/cubit/queue_management_cubit_test.dart
- [ ] T024 [P] [US2] Add Firestore rules tests for allowed/blocked transitions in test/firestore_rules/appointment_status_transition_rules_test.dart

> Note: T022, T023, and T024 were intentionally skipped per user request.

### Implementation for User Story 2

- [x] T025 [US2] Refactor daily queue generation to remove implicit first-entry auto-serving in lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart
- [x] T026 [US2] Implement explicit start-serving transaction method in lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart
- [x] T027 [US2] Implement overdue no-show transaction path for non-serving front entries in lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart
- [x] T028 [US2] Wire new transaction methods into repository operations in lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart
- [x] T029 [US2] Add start-serving use case in lib/features/admin/queue_management/domain/use_cases/start_serving_use_case.dart
- [x] T030 [US2] Integrate auto no-show loop and start-serving action into Cubit in lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart
- [x] T031 [US2] Update Firestore transition policy and validation guards for the clarified lifecycle in firestore.rules

**Checkpoint**: US2 is independently functional and testable.

---

## Phase 5: User Story 3 - Rejoin remains reversible after automation (Priority: P3)

**Goal**: Auto no-show outcomes remain fully reversible with rejoin behavior and fresh eligibility window.

**Independent Test**: Auto no-show an entry, rejoin it, and verify it returns to waiting end with recalculated booking-time eligibility when front again.

### Tests for User Story 3

- [ ] T032 [P] [US3] Add rejoin-after-auto-no-show repository tests in test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart
- [ ] T033 [P] [US3] Add Cubit tests for rejoin state recovery and re-evaluation in test/admin/queue_management/presentation/cubit/queue_management_cubit_test.dart

> Note: T032 and T033 were intentionally skipped per user request.

### Implementation for User Story 3

- [x] T034 [US3] Ensure rejoin transaction preserves ordering and eligibility recomputation in lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart
- [x] T035 [US3] Update rejoin domain flow to refresh derived automation fields in lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart
- [x] T036 [US3] Update waiting-entry action UI for post-automation rejoin states in lib/features/admin/queue_management/presentation/widgets/waiting_entry_actions.dart
- [x] T037 [US3] Surface consistent admin feedback messages for automated and manual recovery actions in lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart

**Checkpoint**: US3 is independently functional and testable.

---

## Phase 6: User Story 4 - Customer sees no-show status messaging in real time (Priority: P4)

**Goal**: Customer queue-status UI clearly shows no-show state and guidance when appointment transitions to `noShow`.

**Independent Test**: While customer status screen is open, status transition to `noShow` updates UI in real time with explicit guidance.

### Tests for User Story 4

- [ ] T038 [P] [US4] Add customer queue-status widget tests for no-show messaging in test/customer/queue_status_no_show_test.dart
- [ ] T039 [P] [US4] Add customer stream-state tests for real-time no-show transition in test/customer/queue_status_stream_test.dart

> Note: T038 and T039 were intentionally skipped per user request.

### Implementation for User Story 4

- [x] T040 [US4] Update customer queue-status presentation for explicit no-show state in lib/features/customer/entry/presentation/pages/customer_queue_status_page.dart
- [x] T041 [US4] Ensure customer status mapping treats `noShow` as terminal guidance state in lib/features/customer/entry/presentation/cubit/customer_queue_status_cubit.dart
- [x] T042 [US4] Align customer-facing text and guidance copy with spec acceptance criteria in lib/features/customer/entry/presentation/widgets/no_show_queue_card.dart

**Checkpoint**: US4 is independently functional and testable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening and cross-story validation.

- [x] T043 [P] Regenerate dependency-injection output after annotation changes using lib/core/di/injection.config.dart
- [x] T044 [P] Run and fix lint/format issues for touched Dart files across lib/features/admin/queue_management/ and lib/features/customer/entry/
- [x] T045 Execute quickstart validation scenarios and document outcomes in specs/006-business-automation/quickstart.md
- [x] T046 [P] Add/update sprint documentation references in docs/FEATURE_CHECKLIST.md and docs/PROJECT_TIMELINE.md (if in scope for this feature branch)
- [x] T047 Run targeted regression tests for queue actions and booking-model serialization in test/admin/queue_management/ and test/shared/booking/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: starts immediately.
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all user stories.
- **Phase 3 (US1)**: depends on Phase 2; delivers MVP.
- **Phase 4 (US2)**: depends on Phase 2 and builds on US1 queue-state projection.
- **Phase 5 (US3)**: depends on US2 no-show transaction behavior.
- **Phase 6 (US4)**: depends on US2 status transition outputs but is customer-UI isolated.
- **Phase 7 (Polish)**: depends on completed targeted user stories.

### User Story Dependencies

- **US1 (P1)**: independent after foundational phase.
- **US2 (P2)**: depends on foundational and US1 projection/state wiring.
- **US3 (P3)**: depends on US2 automation and no-show transitions.
- **US4 (P4)**: depends on availability of `noShow` real-time transitions; implementation can proceed in parallel with late US2 work once contracts are stable.

### Within Each User Story

- Tests are created first for the changed behavior, then implementation follows.
- Domain/repository changes precede Cubit/UI updates.
- Transaction/rules changes precede dependent UI action enablement.

---

## Parallel Opportunities

- Setup: `T003` can run while `T001-T002` are in progress.
- Foundational: `T008`, `T009`, and `T011` can run in parallel after scaffolding (`T004-T007`, `T010`) is drafted.
- US1: `T012-T014` parallel; `T018-T020` parallel after `T015-T017`.
- US2: `T022-T024` parallel; `T026`, `T027`, `T029`, and `T031` mostly parallel once `T025` establishes base flow.
- US3: `T032-T033` parallel and can begin once US2 contract stabilizes.
- US4: `T038-T039` parallel with `T040-T042` implementation in separate customer files.
- Polish: `T043`, `T044`, and `T046` parallel.

---

## Parallel Example: User Story 1

```bash
# Parallel test tasks
T012 + T013 + T014

# Parallel UI tasks after projection and cubit updates
T018 + T019 + T020
```

## Parallel Example: User Story 2

```bash
# Parallel safety net tasks
T022 + T023 + T024

# Parallel implementation slices after queue generation refactor
T026 + T027 + T029 + T031
```

## Parallel Example: User Story 4

```bash
# Customer-side parallel tasks
T038 + T039
```

---

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 and Phase 2.
2. Deliver Phase 3 (US1) end-to-end.
3. Validate `Not due yet`, pre-booking action lock, and countdown start-at-booking behavior.

### Incremental Delivery

1. Add US2 automation and queue advancement safety.
2. Add US3 rejoin robustness.
3. Add US4 customer-facing no-show clarity.
4. Finish with Phase 7 hardening and regression checks.

### Team Parallel Strategy

1. Engineer A: datasource/repository/rules tracks (`T025-T031`).
2. Engineer B: Cubit/UI admin tracks (`T017-T021`, `T030`, `T036-T037`).
3. Engineer C: customer no-show UI track (`T038-T042`).
4. Shared review for rules/tests and final polish.

---

## Notes

- All tasks follow the required checklist format: `- [ ] T### [P] [US#] Description with file path`.
- `[P]` tasks target distinct files or isolated concerns.
- User-story labels appear only in story phases.
- Each story includes an independent test checkpoint.
