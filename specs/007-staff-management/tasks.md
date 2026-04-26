# Tasks: Staff Member Management (Hybrid Approach - Development Mode)

**Input**: Design documents from `/specs/007-staff-management/`
**Prerequisites**: `spec.md` (required)
**Target Branch**: `007-staff-management`
**Environment**: Development (no data migration, no tests)

**Total Tasks**: 57 (streamlined from 86 original tasks)

---

## Phase 1: Setup & Domain Foundation

**Purpose**: Create the foundational data structures and domain contracts for staff management.

- [ ] T001 Create feature branch `007-staff-management` from main
- [ ] T002 Create staff management feature directory structure at `lib/features/admin/staff_management/{data,domain,presentation}`
- [ ] T003 Create `StaffMemberEntity` in `lib/features/shared_domain/entities/staff_member_entity.dart`
- [ ] T004 Create `StaffMemberModel` in `lib/features/shared_domain/models/staff_member_model.dart`

---

## Phase 2: Breaking Changes to Existing Entities

**Purpose**: Update ServiceEntity and AppointmentEntity with required staffId fields.

**⚠️ CRITICAL**: These are breaking changes. New services/appointments must include staffId.

- [ ] T007 Update `ServiceEntity` to add `staffId` (required) and `staffName` (optional) fields in `lib/features/shared_domain/entities/service_entity.dart`
- [ ] T008 Update `ServiceModel` Firestore serialization to include `staffId` and `staffName` in `lib/features/shared_domain/models/service_model.dart`
- [ ] T009 Update `AppointmentEntity` to add `staffId` (required) and `staffName` (optional) fields in `lib/features/shared_domain/entities/appointment_entity.dart`
- [ ] T010 Update `AppointmentModel` Firestore serialization to include `staffId` and `staffName` in `lib/features/shared_domain/models/appointment_model.dart`

**Checkpoint**: Domain layer updated — data and presentation layers can now proceed.

---

## Phase 3: Staff Member Repository Layer

**Purpose**: Implement CRUD operations for staff members.

- [ ] T015 Create `StaffRepository` domain interface in `lib/features/admin/staff_management/domain/repositories/staff_repository.dart`
- [ ] T016 Create `StaffDatasource` in `lib/features/admin/staff_management/data/datasources/staff_datasource.dart`
- [ ] T017 Implement `StaffRepositoryImpl` with real-time streams in `lib/features/admin/staff_management/data/repositories/staff_repository_impl.dart`
- [ ] T018 Add `@lazySingleton` DI registration for repository in `lib/core/di/injection.dart`

---

## Phase 4: Staff Member Use Cases

**Purpose**: Create domain use cases for staff management operations.

- [ ] T021 Create `CreateStaffMemberUseCase` in `lib/features/admin/staff_management/domain/use_cases/create_staff_member_use_case.dart`
- [ ] T022 Create `UpdateStaffMemberUseCase` in `lib/features/admin/staff_management/domain/use_cases/update_staff_member_use_case.dart`
- [ ] T023 Create `DeleteStaffMemberUseCase` with service-check validation in `lib/features/admin/staff_management/domain/use_cases/delete_staff_member_use_case.dart`
- [ ] T024 Create `WatchStaffMembersUseCase` in `lib/features/admin/staff_management/domain/use_cases/watch_staff_members_use_case.dart`
- [ ] T025 Create `GetStaffMemberByIdUseCase` in `lib/features/admin/staff_management/domain/use_cases/get_staff_member_by_id_use_case.dart`

---

## Phase 5: Staff Management State & UI

**Purpose**: Build admin UI for staff member CRUD.

### State Management

- [ ] T027 Create `StaffManagementState` sealed class hierarchy in `lib/features/admin/staff_management/presentation/cubit/staff_management_state.dart`
- [ ] T028 Create `StaffManagementCubit` in `lib/features/admin/staff_management/presentation/cubit/staff_management_cubit.dart`

### UI Components

- [ ] T030 Create `StaffManagementPage` with list view in `lib/features/admin/staff_management/presentation/pages/staff_management_page.dart`
- [ ] T031 Create `StaffCard` widget in `lib/features/admin/staff_management/presentation/widgets/staff_card.dart`
- [ ] T032 Create `StaffFormPage` for create/edit in `lib/features/admin/staff_management/presentation/pages/staff_form_page.dart`
- [ ] T033 Create `StaffEmptyState` widget in `lib/features/admin/staff_management/presentation/widgets/staff_empty_state.dart`
- [ ] T034 Create `StaffDeletionDialog` with service-check warning in `lib/features/admin/staff_management/presentation/widgets/staff_deletion_dialog.dart`
- [ ] T035 Add staff management route to `lib/core/router/app_router.dart` at `/a/staff`
- [ ] T036 Add "Staff Management" navigation item to admin dashboard in `lib/features/admin/dashboard/presentation/pages/admin_dashboard_page.dart`

