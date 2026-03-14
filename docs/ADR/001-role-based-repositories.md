# ADR 001: Role-Based Feature Repositories

**Status**: Accepted  
**Date**: 2026-03-12  
**Deciders**: Development Team  
**Context**: Architecture Migration Plan

---

## Context and Problem Statement

The current architecture splits repository responsibilities inconsistently:

- **Problem 1**: `shared/organization/domain/repositories/organization_repository.dart` contains methods used ONLY by admin (`getOrganizationByAdminUid`) and ONLY by customer (`getOrganizationBySlug`), despite being in a "shared" folder.

- **Problem 2**: Admin features inject TWO repositories for a single domain concept:
  ```dart
  class OrganizationCubit {
    final OrganizationRepository _organizationRepository;        // for reads
    final AdminOrganizationRepository _adminOrganizationRepository; // for writes
  }
  ```

- **Problem 3**: Unclear ownership—when adding new methods, developers are confused about where they belong (shared vs. role-specific).

- **Problem 4**: The read/write split pattern (CQRS-lite) was never formalized, creating a pseudo-architecture that fails to deliver CQRS benefits while introducing cognitive overhead.

**Decision Driver**: As the app scales with more features (Sprint 5: Queue Management, Sprint 6+: Analytics), this inconsistency will compound technical debt and slow development.

---

## Decision

We will adopt **Role-Based Feature Repositories** (Option 2 from architectural analysis):

### Principles

1. **Each role owns complete repositories** with ALL operations that role performs (read + write)
2. **Entities remain shared** in `features/shared_domain/entities/` (pure data classes, no behavior)
3. **Repository ownership by primary actor**:
   - `AdminOrganizationRepository` → all admin operations on organizations
   - `CustomerOrganizationRepository` → all customer operations on organizations
4. **Single repository injection** per feature eliminates dual injection confusion
5. **Repository interface mirrors role permissions** in the domain layer

### New Structure

```
lib/features/
├── shared_domain/
│   ├── entities/           # Pure domain entities (OrganizationEntity, ServiceEntity, etc.)
│   └── models/             # DTOs for Firestore serialization
│
├── authentication/         # Truly shared feature (both roles use identically)
│   ├── data/
│   ├── domain/
│   └── presentation/
│
├── admin/
│   ├── organization_management/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── admin_organization_datasource.dart  # ALL Firestore ops
│   │   │   └── repositories/
│   │   │       └── admin_organization_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── admin_organization_repository.dart  # ALL admin methods
│   │   └── presentation/
│   ├── service_management/
│   ├── working_hours_management/
│   └── dashboard/
│
└── customer/
    └── booking/
        ├── data/
        │   ├── datasources/
        │   │   ├── customer_organization_datasource.dart  # Read-only queries
        │   │   ├── customer_service_datasource.dart
        │   │   ├── customer_working_hours_datasource.dart
        │   │   └── customer_appointment_datasource.dart
        │   └── repositories/
        │       ├── customer_organization_repository_impl.dart
        │       ├── customer_service_repository_impl.dart
        │       ├── customer_working_hours_repository_impl.dart
        │       └── customer_appointment_repository_impl.dart
        ├── domain/
        │   └── repositories/
        │       ├── customer_organization_repository.dart  # getBySlug, watch
        │       ├── customer_service_repository.dart       # watchServices
        │       ├── customer_working_hours_repository.dart # watchWorkingHours
        │       └── customer_appointment_repository.dart   # create, getForDate
        └── presentation/
```

---

## Considered Alternatives

### Alternative 1: CQRS-Inspired (Command-Query Responsibility Segregation)

Split by operation type (query vs. command) across both roles:

```dart
abstract class OrganizationQueryRepository {
  Stream<OrganizationEntity> watchOrganization(String orgId);
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(String uid);
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug);
}

abstract class OrganizationCommandRepository {
  Future<Result<OrganizationEntity>> createOrganization({...});
  Future<Result<void>> updateOrganization(OrganizationEntity org);
}
```

**Pros**:
- Industry-standard pattern for complex domains
- Scales well if we add read replicas or event sourcing later
- Clear separation of concerns at operation level

**Cons**:
- Overkill for current CRUD operations
- Still requires dual injection (query + command repos)
- Added complexity without immediate benefit
- Team unfamiliar with CQRS patterns

**Rejected because**: We have simple CRUD, not complex domain logic requiring CQRS. The pattern introduces complexity without solving our actual problem (unclear role boundaries).

---

### Alternative 2: Keep Current Split (Status Quo)

Maintain read/write separation between `shared/` and `admin/`:

**Pros**:
- No migration cost
- Developers familiar with current structure

