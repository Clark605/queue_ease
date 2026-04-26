# Sprint 6A Quickstart Guide: Staff Member Management (Development Mode)

**Branch**: `006-staff-management`
**Status**: In Progress (March 17-24, 2026)
**Approach**: Hybrid — Add staff members with single-queue filtering (not separate queues)
**Environment**: Development (no data migration, no tests for faster iteration)

---

## 🎯 Sprint Goals

1. **Add StaffMemberEntity**: New first-class entity with full CRUD operations
2. **Service-Staff Assignment**: Each service assigned to exactly one staff member (one-to-many)
3. **Transparent Customer Experience**: Staff assignment inherited automatically from service
4. **Enhanced Admin Queue View**: Show staff assignments, add filtering capability
5. **Data Migration**: Safely migrate existing services and appointments to have valid staffId

---

## 📋 Pre-Implementation Checklist

Before starting Phase 1, ensure:

- [ ] Sprint 5 (Queue System) is complete and stable
- [ ] Sprint 6/7 (Business Automation) is complete and merged to main
- [ ] Current branch is `main` with latest changes pulled
- [ ] All existing tests pass (`flutter test`)
- [ ] Firestore dev environment is accessible
- [ ] No breaking changes pending in other branches

---

## 🚀 Quick Start

### Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b 006-staff-management
```

### Phase 1: Domain Foundation (Day 1)

**Goal**: Create StaffMemberEntity and StaffMemberModel.

```bash
# Create directory structure
mkdir -p lib/features/admin/staff_management/{data/{datasources,repositories},domain/{repositories,use_cases},presentation/{cubit,pages,widgets}}

