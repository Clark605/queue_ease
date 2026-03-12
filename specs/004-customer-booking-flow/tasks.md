# Tasks: Customer Booking Flow

**Input**: Design documents from `/specs/004-customer-booking-flow/`
**Branch**: `004-customer-booking-flow`
**Generated**: 2026-03-11
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: No test tasks — testing explicitly deferred to Sprint 8 per spec.md.

**No Tasks**: All tasks follow `- [ ] [ID] [P?] [Story?] Description with file path`

---

## Phase 1: Setup

**Purpose**: Create the booking flow directory scaffold so all subsequent tasks have a valid target path.

- [x] T001 Create `lib/customer/booking_flow/domain/use_cases/` and `lib/customer/booking_flow/presentation/{cubit,pages,widgets}/` directory structure (add `.gitkeep` files — removed when first real file is added)

**Checkpoint**: Directory skeleton exists — all Phase 3+ tasks have a valid target path.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Firestore rules + index must be deployed, and the `AppointmentRepository` domain contract + model write-path must exist before any user story use case or datasource can function.

**⚠️ CRITICAL**: No user story work can begin until T002–T003 are deployed and T004–T005 are committed.

- [x] T002 [P] Fix appointment `create`/`update` allowed fields and add customer `list` permission in `firestore.rules` (add `customerName`, `customerPhone`, `queuePosition` to `hasOnlyAllowedFields`; change appointment `allow list` from `ownsOrganization(orgId)` to `isAuthenticated()`)
- [x] T003 [P] Add `serviceId ASC` + `scheduledAt ASC` compound index for the `organizations/{orgId}/appointments` subcollection in `firestore.indexes.json`
- [x] T004 [P] Create `AppointmentRepository` abstract interface with `createAppointment()` and `getAppointmentsForDateAndService()` in `lib/shared/booking/domain/repositories/appointment_repository.dart` (follow contract in `contracts/appointment_repository.dart`)
- [x] T005 [P] Add `AppointmentModel.fromEntity(AppointmentEntity)` named constructor to `lib/shared/booking/data/models/appointment_model.dart` (write path: datasource calls `AppointmentModel.fromEntity(entity).toMap()` when writing to Firestore)

**Checkpoint**: Deploy rules + index (`firebase deploy --only firestore:rules,firestore:indexes --project queue-ease-dev`). Foundation is ready — user story implementation can now begin sequentially per the funnel dependency chain.

---

## Phase 3: User Story 1 — Customer Lands on Organization Booking Page (Priority: P1) 🎯 MVP

**Goal**: A customer opens `/c/org/:slug`, sees the organization landing page with name, open/closed status, address, and a "Book Appointment" button. Unrecognized slugs show a not-found error. Unauthenticated users are redirected to login.

**Independent Test**: Open `/c/org/<valid-slug>` — org name and open/closed badge render. Open `/c/org/unknown-slug` — not-found screen renders. GoRouter redirect fires for unauthenticated user.