**Cons**:
- Problem persists: methods in "shared" are role-specific
- Dual injection remains confusing
- Architectural debt compounds with each new feature
- No clear rule for where new methods belong

**Rejected because**: This is the problem we're solving. Deferring the migration increases future cost.

---

### Alternative 3: Single Monolithic Repository per Domain

One repository per domain entity with all operations for all roles:

```dart
abstract class OrganizationRepository {
  // Admin methods:
  Stream<OrganizationEntity> watchOrganization(String orgId);
  Future<Result<OrganizationEntity?>> getOrganizationByAdminUid(String uid);
  Future<Result<OrganizationEntity>> createOrganization({...});
  Future<Result<void>> updateOrganization(OrganizationEntity org);
  
  // Customer methods:
  Future<Result<OrganizationEntity?>> getOrganizationBySlug(String slug);
}
```

**Pros**:
- Single repository per domain concept
- No duplication of datasource queries

**Cons**:
- Customer code has access to admin methods (violates least privilege)
- Repository interface doesn't reflect authorization model
- Testing becomes harder (must mock irrelevant methods)
- Breaks Interface Segregation Principle (SOLID)

**Rejected because**: Repository interfaces should model role capabilities. Exposing admin methods to customer code creates security confusion.

---

## Consequences

### Positive

✅ **Clear ownership**: Each role has ONE repository per domain concept with all relevant operations

✅ **Eliminates dual injection**: Admin features inject `AdminOrganizationRepository`, not two separate repos

✅ **Better permission modeling**: Repository interface = role permissions in the domain

✅ **Easier reasoning**: "I'm building admin feature X" → "Use admin repositories"

✅ **Testability**: Each role's tests mock only the methods that role uses

✅ **Scalability**: Adding Sprint 5 queue management is clear: admin updates appointment status, customer views queue

### Negative

⚠️ **Datasource duplication**: Some Firestore queries duplicated between admin/customer datasources
- **Mitigation**: Acceptable trade-off; queries are simple, duplication prevents coupling

⚠️ **Migration cost**: 2-3 weeks of refactoring across 7 phases
- **Mitigation**: Incremental migration with per-phase verification minimizes risk

⚠️ **Bundle size increase**: ~5-10KB due to duplicated queries
- **Mitigation**: Negligible on modern devices; monitor with `flutter build apk --analyze-size`

⚠️ **Branch conflicts**: In-flight feature branches will conflict with migration changes
- **Mitigation**: Complete migration in dedicated branch, freeze new features during migration (recommended), or accept careful merge coordination

### Neutral

🔄 **No user-facing changes**: This is pure refactoring; all behavior remains identical

🔄 **Testing strategy unchanged**: Unit tests, integration tests, manual QA still required

---

## Implementation Plan

**Timeline**: 13-19 days (2.5-4 weeks) across 8 phases

**Phases**:
1. **Phase 0**: Foundation setup (directory structure, ADR, utilities scaffold)
2. **Phase 1**: Extract shared domain entities (1 day)
3. **Phase 2**: Migrate authentication feature (2 days)
4. **Phase 3**: Migrate organization feature (3-4 days) — **highest complexity**
5. **Phase 4**: Migrate services feature (2-3 days)
6. **Phase 5**: Migrate working hours feature (2 days)
7. **Phase 6**: Migrate booking/appointments (2-3 days)
8. **Phase 7**: Final cleanup, utilities extraction, documentation update (1-2 days)

**Verification Strategy**: Each phase has automated checks (`flutter test`, `flutter analyze`) and manual smoke tests. Full regression suite runs in Phase 7.

---

## Compliance with Engineering Rules

This decision aligns with project engineering principles:

- ✅ **Rule 7: Strict Clean Architecture** — Repositories remain abstractions in domain layer, implementations in data layer
- ✅ **Rule 8: Separation of Concerns** — Each repository owns one business capability for one role
- ✅ **Rule 9: Layer Communication Rules** — Communication via abstract repository contracts (defined rules upheld)
- ✅ **Rule 13: Minimal Surface Changes** — Incremental migration, small verifiable steps
- ✅ **Rule 14: Repository Pattern Consistency** — Establishes ONE consistent pattern project-wide

---

## References

- Architecture Analysis: `/memories/session/plan.md`
- Current Structure Issues: `/memories/repo/queue_ease_structure.md`
- Migration Plan: Phase-by-phase implementation in session memory
- Related Specs: `specs/004-customer-booking-flow/` (current branch context)

---

## Notes

**Migration Branch**: `refactor/role-based-repos` (to be created)  
**Current Branch Context**: `004-customer-booking-flow` — migration will begin after Sprint 4 completion or in parallel with careful coordination

**Approval**: This ADR documents the decision. Implementation proceeds per migration plan with stakeholder approval.
