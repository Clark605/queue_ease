# Quickstart: Customer Booking Flow

**Feature**: `004-customer-booking-flow`  
**Branch**: `004-customer-booking-flow`

---

## Prerequisites

- Flutter SDK ≥ 3.9.0
- Firebase project configured (dev environment)
- Firebase Emulator Suite (for local Firestore testing)
- An existing admin account with an organization, at least one active service, and working hours configured (created via Sprint 2 + Sprint 3)

---

## Setup

```bash
# Switch to feature branch
git checkout 004-customer-booking-flow

# Get dependencies
flutter pub get

# Regenerate DI config after adding new injectable classes
dart run build_runner build --delete-conflicting-outputs

# Deploy updated Firestore rules (adds customerName/customerPhone fields + customer list permission)
firebase deploy --only firestore:rules --project queue-ease-dev

# Deploy Firestore indexes (compound index for appointment queries)
firebase deploy --only firestore:indexes --project queue-ease-dev
```

---

## Implementation Order

This is a strict dependency chain — each step depends on the previous:

### Phase 1: Firestore Rules + Index (BLOCKER)
1. Update `firestore.rules` — add `customerName`, `customerPhone`, `queuePosition` to allowed appointment fields; allow customer list
2. Add compound index to `firestore.indexes.json` — `serviceId` ASC + `scheduledAt` ASC
3. Deploy both to dev project

### Phase 2: Data Layer
4. Add `getOrganizationBySlug()` to `OrganizationRepository` (domain) + `OrganizationRepositoryImpl` (data) + `FirestoreOrganizationDatasource`
5. Create `AppointmentRepository` (domain) abstract class
6. Create `FirestoreAppointmentDatasource` — Firestore queries + transactional create
7. Create `AppointmentRepositoryImpl` — delegates to datasource, wraps in Result

### Phase 3: Domain Layer (Use Cases)
8. `GetOrganizationBySlugUseCase` — calls OrganizationRepository
9. `GetActiveServicesUseCase` — calls ServiceRepository, filters isActive
10. `CalculateAvailableSlotsUseCase` — pure slot algorithm + AppointmentRepository query
11. `CreateBookingUseCase` — validates inputs, calls AppointmentRepository.createAppointment

### Phase 4: Presentation Layer
12. `OrganizationLandingCubit` + `OrganizationLandingPage` — slug resolution + org display
13. `ServiceSelectionCubit` + `ServiceSelectionPage` — active service list
14. `SlotPickerCubit` + `SlotPickerPage` — date selector + slot grid
15. `BookingFormCubit` + `BookingFormPage` — name/phone form + confirm
16. `BookingConfirmationPage` — static result screen

### Phase 5: Navigation + Wiring
17. Add routes to GoRouter (`/c/org/:slug`, `/c/org/:slug/services`, etc.)
18. Register all new classes in Injectable DI
19. Run `build_runner` to regenerate DI config

---

## Verification

```bash
# Run the app in dev mode
flutter run --dart-define=FLAVOR=dev -t lib/main_dev.dart

# Test the flow:
# 1. Log in as a customer
# 2. Navigate to /c/org/<slug> (use an admin's bookingLinkSlug)
# 3. See organization landing page with open/closed status
# 4. Tap "Book Appointment" → see active services
# 5. Select a service → see date/slot picker
# 6. Pick a date and slot → see booking form
# 7. Confirm → see confirmation screen
# 8. Check Firestore Console: new appointment document exists
```

---

## Key Files (new)

| Layer | File | Purpose |
|-------|------|---------|
| Domain | `lib/shared/booking/domain/repositories/appointment_repository.dart` | Abstract interface |
| Domain | `lib/customer/booking_flow/domain/use_cases/get_organization_by_slug_use_case.dart` | Slug resolver |
| Domain | `lib/customer/booking_flow/domain/use_cases/get_active_services_use_case.dart` | Service filter |
| Domain | `lib/customer/booking_flow/domain/use_cases/calculate_available_slots_use_case.dart` | Slot algorithm |
| Domain | `lib/customer/booking_flow/domain/use_cases/create_booking_use_case.dart` | Booking creator |
| Data | `lib/shared/booking/data/datasources/firestore_appointment_datasource.dart` | Firestore ops |
| Data | `lib/shared/booking/data/repositories/appointment_repository_impl.dart` | Repo implementation |
| Presentation | `lib/customer/booking_flow/presentation/cubit/organization_landing_cubit.dart` | Landing state |
| Presentation | `lib/customer/booking_flow/presentation/cubit/service_selection_cubit.dart` | Service state |
| Presentation | `lib/customer/booking_flow/presentation/cubit/slot_picker_cubit.dart` | Slot state |
| Presentation | `lib/customer/booking_flow/presentation/cubit/booking_form_cubit.dart` | Form state |
| Presentation | `lib/customer/booking_flow/presentation/pages/organization_landing_page.dart` | Org screen |
| Presentation | `lib/customer/booking_flow/presentation/pages/service_selection_page.dart` | Service screen |
| Presentation | `lib/customer/booking_flow/presentation/pages/slot_picker_page.dart` | Slot screen |
| Presentation | `lib/customer/booking_flow/presentation/pages/booking_form_page.dart` | Form screen |
| Presentation | `lib/customer/booking_flow/presentation/pages/booking_confirmation_page.dart` | Result screen |
| Config | `firestore.rules` | Updated rules |
| Config | `firestore.indexes.json` | New compound index |

## Key Files (modified)

| File | Change |
|------|--------|
| `lib/shared/organization/domain/repositories/organization_repository.dart` | Add `getOrganizationBySlug()` |
| `lib/shared/organization/data/repositories/organization_repository_impl.dart` | Implement `getOrganizationBySlug()` |
| `lib/shared/organization/data/datasources/firestore_organization_datasource.dart` | Add `getBySlug()` |
| `lib/core/router/app_router.dart` | Add `/c/org/:slug` + booking flow routes |
