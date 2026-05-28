# Tasks: Resolve GitHub Issues

**Input**: Design documents from `/specs/009-resolve-github-issues/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/
**Tests**: Required by the feature spec. Include regression coverage for every fix, plus Firestore rules validation where rules change.
**Organization**: Tasks are grouped by user story so each priority bucket can be implemented and verified independently.

**Total Tasks**: 44

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Shared fixtures and test scaffolding that make the issue fixes easier to implement and validate.

- [X] T001 [P] Add shared regression fixtures for appointments, services, and working-hours data in `test/shared/issue_resolution_fixtures.dart` and wire them through `test/firebase_mocks.dart`
- [X] T002 [P] Add reusable Firestore rules helpers for appointment-status and booking-window cases in `test/firestore_rules/issue_resolution_rules.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Baseline coverage and helpers that multiple issue fixes depend on.

**⚠️ CRITICAL**: These tasks establish shared regression coverage for the status, duration, and time assumptions used by later stories.

- [X] T003 [P] Add baseline appointment-status coverage for `cancelled` and `inQueue` cases in `test/shared/booking/domain/entities/appointment_entity_test.dart`
- [X] T004 [P] Add baseline service-duration coverage for zero and positive defaults in `test/shared/organization/domain/entities/service_entity_test.dart`
- [X] T005 [P] Add baseline server-time coverage in `test/core/utils/time_utils_test.dart` for the date/time assumptions used by issues #22 and #28

**Checkpoint**: Shared fixtures and baseline regressions are ready, so issue-specific work can begin.

---

## Phase 3: User Story 1 - Fix critical and blocking issues (Priority: P1) 🎯 MVP

**Goal**: Resolve the three critical blockers so queue loading, slot rebooking, and QR access work reliably.

**Independent Validation**: The targeted regression tests for issues #17-#19 pass and each fix is isolated to its own code path.

### Validation for User Story 1

- [X] T006 [P] [US1] Add regression coverage for Firestore `whereIn` chunking in `test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart` for issue #17
- [X] T008 [P] [US1] Add regression coverage for cancelled slots being released in `test/customer/booking/domain/use_cases/calculate_available_slots_use_case_test.dart` for issue #18
- [X] T010 [P] [US1] Add regression coverage for mixed-case booking slugs in `test/customer/access_portal/domain/use_cases/parse_access_url_use_case_test.dart` for issue #19

### Implementation for User Story 1