# Create entity (T003)
# Path: lib/features/shared_domain/entities/staff_member_entity.dart
```

**StaffMemberEntity Structure**:
```dart
class StaffMemberEntity extends Equatable {
  const StaffMemberEntity({
    required this.id,
    required this.orgId,
    required this.name,
    this.role,
    this.phone,
    this.email,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String orgId;
  final String name;       // required
  final String? role;      // optional (e.g., "Barber", "Stylist")
  final String? phone;     // optional
  final String? email;     // optional
  final bool isActive;     // default true
  final DateTime createdAt;

  // copyWith, props, ==, hashCode
}
```

**Key Validations**:
- `name`: Required, non-empty, max 100 chars
- `role`: Optional, max 50 chars
- `phone`: Optional, valid phone format
- `email`: Optional, valid email format
- Staff cannot be deleted if services assigned

---

### Phase 2: Breaking Changes (Day 2-3)

**Goal**: Add `staffId` and `staffName` to ServiceEntity and AppointmentEntity.

#### ServiceEntity Update (T007)

```dart
class ServiceEntity extends Equatable {
  // ... existing fields
  final String staffId;        // NEW - required
  final String? staffName;     // NEW - optional, denormalized
}
```

**Migration Impact**: All existing services will need `staffId` populated via migration script.

#### AppointmentEntity Update (T009)

```dart
class AppointmentEntity extends Equatable {
  // ... existing fields
  final String staffId;        // NEW - required
  final String? staffName;     // NEW - optional, denormalized
}
```

**Migration Impact**: All existing appointments will need `staffId` populated via migration script.

---

### Phase 3-4: Repository & Use Cases (Day 4-5)

**StaffRepository Interface** (T015):
```dart
abstract class StaffRepository {
  Stream<Result<List<StaffMemberEntity>>> watchStaffMembers(String orgId);
  Future<Result<StaffMemberEntity>> getStaffMemberById(String orgId, String staffId);
  Future<Result<void>> createStaffMember(StaffMemberEntity staff);
  Future<Result<void>> updateStaffMember(StaffMemberEntity staff);
  Future<Result<void>> deleteStaffMember(String orgId, String staffId);
}
```

**Key Use Cases**:
- `CreateStaffMemberUseCase`: Validates name, creates with `isActive = true`
- `UpdateStaffMemberUseCase`: Allows editing all fields except id, orgId, createdAt
- `DeleteStaffMemberUseCase`: **Blocks deletion if services assigned**, checks service count first
- `WatchStaffMembersUseCase`: Real-time stream for staff list
- `GetStaffMemberByIdUseCase`: Fetch single staff for editing

---

### Phase 5: Staff Management UI (Day 6-7)

**Route**: `/a/staff`

**Pages**:
1. **StaffManagementPage**: List view with search/filter, FloatingActionButton "Add Staff"
2. **StaffFormPage**: Create/edit form with name (required), role, phone, email, active toggle

**Widgets**:
- `StaffCard`: Card showing name, role, active badge, service count, edit/delete actions
- `StaffEmptyState`: "No staff members yet. Add your first staff member to get started."
- `StaffDeletionDialog`: Warning dialog if staff has assigned services

**Cubit States**:
```dart
sealed class StaffManagementState extends Equatable { ... }
final class StaffManagementInitial
final class StaffManagementLoading
final class StaffManagementLoaded { final List<StaffMemberEntity> staff; }
final class StaffManagementError { final String message; }
```

---

### Phase 6: Service Form Updates (Day 8)

**Add Staff Dropdown to ServiceFormPage** (T037):

```dart
// In service form
DropdownButtonFormField<String>(
  decoration: InputDecoration(labelText: 'Assigned Staff Member'),
  items: state.staffMembers.map((staff) => DropdownMenuItem(
    value: staff.id,
    child: Text(staff.name),
  )).toList(),
  validator: (value) => value == null ? 'Staff member is required' : null,
  onChanged: (staffId) => cubit.setStaffMember(staffId),
)
```

**Validation**: Service form must have `staffId` selected before save.

---

### Phase 7: Appointment Updates (Day 9)

**BookingFormCubit.createAppointment()** (T043):

Before creating appointment, fetch service's staffId:
```dart
final service = await _serviceRepository.getServiceById(serviceId);
final appointment = AppointmentEntity(
  // ... other fields
  staffId: service.staffId,
  staffName: service.staffName,
);
```

**No Customer UI Changes**: Customer never sees staff selection, it's inherited transparently.

---

### Phase 8: Queue Staff Filtering (Day 10-11)

**Queue UI Enhancements**:

1. **Display Staff Name** in each queue entry card (T050):
   ```dart
   Row(
     children: [
       Text(entry.customerName, style: bold),
       SizedBox(width: 8),
       Container(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
         decoration: BoxDecoration(
           color: AppColors.primary.withOpacity(0.1),
           borderRadius: BorderRadius.circular(4),
         ),
         child: Text(entry.staffName ?? 'Unknown', style: small),
       ),
     ],
   )
   ```

2. **Add Staff Filter Dropdown** at top of queue page (T054-T055):
   ```dart
   DropdownButton<String?>(
     value: state.selectedStaffId,
     items: [
       DropdownMenuItem(value: null, child: Text('All Staff')),
       ...state.staffMembers.map((staff) => DropdownMenuItem(
         value: staff.id,
         child: Text(staff.name),
       )),
     ],
     onChanged: (staffId) => cubit.filterByStaff(staffId),
   )
   ```

3. **Client-Side Filtering Logic** in cubit (T053):
   ```dart
   void filterByStaff(String? staffId) {
     emit(state.copyWith(selectedStaffId: staffId));
     // Queue list automatically filters entries where entry.staffId == selectedStaffId
   }
   ```

**Important**: Filtering is **client-side only**, does not change Firestore queries. Queue generation remains organization-wide.

---

### Phase 10: Firestore Security Rules (Day 12)

**Add Staff Subcollection Rules** (T062):

```javascript
match /organizations/{orgId}/staff/{staffId} {
  // Allow admin to read all staff in their org
  allow read: if isAdmin(request.auth.uid, orgId);

  // Allow admin to create/update staff
  allow create, update: if isAdmin(request.auth.uid, orgId)
    && request.resource.data.name is string
    && request.resource.data.name.size() > 0
    && request.resource.data.isActive is bool
    && request.resource.data.orgId == orgId;

  // Allow admin to delete staff (service check done client-side)
  allow delete: if isAdmin(request.auth.uid, orgId);
}
```

**Update Service Validation** (T063):
```javascript
// In service document rules
allow create, update: if isAdmin(request.auth.uid, orgId)
  && request.resource.data.staffId is string
  && request.resource.data.staffId.size() > 0;
```

**Update Appointment Validation** (T064):
```javascript
// In appointment document rules
allow create: if isCustomer(request.auth.uid)
  && request.resource.data.staffId is string
  && request.resource.data.staffId.size() > 0;
```

**Deploy Rules**:
```bash
# Dev environment
firebase deploy --only firestore:rules --project ease-queue-dev

# Prod environment (after testing on dev)
firebase deploy --only firestore:rules --project ease-queue
```

---

### Phase 11: Data Migration Script (Day 13-14) ⚠️ CRITICAL

**Script Location**: `scripts/migrate_to_staff_model.ts`

**Execution Steps**:

1. **Backup Firestore Data**:
   ```bash
   gcloud firestore export gs://ease-queue-backups/2026-03-17
   ```

2. **Test on Dev Environment First**:
   ```bash
   npm install firebase-admin
   node scripts/migrate_to_staff_model.ts --project=ease-queue-dev --orgId=TEST_ORG_ID
   ```

3. **Validate Migration**:
   ```bash
   # Check that all services have staffId
   # Check that all appointments have staffId
   # Verify booking flow still works
   ```

4. **Run on Production** (per organization, monitored):
   ```bash
   node scripts/migrate_to_staff_model.ts --project=ease-queue --orgId=REAL_ORG_ID
   ```

**Migration Logic** (Pseudocode):
```typescript
// 1. Check if org has any staff
// 2. If none, create default staff "{OrgName} Staff"
// 3. Update all services missing staffId to default staff
// 4. Update all appointments missing staffId by looking up service
// 5. Log all changes, ensure idempotency
```

**Rollback Plan**: If migration fails, restore from backup and investigate errors before retrying.

---

## ✅ Manual Testing Checklist (Development Mode)

### E2E Smoke Test
- [ ] Create staff "Jane Doe"
- [ ] Create service "Consultation" assigned to Jane
- [ ] Customer books appointment for Consultation
- [ ] Verify appointment.staffId == Jane's ID in Firestore
- [ ] Admin opens queue, sees Jane's name on appointment
- [ ] Admin filters by Jane, sees only her appointments
- [ ] Admin clears filter, sees all appointments

### Admin Staff Management
- [ ] Create staff member with name, role, phone
- [ ] Edit staff member details
- [ ] Mark staff inactive/active
- [ ] Attempt to delete staff with assigned services (blocked)
- [ ] Delete staff with no services

### Service Assignment
- [ ] Create new service and assign to staff
- [ ] Edit existing service to change staff assignment
- [ ] View service list showing staff names

### Customer Booking
- [ ] Customer selects service and books
- [ ] Services with inactive staff are hidden
- [ ] Appointment has correct staffId in Firestore

---

## 🚨 Common Pitfalls & Solutions

### Pitfall 1: Null staffId in New Appointments
**Problem**: Booking flow creates appointments without staffId.
**Solution**: Ensure BookingFormCubit fetches service's staffId BEFORE creating appointment (Phase 7).

### Pitfall 2: Queue Actions Break After Filtering
**Problem**: Admin filters by staff, then "next" action fails.
**Solution**: Queue actions should operate on full queue, not filtered view. Filtering is UI-only.

### Pitfall 3: Firestore Rules Reject Valid Writes
**Problem**: Rules deny service creation because staffId is missing/invalid.
**Solution**: Test rules on dev environment after deployment.

### Pitfall 4: Breaking Entity Changes
**Problem**: Existing code breaks after adding required staffId fields.
**Solution**: Update all entity constructors systematically, regenerate DI, run `flutter analyze`.

---

## 📊 Success Metrics (Development Mode)

- [ ] All 57 tasks completed
- [ ] Zero breaking errors in booking flow
- [ ] Zero breaking errors in queue management
- [ ] Staff filtering applies in < 100ms
- [ ] `flutter analyze` clean
- [ ] Code review approved
- [ ] PR merged to main

---

## 🔄 Deployment Sequence (Development Mode)

1. **Pre-Deployment**:
   - [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
   - [ ] Run `flutter analyze`
   - [ ] Deploy rules to dev
   - [ ] Execute manual smoke test

2. **Deployment**:
   - [ ] PR merged to main
   - [ ] Verify app builds successfully

---

## 📚 Key Files Reference

### Entities
- `lib/features/shared_domain/entities/staff_member_entity.dart`
- `lib/features/shared_domain/entities/service_entity.dart` (updated)
- `lib/features/shared_domain/entities/appointment_entity.dart` (updated)

### Models
- `lib/features/shared_domain/models/staff_member_model.dart`
- `lib/features/shared_domain/models/service_model.dart` (updated)
- `lib/features/shared_domain/models/appointment_model.dart` (updated)

### Repositories
- `lib/features/admin/staff_management/data/repositories/staff_repository_impl.dart`
- `lib/features/admin/service_management/data/repositories/service_repository_impl.dart` (updated)
- `lib/features/customer/booking/data/repositories/appointment_repository_impl.dart` (updated)

### UI
- `lib/features/admin/staff_management/presentation/pages/staff_management_page.dart`
- `lib/features/admin/service_management/presentation/pages/service_form_page.dart` (updated)
- `lib/features/admin/queue_management/presentation/pages/queue_management_page.dart` (updated)

### Rules
- `firestore.rules` (updated)

---

## 🎓 Learning Resources

- **Firestore Subcollections**: https://firebase.google.com/docs/firestore/data-model#subcollections
- **Data Migration Best Practices**: https://firebase.google.com/docs/firestore/manage-data/move-data
- **Flutter Dropdown Forms**: https://api.flutter.dev/flutter/material/DropdownButtonFormField-class.html

---

**Document Status**: Ready for Implementation
**Next Action**: Start Phase 1 (T001-T006) — Create feature branch and domain foundation