- [x] T006 [P] [US1] Add `Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug)` to `OrganizationRepository` in `lib/shared/organization/domain/repositories/organization_repository.dart` (follow contract in `contracts/organization_repository_extension.dart`)
- [x] T007 [P] [US1] Add `getBySlug(String slug)` Firestore query (`where('bookingLinkSlug', isEqualTo: slug.toLowerCase()).limit(1)`) to `FirestoreOrganizationDatasource` in `lib/shared/organization/data/datasources/firestore_organization_datasource.dart`
- [x] T008 [US1] Implement `getOrganizationBySlug()` in `OrganizationRepositoryImpl`, wrapping the datasource call in `Result.guard()`; add `@lazySingleton` registration scope remains unchanged in `lib/shared/organization/data/repositories/organization_repository_impl.dart`
- [x] T009 [US1] Create `GetOrganizationBySlugUseCase` (`@lazySingleton`) that calls `OrganizationRepository.getOrganizationBySlug()`; logs `talker.warning()` on not-found, `talker.error()` on `DatabaseException` in `lib/customer/booking_flow/domain/use_cases/get_organization_by_slug_use_case.dart`
- [x] T010 [P] [US1] Create `OrganizationLandingState` as a sealed class with states: `OrganizationLandingInitial`, `OrganizationLandingLoading`, `OrganizationLandingLoaded(OrganizationEntity org, bool isCurrentlyOpen)`, `OrganizationLandingNotFound`, `OrganizationLandingError(String message)` in `lib/customer/booking_flow/presentation/cubit/organization_landing_state.dart`
- [x] T011 [US1] Create `OrganizationLandingCubit` (`@injectable`), injecting `GetOrganizationBySlugUseCase`; method `loadOrganization(String slug)` resolves slug to entity and derives `isCurrentlyOpen` from `WorkingHoursEntity` list via `WorkingHoursRepository` in `lib/customer/booking_flow/presentation/cubit/organization_landing_cubit.dart`
- [x] T012 [US1] Create `OrganizationLandingPage` consuming `OrganizationLandingCubit`; display name, description, address, open/closed badge; show `AppLoadingIndicator` on loading, not-found screen on `OrganizationLandingNotFound`, "Book Appointment" button (enabled only when `isCurrentlyOpen`) in `lib/customer/booking_flow/presentation/pages/organization_landing_page.dart`
- [x] T013 [US1] Add `/c/org/:slug` route to `GoRouter` in `lib/core/router/app_router.dart`; wire RBAC redirect (unauthenticated → `/login` with `from` param pointing back to `/c/org/:slug`); provide `OrganizationLandingCubit` via `BlocProvider` in the route builder

**Checkpoint**: User Story 1 is fully functional — tap a booking link, see the org landing page.

---

## Phase 4: User Story 2 — Customer Selects a Service (Priority: P2)

**Goal**: Customer taps "Book Appointment", is navigated to the service selection screen, sees all active services (name, duration, price, description), and taps one to proceed.

**Independent Test**: On the service selection screen, at least one active service renders with name + duration. Tapping it navigates to the slot picker. Empty state renders when no active services exist.

- [x] T014 [US2] Create `GetActiveServicesUseCase` (`@lazySingleton`) that calls `ServiceRepository.watchServices(orgId)` and filters to `isActive == true`; logs `talker.error()` on failure in `lib/customer/booking_flow/domain/use_cases/get_active_services_use_case.dart`
- [x] T015 [P] [US2] Create `ServiceSelectionState` sealed class with states: `ServiceSelectionInitial`, `ServiceSelectionLoading`, `ServiceSelectionLoaded(List<ServiceEntity> services)`, `ServiceSelectionError(String message)` in `lib/customer/booking_flow/presentation/cubit/service_selection_state.dart`
- [x] T016 [P] [US2] Create `ServiceCard` widget displaying service name, duration, optional price, optional description; accepts an `onTap` callback in `lib/customer/booking_flow/presentation/widgets/service_card.dart`
- [x] T017 [US2] Create `ServiceSelectionCubit` (`@injectable`), injecting `GetActiveServicesUseCase`; method `loadServices(String orgId)` subscribes to the active-services stream in `lib/customer/booking_flow/presentation/cubit/service_selection_cubit.dart`
- [x] T018 [US2] Create `ServiceSelectionPage` consuming `ServiceSelectionCubit`; render `ListView.builder` of `ServiceCard`; show empty-state widget when list is empty; show `AppLoadingIndicator` on loading in `lib/customer/booking_flow/presentation/pages/service_selection_page.dart`
- [x] T019 [US2] Add `/c/org/:slug/services` route in `lib/core/router/app_router.dart`; wire "Book Appointment" button on `OrganizationLandingPage` to navigate here passing `orgId` as extra; provide `ServiceSelectionCubit` via `BlocProvider`