- [X] T007 [US1] Implement chunked `whereIn` loading and result merging in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart` for issue #17
- [X] T009 [US1] Update `lib/features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart` to exclude `cancelled` appointments from taken slots for issue #18
- [X] T011 [US1] Lowercase the extracted slug before lookup in `lib/features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart` for issue #19
- [ ] T012 [US1] Run the targeted unit tests for issues #17-#19 and record the results in `specs/009-resolve-github-issues/quickstart.md`

**Checkpoint**: The P1 blockers are fixed, tested, and ready for an isolated PR per issue.

---

## Phase 4: User Story 2 - Fix high-priority bugs and add tests (Priority: P2)

**Goal**: Fix the high-impact flow regressions so live updates, countdowns, cancellation, and rules enforcement stay consistent.

**Independent Validation**: The targeted tests for issues #20, #21, #22, #30, #31, and #32 pass, and the Firestore rules suite remains green.

### Validation for User Story 2

- [ ] T013 [P] [US2] Add regression coverage for live working-hours refresh in `test/customer/booking/presentation/cubit/slot_picker_cubit_test.dart` for issue #20
- [ ] T015 [P] [US2] Add regression coverage for advancing past completed and no-show entries in `test/admin/queue_management/data/datasources/admin_queue_datasource_test.dart` for issue #21
- [ ] T017 [P] [US2] Add regression coverage for server-time-based open/closed state in `test/customer/booking/presentation/cubit/organization_landing_cubit_test.dart` for issue #22
- [ ] T019 [P] [US2] Add widget coverage for timer-driven countdown updates in `test/customer/entry/presentation/widgets/wait_timer_countdown_test.dart` for issue #30
- [ ] T021 [P] [US2] Extend cancellation regression coverage in `test/customer/booking/domain/use_cases/cancel_appointment_use_case_test.dart` and `test/customer/entry/presentation/pages/customer_home_page_test.dart` for issue #31
- [ ] T023 [P] [US2] Add Firestore rules regression coverage for cancelled appointment updates in `test/firestore_rules/appointment_rules_test.dart` for issue #32

### Implementation for User Story 2

- [ ] T014 [US2] Update `lib/features/customer/booking/presentation/cubit/slot_picker_cubit.dart` to refresh slots when working-hours streams emit for issue #20
- [ ] T016 [US2] Update `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart` to scan forward to the next `inQueue` appointment for issue #21
- [ ] T018 [US2] Replace device-clock checks in `lib/features/customer/booking/presentation/cubit/organization_landing_cubit.dart` with shared server-time logic for issue #22
- [ ] T020 [US2] Restore periodic rebuilds in `lib/features/customer/entry/presentation/widgets/wait_timer_countdown.dart` for issue #30
- [ ] T022 [US2] Allow `booked` and `inQueue` cancellations in `lib/features/customer/booking/domain/use_cases/cancel_appointment_use_case.dart` and surface the cancel action from `lib/features/customer/entry/presentation/pages/customer_home_page.dart` and `lib/features/customer/entry/presentation/widgets/active_queue_status_card.dart` for issue #31
- [ ] T024 [US2] Update `firestore.rules` to whitelist `cancelled` appointment status transitions and safe no-op admin updates for issue #32
- [ ] T025 [US2] Run the targeted regression suites for issues #20-#22 and #30-#32, including the Firestore rules tests, and record the results in `specs/009-resolve-github-issues/quickstart.md`

**Checkpoint**: The high-priority regressions are fixed and validated without depending on the low-priority backlog.

---

## Phase 5: User Story 3 - Triage and close low-priority issues (Priority: P3)

**Goal**: Close the remaining lower-priority guardrails and cleanup items without regressing the higher-priority fixes.

**Independent Validation**: The targeted tests for issues #23-#29 pass and the previously fixed P1/P2 flows remain green.

### Validation for User Story 3

- [ ] T026 [P] [US3] Add regression coverage for stale booking retries in `test/customer/booking/presentation/cubit/booking_form_cubit_test.dart` and `test/customer/booking/presentation/pages/booking_form_page_test.dart` for issue #23
- [ ] T028 [P] [US3] Add regression coverage for multiple active dashboard appointments in `test/customer/entry/domain/use_cases/watch_customer_dashboard_use_case_test.dart` for issue #24
- [ ] T030 [P] [US3] Add regression coverage for zero-duration service defaults in `test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart` for issue #25
- [ ] T032 [P] [US3] Add regression coverage for orphaned inQueue appointments in `test/customer/booking/data/repositories/customer_appointment_repository_impl_test.dart` for issue #26
- [ ] T034 [P] [US3] Add widget coverage for inline break-time validation in `test/admin/working_hours_management/presentation/widgets/break_time_section_test.dart` for issue #27
- [ ] T036 [P] [US3] Add regression coverage for booking-horizon validation in `test/customer/booking/domain/use_cases/create_booking_use_case_test.dart` for issue #28
- [ ] T038 [P] [US3] Add regression coverage for appointment-scoped auto no-show backoff in `test/admin/queue_management/presentation/cubit/queue_management_cubit_test.dart` for issue #29

### Implementation for User Story 3

- [ ] T027 [US3] Separate retryable booking errors from slot conflicts in `lib/features/customer/booking/presentation/cubit/booking_form_cubit.dart` and `lib/features/customer/booking/presentation/pages/booking_form_page.dart` for issue #23
- [ ] T029 [US3] Update `lib/features/customer/entry/domain/use_cases/watch_customer_dashboard_use_case.dart` to surface or log multiple active appointments instead of dropping them silently for issue #24
- [ ] T031 [US3] Enforce a positive fallback duration in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart` and mirror the constraint in `firestore.rules` for issue #25
- [ ] T033 [US3] Merge the secondary active-appointment query in `lib/features/customer/booking/data/datasources/customer_appointment_datasource.dart` for issue #26
- [ ] T035 [US3] Show the break-end validation error immediately in `lib/features/admin/working_hours_management/presentation/widgets/break_time_section.dart` for issue #27
- [ ] T037 [US3] Reject bookings beyond the configured horizon in `lib/features/customer/booking/domain/use_cases/create_booking_use_case.dart` and `firestore.rules` for issue #28
- [ ] T039 [US3] Key the auto no-show backoff state by appointment ID in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart` for issue #29
- [ ] T040 [US3] Run the targeted regression suites for issues #23-#29 and record the results in `specs/009-resolve-github-issues/quickstart.md`

**Checkpoint**: The low-priority guardrails are fixed, validated, and ready for the final cleanup pass.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, documentation updates, and GitHub issue closure work that spans multiple stories.

- [ ] T041 [P] Update `specs/009-resolve-github-issues/research.md` with the final issue-to-PR matrix and any deferred items
- [ ] T042 [P] Run `flutter analyze`, the full `flutter test` suite, and the Firestore rules suite for the touched files, then capture the command list in `specs/009-resolve-github-issues/quickstart.md`
- [ ] T043 Publish the PRs for the P1 fixes and grouped P2/P3 batches, linking each issue number in the PR body and recording the PR URLs in `specs/009-resolve-github-issues/research.md`
- [ ] T044 Close the GitHub issues that were resolved in this cycle and annotate the outcome in `specs/009-resolve-github-issues/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies; can start immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks the story phases until the shared fixtures and baseline regressions are in place.
- **User Story 1 (P1)**: Can start after Phase 2 and should be the first code-delivery increment.
- **User Story 2 (P2)**: Can start after Phase 2, but should stay behind the P1 work on shared files such as `firestore.rules` and the queue-management repository.
- **User Story 3 (P3)**: Can start after Phase 2, but should be sequenced after any earlier story that touches the same file.
- **Polish**: Depends on the story phases that are being delivered in this cycle.