**Checkpoint**: Staff CRUD is fully functional — admins can create and manage staff members.

---

## Phase 6: Service Management Updates (Breaking Change Integration)

**Purpose**: Update service creation/editing to require staff assignment.

- [ ] T037 Update `ServiceFormPage` to add staff member dropdown selector in `lib/features/admin/service_management/presentation/pages/service_form_page.dart`
- [ ] T038 Update `ServiceFormState` to include `selectedStaffId` field in `lib/features/admin/service_management/presentation/cubit/service_form_state.dart`
- [ ] T039 Update `ServiceFormCubit` to validate `staffId` is not null before save in `lib/features/admin/service_management/presentation/cubit/service_form_cubit.dart`
- [ ] T040 Update `ServiceCard` to display assigned staff name in `lib/features/admin/service_management/presentation/widgets/service_card.dart`
- [ ] T041 Update service list to show "No staff" warning badge for unassigned services in `lib/features/admin/service_management/presentation/pages/service_list_page.dart`

---

## Phase 7: Appointment Updates (Staff Inheritance)

**Purpose**: Populate staffId and staffName in appointments during booking.

- [ ] T043 Update `BookingFormCubit` to fetch service's `staffId` and `staffName` before creating appointment in `lib/features/customer/booking/presentation/cubit/booking_form_cubit.dart`
- [ ] T044 Update `AppointmentDatasource.createAppointment` to accept `staffId` and `staffName` parameters in `lib/features/customer/booking/data/datasources/appointment_datasource.dart`
- [ ] T045 Update `AppointmentRepositoryImpl.createAppointment` to pass staff fields in `lib/features/customer/booking/data/repositories/appointment_repository_impl.dart`
- [ ] T046 Update available slot calculation to consider staff-specific appointments (optimization) in `lib/features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart`

---

## Phase 8: Queue UI Enhancements (Staff Filtering)

**Purpose**: Display staff assignments in queue and add filtering capability.

### Queue Entry Display

- [ ] T048 Update `QueueEntryView` model to include `staffName` field in `lib/features/admin/queue_management/domain/repositories/admin_appointment_repository.dart`
- [ ] T049 Update `AdminQueueRepositoryImpl` to map `staffName` from appointments in `lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart`
- [ ] T050 Update `CurrentQueueCard` to display staff name next to customer name in `lib/features/admin/queue_management/presentation/widgets/current_queue_card.dart`
- [ ] T051 Update `WaitingQueueList` entry cards to show staff badge in `lib/features/admin/queue_management/presentation/widgets/waiting_queue_list.dart`

### Staff Filtering

- [ ] T052 Add `selectedStaffId` filter state to `QueueManagementState` in `lib/features/admin/queue_management/presentation/cubit/queue_management_state.dart`
- [ ] T053 Add `filterByStaff(staffId)` and `clearStaffFilter()` methods to `QueueManagementCubit` in `lib/features/admin/queue_management/presentation/cubit/queue_management_cubit.dart`
- [ ] T054 Create `StaffFilterDropdown` widget in `lib/features/admin/queue_management/presentation/widgets/staff_filter_dropdown.dart`
- [ ] T055 Add staff filter dropdown to `QueueManagementPage` header in `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart`
- [ ] T056 Update queue entry rendering to respect staff filter in `lib/features/admin/queue_management/presentation/widgets/queue_content.dart`

**Checkpoint**: Queue management now shows and filters by staff assignments.

---

## Phase 9: Customer Experience (Inactive Staff Handling)

**Purpose**: Hide services assigned to inactive staff from customer booking flow.

- [ ] T058 Update `ServiceSelectionCubit` to filter out services with inactive staff in `lib/features/customer/booking/presentation/cubit/service_selection_cubit.dart`
- [ ] T059 Update `ServiceRepository.watchActiveServices` query to join with staff status in `lib/features/admin/service_management/data/repositories/service_repository_impl.dart`
- [ ] T060 Add "Staff unavailable" empty state messaging when all services filtered out in `lib/features/customer/booking/presentation/widgets/service_empty_state.dart`

---

## Phase 10: Firestore Security Rules

**Purpose**: Add security rules for staff subcollection and update service/appointment validation.

- [ ] T062 Add staff subcollection CRUD rules in `firestore.rules` at `/organizations/{orgId}/staff/{staffId}`
- [ ] T063 Update service validation rules to require `staffId` field in `firestore.rules`
- [ ] T064 Update appointment validation rules to require `staffId` field in `firestore.rules`
- [ ] T067 Deploy updated rules to dev environment using `firebase deploy --only firestore:rules --project ease-queue-dev`

**Checkpoint**: Firestore security enforces staff model constraints.

---

## Phase 11: Integration & Polish

**Purpose**: Final hardening and code quality.