**Checkpoint**: User Stories 1 and 2 work — org landing page → service selection.

---

## Phase 5: User Story 3 — Customer Picks an Available Time Slot (Priority: P3)

**Goal**: Customer selects a date (today + 6 days), slot calculation excludes breaks, past times, and existing confirmed appointments; available slots render in a scrollable grid; customer taps a slot and taps "Continue".

**Independent Test**: With a 30-min service, org hours 09:00–17:00 with 12:00–13:00 break and one existing booking at 10:00, the slot at 10:00 is absent and no slots in 12:00–13:00 appear. All other 30-min boundary slots are present.

- [ ] T020 [US3] Create `FirestoreAppointmentDatasource` (`@lazySingleton`) with: `getAppointmentsForDateAndService({orgId, serviceId, date})` (range query on `scheduledAt` + `serviceId` filter) and `createAppointmentTransactional(AppointmentEntity)` (Firestore transaction with re-check then write); log errors via `talker.error()` in `lib/shared/booking/data/datasources/firestore_appointment_datasource.dart`
- [ ] T021 [US3] Create `AppointmentRepositoryImpl` (`@LazySingleton(as: AppointmentRepository)`), delegating both methods to `FirestoreAppointmentDatasource`, wrapping in `Result.guard()`; map `FirebaseException` codes to `AppException` subtypes in `lib/shared/booking/data/repositories/appointment_repository_impl.dart`
- [ ] T022 [US3] Create `CalculateAvailableSlotsUseCase` (`@lazySingleton`): pure domain algorithm — (1) generate candidate slots at `durationMinutes` intervals from `openTime` to `closeTime`, (2) remove overlap with `breakStart–breakEnd`, (3) fetch existing appointments from `AppointmentRepository.getAppointmentsForDateAndService()`, (4) remove overlap with confirmed appointments (status ≠ `noShow`), (5) remove past slots for today; log `talker.warning()` on empty result in `lib/customer/booking_flow/domain/use_cases/calculate_available_slots_use_case.dart`
- [ ] T023 [P] [US3] Create `SlotPickerState` sealed class with states: `SlotPickerInitial`, `SlotPickerLoading(DateTime selectedDate)`, `SlotPickerLoaded(DateTime selectedDate, List<DateTime> availableSlots, DateTime? selectedSlot)`, `SlotPickerNoSlots(DateTime selectedDate)`, `SlotPickerError(String message)` in `lib/customer/booking_flow/presentation/cubit/slot_picker_state.dart`
- [ ] T024 [P] [US3] Create `DateSelector` widget: horizontal 7-day row (today → +6 days); closed days (per `WorkingHoursEntity.isOpen`) shown as disabled; selected day highlighted; emits `onDateSelected(DateTime)` callback in `lib/customer/booking_flow/presentation/widgets/date_selector.dart`
- [ ] T025 [P] [US3] Create `TimeSlotGrid` widget: `ListView.builder` of time slot chips from `List<DateTime>`; tap-to-select highlights the slot (stores `selectedSlot`); empty state widget when list is empty in `lib/customer/booking_flow/presentation/widgets/time_slot_grid.dart`
- [ ] T026 [US3] Create `SlotPickerCubit` (`@injectable`), injecting `CalculateAvailableSlotsUseCase` and `WorkingHoursRepository`; method `loadSlotsForDate({orgId, serviceId, date, durationMinutes})` fetches working hours then delegates to use case; method `selectSlot(DateTime)` updates `selectedSlot` on `SlotPickerLoaded` in `lib/customer/booking_flow/presentation/cubit/slot_picker_cubit.dart`
- [ ] T027 [US3] Create `SlotPickerPage` consuming `SlotPickerCubit`; compose `DateSelector` + `TimeSlotGrid`; show `AppLoadingIndicator` on loading; enable "Continue" button only when `selectedSlot != null` in `lib/customer/booking_flow/presentation/pages/slot_picker_page.dart`
- [ ] T028 [US3] Add `/c/org/:slug/slots` route in `lib/core/router/app_router.dart`; wire `ServiceSelectionPage` service-tap callback to navigate here passing `orgId`, `serviceId`, `serviceDurationMinutes` as extra; provide `SlotPickerCubit` via `BlocProvider`

