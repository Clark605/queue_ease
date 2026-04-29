# Tasks: Fix Demo UI

**Input**: Design documents from `specs/chore/spec7-prep-checkpoint/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create `lib/core/widgets/pulsing_dot.dart` - unified PulsingDot widget

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 Verify AppointmentEntity supports 'cancelled' status in `lib/features/shared_domain/entities/appointment_entity.dart`
- [ ] T003 Verify AppointmentModel round-trip handles 'cancelled' status in `lib/features/shared_domain/models/appointment_model.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Customer Booking Cancellation (Priority: P1) 🎯 MVP

**Goal**: Enable customers to cancel their bookings from the home page (only for 'inQueue' and 'waiting' statuses)

**Independent Validation**: Can be validated by adding a cancel action to the customer dashboard that sets status to a cancelled state

### Implementation for User Story 1

- [ ] T004 [P] [US1] Create `lib/features/customer/booking/domain/use_cases/cancel_appointment_use_case.dart`
- [ ] T005 [P] [US1] Add `cancelAppointment` method to `AppointmentRepository` interface in `lib/features/shared_domain/repositories/appointment_repository.dart`
- [ ] T006 [US1] Implement `cancelAppointment` in `AppointmentRepositoryImpl` at `lib/features/customer/booking/data/repositories/appointment_repository_impl.dart` - update Firestore document status to 'cancelled'
- [ ] T007 [US1] Add cancel button to customer appointment card in `lib/features/customer/entry/customer_home_page.dart` (or similar) - only show for 'inQueue'/'waiting' statuses
- [ ] T008 [US1] Add cancellation confirmation dialog in customer home page
- [ ] T009 [US1] Integrate cancelAppointment use case into customer home page logic - handle success/error states with snackbar messages
- [ ] T010 [US1] Show "This booking can no longer be cancelled" message for non-cancellable statuses

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Admin Date Navigation (Priority: P1) 🎯 MVP

**Goal**: Add date navigation to QueueManagementPage so admins can view historical or future queue data

**Independent Validation**: Can be validated by adding a date picker to the AppBar since watchQueue already accepts a date parameter

### Implementation for User Story 2

