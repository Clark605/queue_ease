# Sprint 6A: Staff Member Management (Hybrid Approach)

**Status**: 🚧 In Progress (March 17-29, 2026)
**Branch**: `006-staff-management`
**Priority**: Critical for MVP
**Environment**: Development (no data migration, no tests)
**Estimated Effort**: 6-7 days (1 developer) or 4-5 days (2-3 developers in parallel)

---

## Overview

Sprint 6A introduces **multi-staff support** to Queue Ease using a **hybrid architecture** that balances feature completeness with minimal disruption. Staff members become first-class entities with one-to-many service assignments, while maintaining a single organization-wide queue with enhanced filtering.

### Key Features

✅ **Staff Member CRUD**: Full admin management of staff profiles (name, role, phone, email, active status)
✅ **Service-Staff Assignment**: Each service assigned to exactly one staff member (one-to-many specialization)
✅ **Transparent Customer Booking**: Staff assignment inherited automatically from service selection
✅ **Enhanced Queue Management**: Staff column display + filtering dropdown (not separate queues)
✅ **Data Migration**: Safe migration of existing services and appointments to include staffId

---

## Architecture Approach: Hybrid Model

### What We're Doing ✅
- **Single Queue Model**: Organization-wide queue showing all appointments
- **Staff Filtering**: Client-side filtering by staff member in queue UI
- **One-to-Many Assignment**: Each service → one staff, each staff → many services
- **Transparent to Customer**: Staff selection automatic based on service choice

### What We're NOT Doing (Deferred to v1.1) ❌
- ~~Separate queues per staff member~~
- ~~Parallel serving (multiple customers "serving" simultaneously)~~
- ~~Staff-specific working hours~~
- ~~Customer staff preferences (explicit staff selection during booking)~~

---

## Document Structure

- **`spec.md`**: Full feature specification with user stories, requirements, edge cases
- **`tasks.md`**: Detailed task breakdown (86 tasks across 12 phases)
- **`quickstart.md`**: Implementation guide with code examples and testing checklist
- **`README.md`**: This file — overview and navigation

---

## Quick Navigation

### For Implementers
👉 Start here: [`quickstart.md`](./quickstart.md)
- Phase-by-phase implementation guide
- Code snippets and examples
- Testing checklist
- Common pitfalls and solutions

### For Architects/Reviewers
👉 Start here: [`spec.md`](./spec.md)
- Full functional requirements
- User stories with acceptance criteria
- Architecture impact analysis
- Success metrics

### For Project Managers
👉 Start here: [`tasks.md`](./tasks.md)
- 57 detailed tasks with file paths (streamlined from 86)
- Phase dependencies and critical path
- Parallel execution opportunities
- Estimated timeline (6-7 days, development mode)

---

## Key Design Decisions

### Decision 1: Hybrid Queue Model (Single Queue + Filtering)
**Rationale**: Balances feature need (staff visibility) with implementation complexity. Separate queues would require:
- Complete queue system refactor (10+ files)
- New QueueEntity structure (per-staff queue IDs)
- Parallel serving logic
- Additional 2-3 weeks development time

**Trade-off**: Admin sees unified queue with staff filter, not separate tabs. Acceptable for MVP.

### Decision 2: One-to-Many Staff-Service Assignment
**Rationale**: Matches business model where each service has a specialist. Simpler than many-to-many matrix.

**Alternative Considered**: Many-to-many (staff A and B both offer service X) — deferred to v1.1.

### Decision 3: Transparent Customer Experience
**Rationale**: Reduces booking friction. Most customers care about service, not staff (until they build preferences).

**Future Enhancement**: v1.1 will add optional staff selection during booking for returning customers.

### Decision 4: Breaking Changes with Migration Script
**Rationale**: Adding required `staffId` fields to existing entities is unavoidable. Mitigated by:
- Comprehensive migration script with idempotency
- Backup strategy before deployment
- Rollback plan if migration fails

---

## Impact Summary