- [ ] T078 Regenerate dependency injection using `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] T079 Run `flutter analyze` and fix all warnings/errors
- [ ] T082 Update `docs/FEATURE_CHECKLIST.md` to mark Sprint 6A complete
- [ ] T083 Update `docs/PROJECT_TIMELINE.md` with Sprint 6A actuals
- [ ] T084 Create PR from `007-staff-management` to `main` with comprehensive description

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Starts immediately after branch creation.
- **Phase 2 (Breaking Changes)**: Depends on Phase 1 entity foundation.
- **Phase 3 (Repository)**: Depends on Phase 1 (StaffMemberEntity/Model).
- **Phase 4 (Use Cases)**: Depends on Phase 3 (repository contracts).
- **Phase 5 (Staff UI)**: Depends on Phase 4 (use cases).
- **Phase 6 (Service Updates)**: Depends on Phase 2 (ServiceEntity with staffId) and Phase 5 (staff list available).
- **Phase 7 (Appointment Updates)**: Depends on Phase 2 (AppointmentEntity with staffId) and Phase 6 (services have staffId).
- **Phase 8 (Queue UI)**: Depends on Phase 7 (appointments have staffId).
- **Phase 9 (Customer Flow)**: Depends on Phase 6 (services have staff) and Phase 3 (staff repository for active check).
- **Phase 10 (Rules)**: Can proceed in parallel after Phase 2 (entity changes defined).
- **Phase 11 (Polish)**: Depends on all implementation phases complete.

### Critical Path

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8 → Phase 11
```

### Parallel Opportunities

**Phase 5 & 10**: Staff UI (T027-T036) and Firestore Rules (T062-T067) can run in parallel.

**Phase 6 & 7**: Service updates (T037-T041) and Appointment updates (T043-T046) can overlap once Phase 2 completes.

**Phase 8 & 9**: Queue UI (T048-T056) and Customer flow (T058-T060) can run in parallel once Phase 7 completes.

---

## Estimated Timeline (Development Mode)

**Total Effort**: ~6-7 days (assuming 1 developer)

| Phase | Tasks | Estimated Days |
|-------|-------|----------------|
| Phase 1 | T001-T004 | 0.5 day |
| Phase 2 | T007-T010 | 1 day |
| Phase 3 | T015-T018 | 1 day |
| Phase 4 | T021-T025 | 0.5 day |
| Phase 5 | T027-T036 | 1.5 days |
| Phase 6 | T037-T041 | 0.5 day |
| Phase 7 | T043-T046 | 0.5 day |
| Phase 8 | T048-T056 | 1 day |
| Phase 9 | T058-T060 | 0.5 day |
| Phase 10 | T062-T067 | 0.5 day |
| Phase 11 | T078-T084 | 0.5 day |
| **Total** | **57 tasks** | **~7 days** |

**Note**: Timeline assumes serial execution. With parallel execution of independent phases, can be reduced to 5-6 days.

---

## Sprint Completion Criteria (Development Mode)

### Definition of Done

- [ ] All 57 tasks completed and checked off
- [ ] `flutter analyze` passes with zero warnings/errors
- [ ] Firestore security rules deployed to dev
- [ ] E2E manual test passes: create staff → assign to service → customer books → queue shows staff → filtering works
- [ ] Code review completed and PR merged to main

### Manual Testing Checklist

**Admin Staff Management**:
- [ ] Create staff member with name, role, phone
- [ ] Edit staff member details
- [ ] Mark staff inactive/active
- [ ] Attempt to delete staff with assigned services (should be blocked)
- [ ] Delete staff with no services

**Service Assignment**:
- [ ] Create new service and assign to staff
- [ ] Edit existing service to change staff assignment
- [ ] View service list showing staff names
- [ ] Attempt to create service without selecting staff (should fail validation)

**Customer Booking Flow**:
- [ ] Customer selects service and books appointment
- [ ] Verify appointment has correct staffId in Firestore
- [ ] Services with inactive staff should be hidden

**Queue Management**:
- [ ] View queue showing staff names on entries
- [ ] Filter queue by specific staff member
- [ ] Perform queue actions (next, skip) with filter active
- [ ] Clear filter to see all appointments

---

## Risk Mitigation

### High-Risk Tasks

- **T007-T010**: Breaking changes to core entities — requires fresh test data in dev
- **T067**: Rules deployment — test thoroughly before deploying

### Rollback Strategy (Development Mode)

If breaking changes cause issues:
1. Revert code changes via git
2. Revert Firestore rules to previous version
3. Clear dev Firestore data and re-seed if needed

---

## Notes

- All 29 test tasks removed (34% task reduction)
- Phase 11 (Migration) entirely removed (9 tasks)
- Development mode allows fresh data creation without migration complexity
- Timeline reduced from 11-12 days to 6-7 days
- Original 86 tasks streamlined to 57 tasks
- Focus on rapid iteration and functionality over test coverage

---

**Document Status**: Complete — Ready for Implementation
**Next Steps**: Begin Phase 1 setup and domain foundation
