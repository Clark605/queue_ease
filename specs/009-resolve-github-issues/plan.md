# Implementation Plan: Resolve GitHub Issues

**Branch**: `009-resolve-github-issues` | **Date**: 2026-05-28 | **Spec**: [specs/009-resolve-github-issues/spec.md](specs/009-resolve-github-issues/spec.md)
**Input**: Feature specification from `/specs/009-resolve-github-issues/spec.md`

## Summary

Resolve the 16 currently open issues that were fetched from GitHub, starting with the 3 critical blockers (issues #17-19), then the high-impact flow and rules regressions, then the remaining medium and low backlog items. The implementation approach is to triage by subsystem, keep each P1 fix in its own PR, batch related P2/P3 fixes only when they touch the same code path, and validate each change with targeted automated tests plus the existing Firestore rules suite.

## Backlog Snapshot

- Total open issues fetched: 16
- P1 candidates: #17, #18, #19
- P2 candidates: #20, #21, #22, #30, #31, #32
- P3 candidates: #23, #24, #25, #26, #27, #28, #29
- The repository currently uses the misspelled label `crititcal` for the critical bucket, so triage should use the actual label spelling when searching or syncing issues.

## Technical Context

**Language/Version**: Dart 3.9 / Flutter 3.9  
**Primary Dependencies**: flutter_bloc (Cubit), GetIt, Firebase Auth, cloud_firestore, GoRouter, bloc_test, flutter_test, integration_test  
**Storage**: Firestore and Firestore security rules  
**Testing**: unit tests, widget tests, Firestore rules tests, existing Flutter test suite  
**Target Platform**: Flutter mobile app (Android/iOS) with Firebase backend
**Project Type**: mobile-app  
**Performance Goals**: keep queue loading responsive, avoid Firestore `whereIn` over-limit crashes, keep timer-driven UI updates accurate and predictable  
**Constraints**: Clean Architecture, Cubit-only presentation state, no direct Firebase from UI, no new dependency unless proven necessary, P1 issues stay separate PRs  
**Scale/Scope**: 16 open issues across admin, customer, shared domain, and Firestore rules

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Clean Architecture is preserved by keeping repository and use-case fixes in domain/data and UI fixes in presentation.
- The existing feature-first layout under `lib/features/` remains the organization model.
- Flutter and Dart work continues to use the repository's existing MCP and test tooling; no new package is required for the first pass.
- Testing remains risk-based: unit tests for domain and repository logic, widget tests for timer and cancel affordances, Firestore rules tests for rule changes.
- No constitution violations require justification.

## Project Structure

### Documentation (this feature)

```text
specs/009-resolve-github-issues/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
└── features/
    ├── admin/
    │   └── queue_management/
    │       └── data/repositories/admin_queue_repository_impl.dart
    ├── customer/
    │   ├── access_portal/
    │   │   └── domain/use_cases/parse_access_url_use_case.dart
    │   ├── booking/
    │   │   ├── domain/use_cases/calculate_available_slots_use_case.dart
    │   │   └── domain/use_cases/cancel_appointment_use_case.dart
    │   └── entry/
    │       ├── presentation/pages/customer_home_page.dart
    │       └── presentation/widgets/wait_timer_countdown.dart
firestore.rules

test/
├── admin/
├── customer/
├── firestore_rules/
└── shared/
```

**Structure Decision**: Use the existing feature-first Flutter layout and the existing Firestore rules/test folders. No new top-level application module is required. The planning docs live under `specs/009-resolve-github-issues/`, and any workflow contract lives under `specs/009-resolve-github-issues/contracts/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

None. No constitution violations are introduced by this plan.