**Checkpoint**: User Stories 1–3 work — org → service → slot picker with accurate conflict-aware slot list.

---

## Phase 6: User Story 4 — Customer Confirms Booking Details and Submits (Priority: P4)

**Goal**: Customer sees a booking summary, has a pre-filled name field (from auth profile), optional phone field; taps "Confirm Booking"; appointment is created with transactional conflict check; network errors show inline retry; slot conflict navigates back with error message.

**Independent Test**: Valid name + slot → appointment saved with `status = booked`, all required fields set. Empty name → inline validation error. Second concurrent write to same slot → conflict error shown, form stays mounted.

- [ ] T029 [US4] Create `CreateBookingUseCase` (`@lazySingleton`), injecting `AppointmentRepository`; validate `customerName` not empty (emit `ValidationException`); construct `AppointmentEntity` with `status = booked`, `createdAt = DateTime.now()`; delegate to `AppointmentRepository.createAppointment()`; log `talker.warning()` on conflict, `talker.error()` on other failures in `lib/customer/booking_flow/domain/use_cases/create_booking_use_case.dart`
- [ ] T030 [P] [US4] Create `BookingFormState` sealed class with states: `BookingFormInitial(String prefillName)`, `BookingFormSubmitting`, `BookingFormSuccess(AppointmentEntity appointment)`, `BookingFormConflict(String message)`, `BookingFormError(String message)` in `lib/customer/booking_flow/presentation/cubit/booking_form_state.dart`
- [ ] T031 [P] [US4] Create `BookingSummaryCard` widget: displays org name, service name, formatted date + time, duration; uses `const` constructor; read-only in `lib/customer/booking_flow/presentation/widgets/booking_summary_card.dart`
- [ ] T032 [US4] Create `BookingFormCubit` (`@injectable`), injecting `CreateBookingUseCase`; on submit: emits `BookingFormSubmitting` → calls use case → emits `BookingFormSuccess` or `BookingFormConflict` or `BookingFormError`; form data (name, phone) is held in the cubit so retry re-uses same inputs in `lib/customer/booking_flow/presentation/cubit/booking_form_cubit.dart`
- [ ] T033 [US4] Create `BookingFormPage` consuming `BookingFormCubit`; render `BookingSummaryCard` + name `TextFormField` (required validation) + phone `TextFormField` (optional); on `BookingFormError` emit inline error banner with "Retry" button (form stays mounted, fields preserved); on `BookingFormConflict` show snackbar then pop back to slot picker in `lib/customer/booking_flow/presentation/pages/booking_form_page.dart`
- [ ] T034 [US4] Add `/c/org/:slug/book` route in `lib/core/router/app_router.dart`; wire `SlotPickerPage` "Continue" button to navigate here passing `orgId`, `serviceId`, `serviceEntity`, `scheduledAt`, `customerId`; provide `BookingFormCubit` via `BlocProvider`

**Checkpoint**: User Stories 1–4 work — full booking funnel through to successful appointment write.

---

## Phase 7: User Story 5 — Customer Views Booking Confirmation (Priority: P5)

**Goal**: After a successful booking, the customer sees a confirmation screen with org name, service name, scheduled date/time, and optional address. A "Back to Home" button clears the booking stack and navigates to customer home.

**Independent Test**: `BookingConfirmationPage` renders correct org + service + time data from the passed `AppointmentEntity`. "Back to Home" clears the `/c/org/:slug/...` stack and lands on customer home.

