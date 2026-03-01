# Implementation Plan: Admin Core — Organization Setup & Service Management

**Branch**: `001-admin-core` | **Date**: March 1, 2026 | **Spec**: [spec.md](spec.md)

## Summary

Enable admin sign-up to automatically create an Organization record and link it to the user profile (replacing the `orgName` text field with an `organizationId` reference). Implement real-time OrganizationRepository and ServiceRepository. Build admin UI for organization profile management and full service CRUD. Add a router guard that redirects admins with no linked organization to a dedicated "Complete Your Setup" screen. Add a first-time tutorial that guides new admins through the three setup steps and persists completion state in Firestore.

## Technical Context

**Language/Version**: Dart 3.9+, Flutter 3.9+ (stable channel)
**Primary Dependencies**: flutter_bloc (Cubit), GetIt + Injectable, GoRouter 17.1.0, Cloud Firestore, Firebase Auth, Equatable, Talker
**Storage**: Firebase Firestore — `users/{uid}`, `organizations/{orgId}`, `organizations/{orgId}/services/{serviceId}`
**Testing**: Deferred to Sprint 8 (team decision — see Constitution Check)
**Target Platform**: Android (primary), iOS (secondary)
**Project Type**: Mobile app (Flutter — Clean Architecture, feature-based modules)
**Performance Goals**: Firestore writes acknowledged <2s; real-time stream propagation <500ms; screen navigation <300ms; 60fps animations
**Constraints**: No tests in this sprint; no multi-org per admin; Google Sign-In path not modified; existing security rules already deployed cover all collections
**Scale/Scope**: Single-org per admin, small-clinic scale; ~6 new screens, ~2 new repository interfaces, ~4 new Firestore datasource classes

## Constitution Check

*GATE: Must pass before research. Re-evaluated after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Code Quality First (Clean Architecture, SOLID, Result\<T\>, domain purity) | ✅ PASS | All repo interfaces in domain layer; no Firebase in domain; Result\<T\> on all async ops; Equatable on all entities |
| II | Flexibility & Extensibility (feature modules, DI, env configs) | ✅ PASS | New feature modules under `admin/organization/` and `admin/tutorial/`; all deps registered via Injectable |
| III | Testing Standards (TDD, 80%/70% coverage) | ⚠️ JUSTIFIED DEVIATION | Tests deferred to Sprint 8 by explicit team decision documented in spec Assumptions. See Complexity Tracking. |
| IV | UX Consistency (Material 3, loading/error/success states, accessibility, offline-first) | ✅ PASS | All screens must provide loading, error, and success states; Semantics labels required; 8px grid |
| V | Fast Delivery (MVP mindset, P1 first, 3-day cycles) | ✅ PASS | P1 (sign-up + org creation) implemented first; P2 (profile) second; P3 (services) third; P4 (tutorial) last |
| VI | Performance Requirements (real-time ops, 60fps, <3s startup) | ✅ PASS | Real-time Firestore streams for org profile and service list; cached-first reads |

**Post-Phase-1 re-check**: ✅ No new violations introduced by design. Data model aligns with existing Firestore schema and security rules.

## Project Structure

### Documentation (this feature)

```text
specs/001-admin-core/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/
│   ├── organization-repository.md   ← Phase 1 output
│   └── service-repository.md        ← Phase 1 output
└── tasks.md             ← Phase 2 output (/speckit.tasks — not created here)
```

### Source Code

```text
lib/
├── shared/
│   ├── auth/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── user_entity.dart              [MODIFIED] orgName → organizationId
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── firestore_user_datasource.dart [MODIFIED] orgName → organizationId
│   │       └── repositories/
│   │           └── auth_repository_impl.dart      [MODIFIED] pass organizationId; trigger org creation
│   │
│   └── organization/
│       ├── domain/
│       │   ├── entities/                          (existing — no changes)
│       │   └── repositories/                      [NEW]
│       │       ├── organization_repository.dart
│       │       └── service_repository.dart
│       └── data/
│           ├── models/                            (existing — no changes)
│           ├── datasources/                       [NEW]
│           │   ├── firestore_organization_datasource.dart
│           │   └── firestore_service_datasource.dart
│           └── repositories/                      [NEW]
│               ├── organization_repository_impl.dart
│               └── service_repository_impl.dart
│
└── admin/
    ├── organization/                              [NEW feature module]
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── organization_cubit.dart
    │       │   └── organization_state.dart
    │       ├── pages/
    │       │   ├── organization_setup_page.dart   ← "Complete Your Setup" screen
    │       │   ├── organization_profile_page.dart
    │       │   └── organization_profile_edit_page.dart
    │       └── widgets/
    │           └── organization_profile_form.dart
    │
    ├── services/                                  [EXISTING skeleton → IMPLEMENT]
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── service_cubit.dart
    │       │   └── service_state.dart
    │       ├── pages/
    │       │   ├── service_list_page.dart
    │       │   └── service_form_page.dart
    │       └── widgets/
    │           └── service_list_tile.dart
    │
    └── tutorial/                                  [NEW feature module]
        └── presentation/
            ├── cubit/
            │   ├── tutorial_cubit.dart
            │   └── tutorial_state.dart
            └── widgets/
                └── tutorial_overlay.dart

core/
└── app/
    └── router/
        └── app_router.dart                        [MODIFIED] new routes + missing-org guard
```

**Structure Decision**: Feature-based modules under `admin/` for UI concerns; domain contracts and data implementations under `shared/organization/` (role-agnostic, reusable in Sprint 4 customer booking). Follows existing auth feature pattern exactly.

## Complexity Tracking

> **Constitution Check violation — Principle III (Testing Standards)**

**Violation**: TDD and test coverage requirements not met in this sprint.  
**Justification**: Explicit team decision captured in spec.md Assumptions section: "No tests are written in this sprint (deferred to Sprint 8 per team decision)." The project is in active MVP development phase (5–6 weeks remaining). Sprint 8 is dedicated entirely to testing and will cover all deferred code.  
**Risk**: Regression risk during integration of subsequent sprints.  
**Mitigation**: All new classes follow Clean Architecture (dependency-injectable, interface-driven) so tests can be added in Sprint 8 without refactoring. No logic is embedded in widgets or datasources that would be difficult to unit-test retroactively.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
