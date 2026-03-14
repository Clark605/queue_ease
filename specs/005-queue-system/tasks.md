# Tasks: Queue System (Sprint 5)

**Input**: Design documents from `/specs/005-queue-system/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare queue feature scaffolding and integration points used by all stories.

- [x] T001 Create admin queue datasource scaffold in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [x] T002 Create admin queue repository implementation scaffold in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [x] T003 Create admin queue use case folder and skeleton files in `lib/features/admin/queue_management/domain/use_cases/`
- [x] T004 Create admin queue cubit/state skeleton files in `lib/features/admin/queue_management/presentation/cubit/`
- [x] T005 Create customer queue status cubit/page/widget skeleton files in `lib/features/customer/entry/presentation/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Complete core constraints and shared plumbing required before story implementation.

**⚠️ CRITICAL**: No user story work should be finalized before this phase is complete.

- [x] T006 Update queue and appointment access rules in `firestore.rules`
- [x] T007 Update queue-related indexes in `firestore.indexes.json`
- [x] T008 Extend admin queue domain contract in `lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart`
- [x] T009 [P] Extend customer appointment domain contract for queue status in `lib/features/customer/booking/domain/repositories/customer_appointment_repository.dart`
- [x] T010 Register queue dependencies in `lib/core/di/injection.dart`
- [x] T011 Regenerate dependency graph file in `lib/core/di/injection.config.dart`
- [x] T012 [P] Add queue status navigation entry in `lib/core/router/app_router.dart`

**Checkpoint**: Foundation complete — user stories can now be implemented independently.

---

## Phase 3: User Story 1 - Admin manages daily queue progression (Priority: P1) 🎯 MVP

**Goal**: Admin can view current/waiting queue and execute next/skip/no-show/rejoin actions safely.

**Independent Test**: With pre-existing queue data, admin opens queue screen and runs actions; state changes are reflected correctly and idempotently.

- [x] T013 [US1] Implement queue watch + action transactions in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [x] T014 [US1] Implement repository action methods in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [x] T015 [P] [US1] Implement action use cases (`advance`, `skip`, `mark_no_show`, `rejoin`) in `lib/features/admin/queue_management/domain/use_cases/`
- [x] T016 [US1] Implement queue management cubit/state behavior in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [x] T017 [P] [US1] Add current queue card widget in `lib/features/admin/queue_management/presentation/widgets/current_queue_card.dart`
- [x] T018 [P] [US1] Add waiting queue list widget in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`
- [x] T019 [P] [US1] Add queue action bar widget in `lib/features/admin/queue_management/presentation/widgets/queue_action_bar.dart`
- [x] T020 [US1] Replace placeholder UI with live queue screen integration in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`

**Checkpoint**: User Story 1 is independently functional for admin queue progression.

---

## Phase 4: User Story 2 - Customer tracks live queue status (Priority: P2)

**Goal**: Customer sees own live queue position, turn indicator, and privacy-safe status updates.

**Independent Test**: Customer with active queue entry sees live updates after admin actions, with no other customer identity exposure.

- [x] T021 [US2] Implement customer queue status watch queries in `lib/features/customer/booking/data/datasources/customer_appointment_datasource.dart`
- [x] T022 [US2] Implement customer repository queue status stream in `lib/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart`
- [x] T023 [US2] Implement customer queue status use case in `lib/features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart`
- [x] T024 [US2] Implement customer queue status cubit/state in `lib/features/customer/entry/presentation/cubit/`
- [x] T025 [P] [US2] Create queue position card widget in `lib/features/customer/entry/presentation/widgets/queue_position_card.dart`
- [x] T026 [US2] Create customer queue status page in `lib/features/customer/entry/presentation/pages/customer_queue_status_page.dart`
- [x] T027 [US2] Add queue status entry point from home in `lib/features/customer/entry/presentation/pages/customer_home_page.dart`
- [x] T028 [US2] Wire customer queue status route in `lib/core/router/app_router.dart`

**Checkpoint**: User Story 2 is independently functional for privacy-safe customer queue tracking.

---

## Phase 5: User Story 3 - System generates queue from appointments (Priority: P3)

**Goal**: System generates daily queue from today's `booked` appointments in deterministic, duplicate-free order.

**Independent Test**: Re-running generation for same org/date keeps a stable, duplicate-free queue ordered by `scheduledAt`.