- [ ] T035 [US5] Create `BookingConfirmationPage` (stateless): accepts `OrganizationEntity`, `ServiceEntity`, `AppointmentEntity` via GoRouter extra; displays org name, service name, formatted scheduled date/time, optional address; "Back to Home" button in `lib/customer/booking_flow/presentation/pages/booking_confirmation_page.dart`
- [ ] T036 [US5] Add `/c/org/:slug/confirmation` route in `lib/core/router/app_router.dart`; on `BookingFormCubit` emitting `BookingFormSuccess`, navigate here with `go()` (not `push()`) to clear the booking stack; "Back to Home" calls `context.go('/c')` to land on customer home

**Checkpoint**: Complete end-to-end booking funnel is demoable: QR link → org → service → slot → form → confirmation → home.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: DI build, observability hardening, auth redirect validation, and end-to-end smoke test.

- [ ] T037 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/core/di/injection.config.dart` after all `@injectable` / `@lazySingleton` / `@LazySingleton` annotations are added (T008–T009, T011, T014, T017, T020–T022, T026, T029, T032)
- [ ] T038 [P] Audit all use case `impl` classes and `AppointmentRepositoryImpl` to confirm `talker.error()` is called for `DatabaseException`/`UnknownException` and `talker.warning()` for `ValidationException`; confirm no PII fields (customerName, customerPhone, customerId) appear in any log message per Observability FR
- [ ] T039 [P] Verify GoRouter redirect fires correctly for unauthenticated deep links to `/c/org/:slug` — confirm `from` query param is preserved through login and the customer is returned to the booking page in `lib/core/router/app_router.dart`
- [ ] T040 Run quickstart.md end-to-end smoke test: `flutter run -t lib/main_dev.dart` → scan QR → org landing page loads → select service → select slot → fill form → confirm → see confirmation screen → tap home

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)            → No dependencies
Phase 2 (Foundational)     → Phase 1 complete; deploy rules+index to Firebase before US3 data layer
Phase 3 (US1)              → Phase 2 complete
Phase 4 (US2)              → Phase 3 complete (routes nest under /c/org/:slug established in US1)
Phase 5 (US3)              → Phase 4 complete (slot picker receives serviceId from US2)
Phase 6 (US4)              → Phase 5 complete (booking form receives scheduledAt from US3)
Phase 7 (US5)              → Phase 6 complete (confirmation receives AppointmentEntity from US4)
Phase 8 (Polish)           → All user story phases complete
```

### User Story Dependencies

This feature is a **linear booking funnel** — each story is a step that feeds into the next. Stories cannot be implemented fully in parallel because each screen receives data from the previous screen.

| Story | Depends On | Reason |
|-------|-----------|--------|
| US1 (P1) | Phase 2 only | Entry point — no prior story needed |
| US2 (P2) | US1 | `orgId` and slug route context established in US1 |
| US3 (P3) | US2 + Phase 2 deployed | `serviceId` + `durationMinutes` passed from US2; appointment query needs rules+index |
| US4 (P4) | US3 | `scheduledAt` passed from US3; datasource + repo impl created in US3 |
| US5 (P5) | US4 | `AppointmentEntity` result passed from US4 |

### Within Each User Story

| Pattern | Rule |
|---------|------|
| Domain interface before impl | T006 before T008; T004 before T020 |
| Datasource before repo impl | T020 before T021 |
| Use case before cubit | T009 before T011; T014 before T017; T022 before T026; T029 before T032 |
| State file before cubit | T010 before T011; T015 before T017; T023 before T026; T030 before T032 |
| Cubit + widget before page | T011 before T012; T016+T017 before T018; T024+T025+T026 before T027; T031+T032 before T033 |
| Page before route | T012 before T013; T018 before T019; T027 before T028; T033 before T034; T035 before T036 |

---

## Parallel Opportunities

### Phase 2 — All 4 tasks are parallel:

```
T002 [fix firestore.rules]        ─┐
T003 [add index]                   ├─ all in parallel
T004 [AppointmentRepository iface] ├─
T005 [AppointmentModel.fromEntity] ─┘
```