- [ ] T011 [P] [US2] Add `selectedDate` state field to `QueueManagementCubit` in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [ ] T012 [P] [US2] Add date picker trigger (icon button or tappable text) to QueueManagementPage AppBar in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`
- [ ] T013 [US2] Implement date picker dialog that calls `watchQueue(orgId, selectedDate)` with the chosen date
- [ ] T014 [US2] Pass `selectedDate` to `watchQueue` use call in cubit
- [ ] T015 [US2] Handle empty state when no queue data exists for selected date - show "No queue data for this date" message
- [ ] T016 [US2] Format selected date display in AppBar (e.g., "Apr 29, 2026")

**Checkpoint**: At this point, User Story 2 should be fully functional and testable independently

---

## Phase 5: User Story 3 - Fix "See All" Navigation (Priority: P1) 🎯 MVP

**Goal**: Change "See all" navigation from QR scanner to appointments list

**Independent Validation**: Can be validated by changing the navigation target to an appointments list route

### Implementation for User Story 3

- [ ] T017 [P] [US3] Identify correct appointments list route in `lib/core/router/app_router.dart` (look for existing customer appointments route)
- [ ] T018 [P] [US3] If route doesn't exist, create `CustomerAppointmentsPage` and add route definition in app_router.dart
- [ ] T019 [US3] Update "See all" button onPressed/onTap in customer home page (`lib/features/customer/entry/customer_home_page.dart` or similar) to navigate to appointments list route instead of `Routes.customerAccess`
- [ ] T020 [US3] Verify navigation works correctly - tapping "See all" shows list of appointments, not QR scanner

**Checkpoint**: At this point, User Story 3 should be fully functional and testable independently

---

## Phase 6: User Story 4 - Quick Open/Closed Toggle (Priority: P1) 🎯 MVP

**Goal**: Add quick toggle for organization open/closed status on admin dashboard

**Independent Validation**: Can be validated by adding a switch in the header area of the dashboard

### Implementation for User Story 4

- [ ] T021 [P] [US4] Add Switch widget to admin dashboard header area in `lib/features/admin/dashboard/presentation/pages/admin_dashboard_page.dart`
- [ ] T022 [P] [US4] Connect Switch to `OrganizationEntity.isOpen` stream from Firestore (watch organization in dashboard cubit)
- [ ] T023 [US4] Implement toggle action that calls `updateOrganization` use case with updated `isOpen` value
- [ ] T024 [US4] Handle optimistic UI - toggle switches immediately, reverts on failure
- [ ] T025 [US4] Show error snackbar "Failed to update status. Please try again." on network error
- [ ] T026 [US4] Ensure toggle is reachable in under 2 taps from dashboard

**Checkpoint**: At this point, User Story 4 should be fully functional and testable independently

---

## Phase 7: User Story 5 - Fix Architecture Issues (Priority: P2)

**Goal**: Fix transactionMarkNoShow validation and AdminWorkingHoursDatasource.saveAll batch.update issue

**Independent Validation**: Can be validated by fixing the validation logic and using batch.set with merge option

### Implementation for User Story 5

- [ ] T027 [P] [US5] Fix `transactionMarkNoShow` validation in `lib/features/admin/queue_management/data/datasources/queue_datasource.dart` (or similar) - handle status check gracefully with Result<T>
- [ ] T028 [P] [US5] Ensure `transactionMarkOverdueNoShow` properly handles failure cases from `transactionMarkNoShow`
- [ ] T029 [P] [US5] Fix `AdminWorkingHoursDatasource.saveAll` in `lib/features/admin/working_hours_management/data/datasources/working_hours_datasource.dart` - replace `batch.update(doc.ref, data)` with `batch.set(doc.ref, data, SetOptions(merge: true))`
- [ ] T030 [US5] Test with new organization (no existing working hours documents) - should create documents properly
- [ ] T031 [US5] Verify no-show marking handles various statuses without throwing errors

**Checkpoint**: At this point, User Story 5 should be fully functional and testable independently

---

## Phase 8: User Story 6 - Optimize Wait Timer Polling (Priority: P2)

**Goal**: Remove unnecessary Timer.periodic from WaitTimerCountdown, recalculate on stream emission

**Independent Validation**: Can be validated by reducing poll interval to 60 seconds or removing timer and recalculating on WatchCustomerQueueStatusUseCase emission

### Implementation for User Story 6

- [ ] T032 [P] [US6] Locate `WaitTimerCountdown` widget (likely in `lib/features/customer/` or `lib/core/widgets/`)
- [ ] T033 [P] [US6] Remove `Timer.periodic(Duration(seconds: 30), callback)` logic
- [ ] T034 [US6] Recalculate elapsed/wait time when `WatchCustomerQueueStatusUseCase` stream emits new state
- [ ] T035 [US6] Ensure any remaining timers are properly disposed in `dispose()` method
- [ ] T036 [US6] Verify timer updates appropriately without unnecessary polling

**Checkpoint**: At this point, User Story 6 should be fully functional and testable independently

---

## Phase 9: User Story 7 - Quick Wins (Priority: P2)

**Goal**: Implement various small improvements: consolidate PulsingDot, show orgName on confirmation, fix notification dot, mask Admin ID

**Independent Validation**: Can be validated by implementing each small fix individually

### Implementation for User Story 7

- [ ] T037 [P] [US7] Replace all PulsingDot usages with unified widget from `lib/core/widgets/pulsing_dot.dart` (search for all usages in queue list, date header, etc.)
- [ ] T037 [P] [US7] Delete old PulsingDot implementations after migration
- [ ] T038 [P] [US7] Pass `orgName` to confirmation page (likely in `lib/features/customer/booking/presentation/pages/`)
- [ ] T039 [US7] Display organization name on confirmation page UI
- [ ] T040 [P] [US7] Locate notification dot in customer home drawer (`lib/features/customer/entry/customer_home_page.dart` or similar)
- [ ] T041 [US7] Either remove notification dot entirely OR connect to real notification data source
- [ ] T042 [P] [US7] Locate Admin ID display in `lib/features/admin/app_section/presentation/pages/organization_profile_page.dart` (or similar)
- [ ] T043 [US7] Apply masking to Admin ID - show first 8 characters + "..." (e.g., "ABC12345...")
- [ ] T044 [US7] Optionally add long-press to show full ID for support scenarios

**Checkpoint**: At this point, User Story 7 should be fully functional and testable independently

---

## Phase 10: Dead UI Elements Cleanup (Cross-Cutting)

**Goal**: Remove or fix dead UI elements as specified in FR-001 and FR-002

### Implementation

- [ ] T045 [P] Fix Service list search button in `lib/features/admin/service_management/` - either implement client-side filtering OR hide the button
- [ ] T046 [P] Fix Queue management filter button in `lib/features/admin/queue_management/` - either implement status filter OR hide the button
- [ ] T047 [P] Fix NowServingCard (hardcoded) in admin dashboard - connect to real queue data OR remove if unused
- [ ] T048 [P] Fix _StatsStrip (hardcoded numbers) in admin dashboard - connect to real Firestore data OR remove
- [ ] T049 [P] Fix Daily Summary card snackbar in `lib/features/admin/daily_summary/` - navigate to daily summary page OR remove card
- [ ] T050 [P] Remove "Coming soon" items (5 items) from Settings page in `lib/features/admin/app_section/` - not in scope for new features

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T051 [P] Run `flutter analyze` to check for errors and warnings
- [ ] T052 [P] Run `flutter test` to ensure no regressions
- [ ] T053 [P] Verify Clean Architecture compliance - no Flutter/Firebase imports in domain layer
- [ ] T054 [P] Verify Result<T> pattern used consistently for async operations
- [ ] T055 [P] Test all 7 user stories manually end-to-end
- [ ] T056 [P] Verify performance: 60fps UI, <1s data refresh on date navigation
- [ ] T057 [P] Update documentation if needed
- [ ] T058 [P] Code cleanup and refactoring

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-9)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2)
- **Dead UI Cleanup (Phase 10)**: Depends on Foundational - can run in parallel with user stories
- **Polish (Phase 11)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 4 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 5 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 6 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 7 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories

### Within Each User Story

- Models before services
- Services before endpoints/UI
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tasks within a user story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members
- Dead UI Cleanup (Phase 10) can run in parallel with user stories

### Suggested Execution Order (Sequential)

1. Complete Phase 1-2 (Foundation)
2. Implement P1 stories (Phases 3-6) - highest priority
3. Implement P2 stories (Phases 7-9) - after P1 complete
4. Complete Phase 10 (Dead UI Cleanup) - can run in parallel with P1/P2
5. Complete Phase 11 (Polish) - after all stories done

### Suggested Execution Order (Parallel - 4 Developers)

- **Dev 1**: User Story 1 (Customer Cancellation) - Phase 3
- **Dev 2**: User Story 2 (Date Navigation) - Phase 4
- **Dev 3**: User Story 3 (See All Fix) + User Story 4 (Toggle) - Phases 5-6
- **Dev 4**: User Story 5-7 (Architecture, Timer, Quick Wins) + Dead UI Cleanup - Phases 7-10
- **All**: Phase 11 (Polish) together

---