### High Impact (Breaking Changes)
- **ServiceEntity**: Add required `staffId`, optional `staffName`
- **AppointmentEntity**: Add required `staffId`, optional `staffName`
- **Service Form**: Must select staff before save (validation)
- **Appointment Creation**: Inherit staffId from service

### Moderate Impact (New Features)
- **StaffMemberEntity**: Complete new entity with Firestore subcollection
- **Staff Management UI**: New admin feature under settings
- **Queue UI**: Staff column + filter dropdown

### Low Impact (Enhancements)
- **Customer Booking**: No UI changes, only backend data population
- **Firestore Rules**: Add staff subcollection permissions

---

## Success Criteria

Sprint 6A is complete when:

- [ ] All 57 tasks checked off in `tasks.md`
- [ ] `flutter analyze` clean (zero warnings/errors)
- [ ] E2E manual test passes: create staff → assign to service → customer books → queue shows staff → filtering works
- [ ] Firestore security rules deployed to dev environment
- [ ] Code review approved
- [ ] PR `006-staff-management` merged to `main`

---

## Timeline

**Sprint 6A Start**: March 17, 2026
**Sprint 6A End**: March 24, 2026 (target - streamlined)
**Sprint 7 Start**: March 25, 2026 (Notifications & Polish)

### Critical Path (6-7 days, development mode)
```
Phase 1 (Setup) → Phase 2 (Breaking Changes) → Phase 3 (Repository) →
Phase 4 (Use Cases) → Phase 5 (Staff UI) → Phase 6 (Service Updates) →
Phase 7 (Appointment Updates) → Phase 8 (Queue UI) → Phase 11 (Polish)
```

### Parallel Opportunities
- Phase 5 (Staff UI) and Phase 10 (Rules) can run in parallel
- Phase 6 (Service Updates) and Phase 7 (Appointment Updates) can overlap
- Phase 8 (Queue UI) and Phase 9 (Customer Flow) can run in parallel

---

## Risks & Mitigations

### Risk 1: Breaking Changes Impact
**Impact**: High — new services/appointments require staffId field
**Mitigation**:
- Development mode allows fresh data creation
- Firestore rules will reject invalid writes
- Manual testing covers all CRUD operations

### Risk 2: Booking Flow Breaks
**Impact**: Critical — customers cannot book appointments
**Mitigation**:
- Manual E2E test before merging PR
- Staff assignment populated at booking time
- Verify staffId in Firestore after booking

### Risk 3: Queue Actions Fail After Filtering
**Impact**: Moderate — admin cannot progress queue
**Mitigation**:
- Ensure queue actions operate on full queue, not filtered subset
- Test all queue actions (next, skip, no-show, rejoin) with staff filter active

### Risk 4: Timeline Slippage
**Impact**: Moderate — delays Sprint 7 (Notifications)
**Mitigation**:
- Parallel execution where possible (2-3 developers)
- Streamlined task list (57 vs 86 original)
- No testing overhead during development

---

## Post-MVP Enhancements (v1.1)

Once Sprint 6A is stable, consider these future enhancements:

1. **Separate Queues Per Staff**: Each staff member has independent queue with parallel serving
2. **Staff Working Hours**: Each staff configures their own weekly availability
3. **Customer Staff Preferences**: Customers can select preferred staff during booking
4. **Staff Performance Analytics**: Dashboard showing appointments served, average times
5. **Staff Notifications**: Push notifications to staff when their turn approaches

---

## Questions or Issues?

- **Spec Clarifications**: Review [`spec.md`](./spec.md) acceptance scenarios
- **Implementation Help**: Check [`quickstart.md`](./quickstart.md) code examples
- **Task Assignments**: See [`tasks.md`](./tasks.md) for detailed breakdowns
- **Progress Tracking**: Update task checkboxes in `tasks.md` as you complete them

---

**Document Status**: Ready for Implementation
**Created**: March 17, 2026
**Last Updated**: March 17, 2026
**Owner**: Queue Ease Development Team