### User Story Dependencies

- **User Story 1 (P1)**: Independent of the lower-priority work; the three issue fixes can be merged separately.
- **User Story 2 (P2)**: Independent as a story, but some tasks share files with User Story 1 and must be sequenced carefully.
- **User Story 3 (P3)**: Independent as a story, but the queue repository and Firestore rules tasks should follow the earlier priority work in those files.

### Within Each User Story

- Add or update the regression test first, then implement the corresponding fix, then run the targeted validation.
- Keep fixes for unrelated files separate even when they belong to the same priority bucket.
- When a story touches `firestore.rules`, validate the rules before moving on to the next story.

### Parallel Opportunities

- The Setup tasks can run in parallel because they touch different helper files.
- The Foundational tasks can run in parallel because they cover different shared regression surfaces.
- In User Story 1, the three test tasks can run in parallel, and each implementation task can then be done independently.
- In User Story 2, the issue-specific test tasks can run in parallel, but the `firestore.rules`, `customer_home_page.dart`, and queue repository tasks should be sequenced where they touch the same file.
- In User Story 3, the test tasks can run in parallel across different files, but the `admin_queue_repository_impl.dart` and `firestore.rules` edits should be ordered after the earlier priority work in those files.

---

## Parallel Example: User Story 1

```bash
# Launch the three P1 regression tests together:
Task: "Add regression coverage for Firestore whereIn chunking in test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart for issue #17"
Task: "Add regression coverage for cancelled slots being released in test/customer/booking/domain/use_cases/calculate_available_slots_use_case_test.dart for issue #18"
Task: "Add regression coverage for mixed-case booking slugs in test/customer/access_portal/domain/use_cases/parse_access_url_use_case_test.dart for issue #19"

# Then implement the three P1 fixes independently:
Task: "Implement chunked whereIn loading and result merging in lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart for issue #17"
Task: "Update lib/features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart to exclude cancelled appointments from taken slots for issue #18"
Task: "Lowercase the extracted slug before lookup in lib/features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart for issue #19"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 for issues #17-#19.
3. Stop and validate the P1 tests before moving on.
4. Publish the three separate P1 PRs if the fixes are ready.

### Incremental Delivery

1. Finish Setup + Foundational so shared fixtures are ready.
2. Deliver User Story 1 and validate it independently.
3. Deliver User Story 2 next, keeping the rules and cancellation changes isolated.
4. Deliver User Story 3 last, reusing the already-stabilized queue and rules surfaces.
5. Run the final polish tasks only after the story phases are complete.

### Parallel Team Strategy

With multiple developers:

1. One developer can handle the shared fixtures and baseline regressions.
2. Another developer can implement the P1 repository/domain fixes.
3. A second developer can begin the P2 widget and cubit fixes once the foundational tasks are done.
4. The P3 guardrails can be split across devs, but any file shared with P1/P2 should be sequenced carefully.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps task to a specific user story for traceability.
- Each user story should be independently completable and testable.
- The feature spec requires regression coverage for every fix, so tests are included throughout the task list.
- Commit after each logical group and stop at the validation checkpoints.