- [x] T029 [US3] Implement generation candidate query (`booked` + today) in `lib/features/admin/queue_management/data/datasources/admin_queue_datasource.dart`
- [x] T030 [US3] Implement idempotent generation logic in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [x] T031 [US3] Implement generate daily queue use case in `lib/features/admin/queue_management/domain/use_cases/generate_daily_queue_use_case.dart`
- [x] T032 [US3] Trigger queue generation from queue management flow in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [x] T033 [US3] Surface generation action/status in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`

**Checkpoint**: User Story 3 is independently functional for repeatable queue generation.

---

## Phase 6: User Story 4 - Wait time estimate is understandable and stable (Priority: P4)

**Goal**: Wait estimate is computed from durations ahead and updates consistently as queue changes.

**Independent Test**: With mixed service durations, customer/admin estimates update correctly after each queue action.

- [x] T034 [US4] Implement wait-time calculation use case in `lib/features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart`
- [x] T035 [US4] Integrate wait-time computation into customer queue status use case in `lib/features/customer/entry/domain/use_cases/watch_customer_queue_status_use_case.dart`
- [x] T036 [US4] Add wait-time chip widget in `lib/features/customer/entry/presentation/widgets/wait_time_chip.dart`
- [x] T037 [US4] Render wait-time UI in customer queue status page in `lib/features/customer/entry/presentation/pages/customer_queue_status_page.dart`
- [x] T038 [US4] Update admin waiting list display to show estimated wait metadata in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`

**Checkpoint**: User Story 4 is independently functional with deterministic wait-time updates.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening across all stories.

- [x] T039 [P] Add structured queue logging and sanitize PII in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [x] T040 [P] Add structured queue logging and sanitize PII in `lib/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart`
- [x] T041 Align user-facing queue error messages across cubits in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [x] T042 Align user-facing queue error messages across cubits in `lib/features/customer/entry/presentation/cubit/customer_queue_status_cubit.dart`
- [x] T043 Run quickstart flow validation updates in `specs/005-queue-system/quickstart.md`
- [x] T044 Run static analysis and resolve queue-scope issues in `lib/features/admin/queue_management/` and `lib/features/customer/entry/`

---

## Phase 8: User Story 5 — Customer Dashboard as Entry Page (Priority: P5)

**Goal**: Customer home page shows a proper dashboard with an active queue status card, an upcoming appointment card, and explicit empty states when neither exists.

**Independent Test**: A logged-in customer with no bookings sees the empty-state CTA; a customer in an active queue sees position and wait time; a customer with an upcoming appointment but no active queue sees the appointment card only.

- [x] T045 [US5] Extend customer appointment domain contract with `watchTodayActiveAppointments` stream in `lib/features/customer/booking/domain/repositories/customer_appointment_repository.dart`
- [x] T046 [US5] Implement `watchTodayActiveAppointments` Firestore query in `lib/features/customer/booking/data/datasources/customer_appointment_datasource.dart`
- [x] T047 [US5] Implement `watchTodayActiveAppointments` repository method in `lib/features/customer/booking/data/repositories/customer_appointment_repository_impl.dart`
- [x] T048 [US5] Implement `WatchCustomerDashboardUseCase` (combines active queue + today appointment streams) in `lib/features/customer/entry/domain/use_cases/watch_customer_dashboard_use_case.dart`
- [x] T049 [US5] Implement `CustomerDashboardCubit` + sealed states (`initial`, `loading`, `loaded`, `error`) in `lib/features/customer/entry/presentation/cubit/customer_dashboard_cubit.dart`
- [x] T050 [P] [US5] Create `ActiveQueueStatusCard` widget (position, wait time, org/service name) in `lib/features/customer/entry/presentation/widgets/active_queue_status_card.dart`
- [x] T051 [P] [US5] Create `UpcomingAppointmentCard` widget (service, provider, date/time, location) in `lib/features/customer/entry/presentation/widgets/upcoming_appointment_card.dart`
- [x] T052 [P] [US5] Create `CustomerDashboardEmptyState` widget (no-bookings CTA) in `lib/features/customer/entry/presentation/widgets/customer_dashboard_empty_state.dart`
- [x] T053 [US5] Rebuild `CustomerHomePage` as dashboard per `customer-dashboard-1.html` design, handling all states in `lib/features/customer/entry/presentation/pages/customer_home_page.dart`
- [x] T054 [US5] Register `CustomerDashboardCubit` in DI and regenerate the dependency graph in `lib/core/di/injection.dart` and `lib/core/di/injection.config.dart`

**Checkpoint**: User Story 5 — Dashboard renders correctly for all three content states: active queue, upcoming appointment only, and fully empty.

---

## Phase 9: User Story 6 — Customer Accesses Organization via QR Code or URL (Priority: P6)

**Goal**: Customer can scan a QR code from the camera or from a gallery image, or manually paste an org URL, to navigate directly to an organization's landing page — replacing the manual slug-entry field.

