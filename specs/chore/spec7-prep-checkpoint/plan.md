# Implementation Plan: Fix Demo UI

**Branch**: `008-fix-demo-ui` | **Date**: 2026-04-29 | **Spec**: `specs/008-fix-demo-ui/spec.md`
**Input**: Feature specification from `specs/008-fix-demo-ui/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Fix 7 user stories (4 P1, 3 P2) addressing critical demo UI issues: remove dead UI elements (NowServingCard, _StatsStrip hardcoded values, Daily Summary snackbar, service list search button, queue management filter button, 5 "Coming soon" settings items), enable core user journeys (customer booking cancellation for 'inQueue'/'waiting' statuses, admin date navigation in queue management, fix "See all" → appointments list navigation), add quick open/closed toggle on admin dashboard, fix architecture issues (transactionMarkNoShow validation, AdminWorkingHoursDatasource.saveAll batch.update), optimize WaitTimerCountdown polling, and implement quick wins (consolidate PulsingDot, show orgName on confirmation, fix notification dot, mask Admin ID).

## Technical Context

**Language/Version**: Dart ^3.9.0, Flutter Stable channel
**Primary Dependencies**: Firebase (Auth, Firestore, Crashlytics), flutter_bloc, get_it, injectable, go_router, flutter_dotenv
**Storage**: Cloud Firestore (NoSQL, real-time streams)
**Testing**: flutter_test, bloc_test, mocktail (pragmatic/risk-based per Constitution III)
**Target Platform**: iOS and Android (mobile app)
**Project Type**: mobile-app (Flutter)
**Performance Goals**: 60 fps UI rendering, real-time Firestore stream updates, <1s data refresh on date navigation
**Constraints**: Strict 3-layer Clean Architecture (Domain/Data/Presentation), feature-first organization, sealed AppException hierarchy, Result<T> for async operations
**Scale/Scope**: 7 user stories (4 P1, 3 P2), ~15-20 files to modify across admin and customer features

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Gate Results:
- ✅ **I. Code Quality First**: All fixes will maintain strict layer separation. Customer cancellation requires new use case in domain layer, repository update in data layer, cubit/UI update in presentation layer. Architecture issues (transactionMarkNoShow, AdminWorkingHoursDatasource) are in data layer and will be fixed there.
- ✅ **II. Flexibility & Extensibility**: No new feature folders needed - all fixes apply to existing features (customer/booking, admin/queue_management, admin/dashboard, etc.). Changes are self-contained within respective features.
- ✅ **III. Pragmatic Testing**: Risk-based approach - unit tests for new use cases (customer cancellation), widget tests for UI changes if complex. No blanket test requirement per Constitution III.
- ✅ **IV. User Experience Consistency**: Fixing dead UI elements (NowServingCard, hardcoded _StatsStrip) improves UX consistency. Quick open/closed toggle follows Material Design patterns.
- ✅ **V. Fast Delivery**: 7 focused user stories, all independently testable. P1 stories (cancellation, date navigation, See all fix, toggle) deliver core value first.
- ✅ **VI. Performance Requirements**: WaitTimerCountdown optimization reduces unnecessary polling, improving frame rate and battery life. Real-time Firestore streams already meet <500ms propagation requirement.

**GATE STATUS: PASSED** - No violations detected. All fixes align with Constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
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
│   ├── error/          # AppException, Result<T>
│   ├── router/         # GoRouter with RBAC
│   └── widgets/        # Shared widgets (PulsingDot consolidation)
├── features/
│   ├── admin/
│   │   ├── dashboard/          # Add open/closed toggle (P1)
│   │   ├── queue_management/   # Date navigation (P1), fix filter button
│   │   ├── app_section/        # Settings page - remove "Coming soon" items
│   │   ├── daily_summary/      # Fix snackbar issue
│   │   └── share_access/       # Fix QR scanner navigation (P1)
│   ├── customer/
│   │   ├── booking/            # Add cancellation use case (P1)
│   │   ├── entry/              # Fix "See all" nav, notification dot, confirmation page
│   │   └── home/               # Customer dashboard fixes
│   ├── shared_domain/
│   │   ├── entities/            # AppointmentEntity (add cancelled status)
│   │   └── models/
│   └── authentication/
└── main_dev.dart, main_prod.dart
```

**Structure Decision**: Feature-first Clean Architecture. All fixes apply to existing features. New use case (customer cancellation) will be added to `features/customer/booking/domain/`. Shared widget consolidation (PulsingDot) goes to `core/widgets/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