### Phase 3 — US1 parallel cluster:

```
T006 [OrgRepo domain method]  ─┐
T007 [Datasource getBySlug]    ├─ parallel
T010 [LandingState]            ─┘
  ↓
T008 [OrgRepoImpl]  ─┐
T009 [UseCase]       ├─ parallel after T006+T007
                     │
T011 [Cubit] ← T009+T010
T012 [Page]  ← T011
T013 [Route] ← T012
```

### Phase 4 — US2 parallel cluster:

```
T015 [ServiceSelectionState]  ─┐
T016 [ServiceCard widget]      ├─ parallel
T014 [GetActiveServicesUseCase]─┘
  ↓
T017 [Cubit]  ← T014 + T015
T018 [Page]   ← T016 + T017
T019 [Route]  ← T018
```

### Phase 5 — US3 parallel cluster:

```
T020 [Datasource]   ─┐
T023 [SlotState]     │
T024 [DateSelector]  ├─ parallel
T025 [TimeSlotGrid]  │
T022 [UseCase]       ─┘  (needs T004 — AppointmentRepository iface)
  ↓
T021 [RepoImpl]    ← T020
T026 [Cubit]       ← T022 + T023
T027 [Page]        ← T024 + T025 + T026
T028 [Route]       ← T027
```

### Phase 6 — US4 parallel cluster:

```
T030 [BookingFormState]   ─┐
T031 [BookingSummaryCard]  ├─ parallel
T029 [CreateBookingUseCase]─┘
  ↓
T032 [Cubit]  ← T029 + T030
T033 [Page]   ← T031 + T032
T034 [Route]  ← T033
```

### Phase 8 — Polish parallel:

```
T038 [Talker audit]        ─┐
T039 [Auth redirect verify] ├─ parallel
                             │
T037 [build_runner]         ─┘ (run first — others can run after T037 finishes)
T040 [smoke test]            (run last)
```

---

## Implementation Strategy

**MVP Scope**: Complete User Story 1 (T001–T013) first. This validates the Firestore rules fix, slug lookup path, and GoRouter deep-link routing before any slot or booking logic is written.

**Incremental Delivery**:
1. **Sprint 4.1** — Phase 1 + Phase 2 + Phase 3 (US1): Org landing page demoable
2. **Sprint 4.2** — Phase 4 (US2): Service selection demoable
3. **Sprint 4.3** — Phase 5 (US3): Slot picker demoable (hardest phase — 9 tasks)
4. **Sprint 4.4** — Phase 6 + Phase 7 + Phase 8 (US4 + US5 + Polish): Full funnel complete

**Key Risk**: T020–T022 (datasource + repo impl + use case for slot calculation) is the densest cluster. The slot algorithm in `CalculateAvailableSlotsUseCase` is the single most complex task — plan for iterative refinement around the step-5 past-slot filtering edge case.

---

## Summary

| Metric | Value |
|--------|-------|
| Total tasks | 40 |
| Phase 1 (Setup) | 1 task |
| Phase 2 (Foundational) | 4 tasks |
| Phase 3 (US1 — Org Landing) | 8 tasks |
| Phase 4 (US2 — Service Selection) | 6 tasks |
| Phase 5 (US3 — Slot Picker) | 9 tasks |
| Phase 6 (US4 — Booking Form) | 6 tasks |
| Phase 7 (US5 — Confirmation) | 2 tasks |
| Phase 8 (Polish) | 4 tasks |
| Parallelizable tasks [P] | 17 tasks |
| New files | ~28 |
| Modified files | 7 (`firestore.rules`, `firestore.indexes.json`, `organization_repository.dart`, `firestore_organization_datasource.dart`, `organization_repository_impl.dart`, `appointment_model.dart`, `app_router.dart`) |
| Suggested MVP | Phase 1 + Phase 2 + Phase 3 (US1) — 13 tasks |