**Independent Test**: Scanning a valid org QR code (camera), reading a gallery image containing an org QR, and typing a valid org URL all navigate to the correct organization landing page; invalid or malformed codes show an inline error and do not crash.

**Package prerequisites** (complete before any US6 tasks):

- [x] T055 Add `mobile_scanner: ^6.0.0` and `image_picker: ^1.1.0` to `pubspec.yaml` and run `flutter pub get`
- [x] T056 Configure Android camera and `READ_MEDIA_IMAGES` permissions for QR scanning in `android/app/src/main/AndroidManifest.xml`
- [x] T057 Configure iOS `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`

**Domain**:

- [x] T058 [US6] Implement `ParseAccessUrlUseCase` (extracts org slug from a raw QR value or typed URL) in `lib/features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart`

**Presentation**:

- [x] T059 [US6] Implement `AccessPortalCubit` + sealed states (`scanning`, `urlEntry`, `resolving`, `error`, `success`) in `lib/features/customer/access_portal/presentation/cubit/access_portal_cubit.dart`
- [x] T060 [P] [US6] Create `QrScannerView` widget (live camera scanner using `mobile_scanner`) in `lib/features/customer/access_portal/presentation/widgets/qr_scanner_view.dart`
- [x] T061 [P] [US6] Create `UrlEntryBottomSheet` widget (URL input field + connect action per design) in `lib/features/customer/access_portal/presentation/widgets/url_entry_bottom_sheet.dart`
- [x] T062 [US6] Create `AccessPortalPage` assembling scanner view + bottom sheet + flash/close controls per `access-portal-variant-2.html` design in `lib/features/customer/access_portal/presentation/pages/access_portal_page.dart`
- [x] T063 [US6] Register `AccessPortalCubit` in DI and regenerate in `lib/core/di/injection.dart` and `lib/core/di/injection.config.dart`
- [x] T064 [US6] Add `/c/access` route in `lib/core/router/app_router.dart` and replace slug-text-field on customer home with a "Scan / Enter URL" CTA that navigates to `/c/access`

**Checkpoint**: User Story 6 — All three access paths (camera QR, gallery QR, manual URL) resolve to the org landing page; invalid inputs show inline errors.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Starts immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks story completion.
- **Phase 3–6 (User Stories)**: Depend on Phase 2 completion.
- **Phase 7 (Polish)**: Depends on all selected user stories being complete.
- **Phase 8 (US5)**: Depends on Phase 2 (customer booking repository contract) and Phase 4 (US2 queue status stream). Can start after Phase 4 checkpoint.
- **Phase 9 (US6)**: Depends on Phase 8 checkpoint (dashboard must exist before scan CTA is integrated). Package prerequisites (T055–T057) can be done in parallel with Phase 8.

### User Story Dependencies

- **US1 (P1)**: Starts after foundational phase; does not require US2/US3/US4 for independent admin action testing with prepared queue data.
- **US2 (P2)**: Starts after foundational phase; can run independently with prepared queue data.
- **US3 (P3)**: Starts after foundational phase; improves automation of queue creation for US1/US2 flows.
- **US4 (P4)**: Depends on basic queue status plumbing from US2 and action transitions from US1.
- **US5 (P5)**: Depends on US2 queue status stream; extends customer booking repository contract.
- **US6 (P6)**: Depends on US5 dashboard page existing to attach the scan CTA. Package prerequisites are independent.

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

### User Story 5

- [ ] T050 [P] [US5] Create `ActiveQueueStatusCard` widget in `lib/features/customer/entry/presentation/widgets/active_queue_status_card.dart`
- [ ] T051 [P] [US5] Create `UpcomingAppointmentCard` widget in `lib/features/customer/entry/presentation/widgets/upcoming_appointment_card.dart`
- [ ] T052 [P] [US5] Create `CustomerDashboardEmptyState` widget in `lib/features/customer/entry/presentation/widgets/customer_dashboard_empty_state.dart`

### User Story 6

- [x] T060 [P] [US6] Create `QrScannerView` widget in `lib/features/customer/access_portal/presentation/widgets/qr_scanner_view.dart`
- [x] T061 [P] [US6] Create `UrlEntryBottomSheet` widget in `lib/features/customer/access_portal/presentation/widgets/url_entry_bottom_sheet.dart`

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
5. Add US5 for customer dashboard redesign with state handling.
6. Add US6 for QR/URL access portal.

### Team Parallelization

1. One developer handles admin data/domain (US1/US3).
2. One developer handles customer presentation flow (US2/US4).
3. Shared reviewer handles Firestore rules/indexes + DI/router integration.
4. After Phase 7: one developer implements US5 dashboard; another prepares US6 package prerequisites and platform config in parallel.
