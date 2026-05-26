<!--
SYNC IMPACT REPORT - Constitution v2.2.0
Generated: 2026-05-26

VERSION CHANGE: 2.1.0 → 2.2.0
  Rationale: MINOR bump - expanded the Dart MCP tooling discipline to cover
  pub.dev package discovery/search in addition to runtime control, debugging,
  logs, repo search, and dependency management.

PRINCIPLES MODIFIED:
  ✅ VII. Dart MCP Tooling Discipline - Expanded to require pub.dev package
     discovery/search before dependency changes

ADDED SECTIONS:
  None

REMOVED SECTIONS:
  None

TEMPLATE AND DOC UPDATES:
  ✅ .specify/templates/plan-template.md - reviewed; no conflicting workflow
     text required changes
  ✅ .specify/templates/spec-template.md - reviewed; no conflicting scope text
     required changes
  ✅ .specify/templates/tasks-template.md - reviewed; no conflicting task text
     required changes
  ✅ README.md - reviewed; runtime and testing notes remain compatible with the
     constitution amendment

DEFERRED ITEMS:
  None
-->

# Queue Ease Constitution

## Core Principles
 - Follow all rules in [.github/copilot-instructions.md](../../.github/copilot-instructions.md) in addition to the specific principles below
 - Follow all Flutter patterns in the [flutter-patterns skill](c:/Users/Clark/.copilot/skills/flutter-patterns/SKILL.md): [widget patterns](c:/Users/Clark/.copilot/skills/flutter-patterns/patterns/flutter-widget-patterns.md), [testing patterns](c:/Users/Clark/.copilot/skills/flutter-patterns/patterns/flutter-testing-patterns.md), [performance checklist](c:/Users/Clark/.copilot/skills/flutter-patterns/patterns/flutter-performance-checklist.md), [security patterns](c:/Users/Clark/.copilot/skills/flutter-patterns/patterns/flutter-security-patterns.md), and [animation patterns](c:/Users/Clark/.copilot/skills/flutter-patterns/patterns/flutter-animation-patterns.md)
 - This constitution is the supreme authority for all development decisions in Queue Ease. All team members, code reviews, and automated checks MUST verify compliance with these principles.
### I. Code Quality First

All code MUST adhere to Clean Architecture principles with strict layer separation:
- **Domain Layer** MUST be framework-agnostic with zero external dependencies (no Flutter/Firebase imports)
  - Canonical entity definitions live in [docs/domain/ENTITIES.md](../../docs/domain/ENTITIES.md)
  - Repository interfaces define contracts (implementation in data layer)
- **Data Layer** implements domain repository interfaces; never directly accessed by presentation
  - Firestore models handle serialization: `fromDoc()`, `toMap()`, `toEntity()` methods required
  - Round-trip conversion MUST preserve data integrity; validate with tests when the model changes
  - Exception mapping: translate Firebase/platform errors into `AppException` subtypes (sealed hierarchy with 5 final subtypes)
  - Return `Result<T>` from all async operations for explicit error handling
- **Presentation Layer** depends only on domain abstractions via dependency injection
  - Use Cubit pattern (not full BLoC); `bloc_test` is the preferred harness when tests are added
  - UI never imports data layer or Firebase directly
- SOLID principles MUST be followed in all implementations
- Code reviews MUST verify architecture compliance before merge (use Constitution Check in plan templates)
- Dart effective patterns and lint rules (`analysis_options.yaml`) are NON-NEGOTIABLE
  - `prefer_single_quotes: true`, `camel_case_types: true`, exclude generated files (*.g.dart, *.config.dart)

**Rationale**: Clean architecture ensures testability, maintainability, and long-term flexibility. Layer violations create technical debt that compounds exponentially in Flutter projects. The domain entities represent core business concepts that must remain stable as Firebase or UI frameworks evolve. Sealed exception hierarchy enables compile-time exhaustive checking while allowing controlled extension as new error types are discovered during development.

### II. Flexibility & Extensibility

Every feature MUST be self-contained and independently deployable:
- **Feature Organization**: Feature-first structure under `lib/features/`
  - **Admin features**: `organization_management/`, `service_management/`, `working_hours_management/`, `queue_management/`, `daily_summary/`, `dashboard/`, `share_access/`, `tutorial/`, `app_section/`
  - **Customer features**: `booking/`, `entry/`
  - **Authentication**: `authentication/` (shared across roles)
  - **Onboarding**: `onboarding/` (initial user experience)
  - **Shared Domain**: `shared_domain/` (entities and models used across multiple features/roles)
- Each feature follows Clean Architecture with own data/domain/presentation layers (where applicable)
- Shared functionality lives in `lib/core/` (config, theme, widgets, utils, error, router, di, services)
- New features MUST NOT require modifications to existing feature code
- Dependencies managed via abstract interfaces registered with GetIt/Injectable
- Configuration externalized via environment-specific files (dev/prod)
- Feature flags SHOULD be used for gradual rollouts and A/B testing

**Rationale**: Feature-first organization with role-based grouping (admin/customer) enables parallel team development, clear ownership, and easier navigation. Modular design enables easier testing and graceful feature deprecation. The shared_domain feature provides clean access to domain entities across roles without coupling.

### III. Pragmatic Testing

Testing is a validation tool, not a universal merge gate:
- Tests are recommended for high-risk changes, core business logic, regression-prone code, and critical user flows.
- There is no blanket requirement that every change include tests before merge.
- When tests are added, prefer unit tests for domain logic, widget tests for complex UI, and integration tests for critical end-to-end flows.
- Keep assertions specific enough to document behavior and prevent regressions.

**Rationale**: Risk-based testing keeps low-risk or exploratory work moving without
removing the team's ability to add targeted automation where it protects the
product most.

### IV. User Experience Consistency

User interface MUST deliver consistent, accessible experiences across all screens:
- **Design System**: Follow Material Design 3 guidelines with custom Queue Ease theme
  - Primary color: Teal/Blue gradient (professional, trustworthy)
  - Typography: Clear hierarchy with readable font sizes (min 14sp body text)
  - Spacing: Consistent 8px grid system
- **Reusable Widgets** MUST be in `core/widgets/` (app-wide) or `shared/widgets/` (cross-role)
  - Already implemented: `AppErrorWidget`, `AppLoadingIndicator`
  - Planned: `QueuePositionCard`, `ServiceCard`, `TimeSlotPicker`
  - Every reusable widget SHOULD have targeted widget tests when behavior is complex or high-risk
- **State Feedback** MUST provide meaningful user feedback:
  - Loading states: show spinner or skeleton screen (never silent/frozen UI)
  - Error messages: user-friendly with actionable guidance ("Try again", "Check network")
  - Success confirmations: toast or snackbar for actions ("Appointment booked!")
  - No silent failures - every error MUST be visible to user or logged
- **Onboarding Flow** (completed):
  - 3-screen swipeable intro: Skip the Wait, Real-Time Tracking, Fair Turns
  - Skip button (top-right), Next/Get Started buttons
  - Completion persisted via `SharedPreferences` (never show again)
  - Custom illustrations in `assets/images/` folder
- **Navigation Patterns** MUST be predictable:
  - Bottom navigation bar for primary actions (admin: services, queue, settings)
  - AppBar back button for hierarchical navigation
  - GoRouter handles deep linking and role-based routing
- **Accessibility** (WCAG AA standards):
  - All interactive elements MUST have minimum 48x48 tap targets
  - Color contrast ratio ≥4.5:1 for normal text, ≥3:1 for large text
  - Semantic labels for screen readers (use `Semantics` widget)
  - Form validation errors announced to screen readers
- **Animation Standards**: All animations MUST follow these rules:
  - Prefer implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`) over explicit animations when possible
  - Use `AnimatedBuilder` for custom explicit animations; never use raw `addListener` on an `AnimationController`
  - Every `AnimationController` MUST be disposed in `dispose()` to prevent memory leaks
  - Duration guidelines: 200–300ms for micro-interactions, 300–500ms for screen transitions
  - Wrap widgets containing complex animations in `RepaintBoundary` to isolate repaints
  - Use `CurvedAnimation` with appropriate `Curves` constants (e.g., `easeInOut`, `easeOut`)
- **Offline-First Design**: Graceful degradation when network unavailable
  - Firestore cached queries enable offline reads
  - Queue writes when online returns, show "Waiting for connection" indicator
  - Offline banner at top of screen when disconnected
- **Responsive Layouts** MUST work on:
  - Phone: 360x640 (small), 412x915 (pixel-like) - PRIMARY target
  - Tablet: 768x1024 (iPad) - SECONDARY target
  - Web: ≥1024px width - FUTURE (post-MVP)

**Rationale**: Queue Ease serves diverse users (clinic admins, patients of all ages). Consistent UX reduces training costs and appointment booking errors. Accessibility expands market reach and is ethically required. Offline support critical for clinics in areas with spotty connectivity. Real-time queue updates are useless if UI doesn't reflect changes instantly.

### V. Fast Delivery

Development velocity prioritized through iterative, incremental releases:
- **MVP Mindset**: Ship minimum viable features, iterate based on feedback
  - Current status: ~35-40% complete (Phase 1 Foundation done)
  - Timeline: 5-6 weeks remaining to MVP (target: mid-May 2026)
  - 8 phases planned: Foundation (✅), Data Layer, Admin Core, Customer Core, Queue System, Business Logic, Notifications, Testing & Deploy
- **User Stories MUST be prioritized** (P1/P2/P3) and independently testable
  - P1: Critical path for MVP (booking flow, queue generation, real-time updates)
  - P2: Important but deferrable (daily summary, QR code generation)
  - P3: Nice-to-have (advanced analytics, multi-device sync)
  - Each story MUST deliver standalone value even if implemented alone
- **Feature Branches & Merge Frequency**:
  - Feature branches merged to `develop` frequently (max 3-day cycles, ideally daily)
  - Current branch: `develop` (feature/auth recently merged)
  - Naming convention: `feature/###-name`, `hotfix/###-description`
  - Small, focused PRs preferred over large monolithic changes
- **CI/CD Pipeline** MUST run linting and build validation on every commit
  - GitHub Actions or Firebase App Distribution for automated builds
  - Test jobs are optional and only block merge when they are part of the configured pipeline for the change
- **Environment Strategy**:
  - Staging: `main_dev.dart` with test Firebase project for validation
  - Production: `main_prod.dart` with production Firebase project
  - Test data generation scripts for rapid iteration
- **No Gold-Plating**: Implement only specified requirements from PRD
  - Feature creep is the enemy of fast delivery
  - New ideas captured in GitHub Issues for post-MVP evaluation
- **Technical Debt Management**:
  - Track in GitHub Issues with `tech-debt` label
  - Addressed in dedicated sprint quarterly (not during MVP push)
  - Acceptable short-term debt: TODO comments with ticket references

**Rationale**: Small clinics need working software quickly to validate value proposition. Incremental delivery reduces risk and enables course correction. Current 5-6 week MVP target demands disciplined scope control and frequent integration. Waiting for "perfect" code delays market feedback.

### VI. Performance Requirements

Application MUST meet quantifiable performance benchmarks for real-time operations:
- **App Launch**: Cold start <3s, warm start <1s (measured on mid-range Android devices ~$200)
- **Screen Navigation**: <300ms transition time between screens using GoRouter
- **Firebase Operations**:
  - Firestore reads MUST use cached-first strategy (reduce costs and improve offline UX)
  - Writes MUST acknowledge <2s even under poor network conditions
  - Real-time listeners for queue updates: <500ms propagation from server to client
  - Batch operations preferred for multiple writes (queue generation, bulk updates)
- **Memory Usage**: <200MB baseline, <400MB peak during active queue operations with 20+ appointments
- **Frame Rate**: 60fps maintained during animations, scrolling, and real-time queue updates
  - No dropped frames during page transitions or queue position changes
  - Talker logging MUST use lazy evaluation to minimize overhead
- **Widget Composition Rules** (enforced for all UI code):
  - All reusable UI components MUST be `StatelessWidget` or `StatefulWidget` classes — never plain functions returning `Widget`; functions bypass Flutter's element diffing and cause unnecessary rebuilds
  - Maximum widget nesting depth: 4–5 levels before extracting into a named sub-widget class
  - Use `RepaintBoundary` to isolate expensive or frequently repainted widgets (e.g., queue position counters, real-time timers)
  - Cache expensive computations outside `build()` — never perform heavy work inside a build method
  - Use `compute()` (isolate) for CPU-intensive operations (e.g., bulk appointment sorting, queue reordering algorithms)
- **Build Size**: APK <50MB, use bundle splits for feature APKs exceeding 10MB
- **Critical Business Logic Performance**:
  - Time margin countdown accuracy: ±5s (countdown starts when customer's turn begins)
  - Auto no-show detection: triggered within 10s of margin expiration
  - Wait time estimation recalculation: <100ms for queue reordering events
- Performance profiling MUST be conducted before production releases using Flutter DevTools
- Talker logging configured for minimal overhead in production (error-level only, no verbose)
- Query optimization: Firestore compound indexes MUST be defined for filtered queries
  - Index appointments by `orgId + scheduledAt` for booking conflict checks
  - Index queues by `orgId + date` for daily queue retrieval

**Rationale**: Real-time queue updates and appointment booking demand high responsiveness. Customers checking queue position expect instant updates. Poor performance erodes trust in critical clinic workflows (no-shows cause cascading delays). Firebase costs scale with inefficient queries, impacting small clinic budgets. Time margin enforcement accuracy directly affects fairness and business operations.

### VII. Dart MCP Tooling Discipline

Flutter and Dart work MUST use the Dart MCP toolchain whenever a supported tool exists; shell commands are fallback only when no tool covers the task.
- Runtime and app control MUST prefer these tools:
  - `mcp_dart_sdk_mcp__connect_dart_tooling_daemon`
  - `mcp_dart_sdk_mcp__create_project`
  - `mcp_dart_sdk_mcp__hot_reload`
  - `mcp_dart_sdk_mcp__hot_restart`
  - `mcp_dart_sdk_mcp__stop_app`
- Debugging and runtime inspection MUST use these tools:
  - `mcp_dart_sdk_mcp__get_runtime_errors`
  - `mcp_dart_sdk_mcp__flutter_driver`
- Pub.dev package operations MUST use `mcp_dart_sdk_mcp__pub` for dependency
  management, including `add`, `get`, `remove`, `upgrade`, `deps`, and
  `outdated`.
- Pub.dev package discovery/search MUST happen before dependency changes by
  checking the package catalog on pub.dev or the closest available discovery
  tool, so package selection is based on current package metadata rather than
  guesswork.
- Repository search MUST use workspace search tools instead of shell search:
  - `semantic_search`
  - `grep_search`
  - `file_search`
- If no MCP tool covers the task, the smallest necessary fallback MAY be used,
  but the gap and fallback reason MUST be stated before proceeding.

## Technical Standards

### Flutter & Dart Requirements

- **Flutter SDK**: ≥3.9.0, follow stable channel releases
- **Dart SDK**: ≥3.9.0, use latest language features (records, patterns, sealed classes)
- **State Management**: flutter_bloc (Cubit pattern) exclusively, never full BLoC
  - Emit immutable states using `copyWith` or sealed class pattern
  - Use `bloc_test` for all Cubit tests (arrange-act-assert)
- **Dependency Injection**: GetIt + Injectable with module-based registration
  - Register repositories as singletons, datasources as lazy singletons
  - Use `@injectable` annotation, run `flutter pub run build_runner build`
- **Navigation**: GoRouter with typed routes and authentication guards
  - `GoRouterRefreshStream` listens to auth state changes for automatic routing
  - Protected routes redirect unauthenticated users to login
  - Role-based routing: `/admin/*` vs `/customer/*` based on `UserRole` enum
- **Backend**: Firebase Authentication, Firestore, Crashlytics, Cloud Messaging
  - Firebase options generated via FlutterFire CLI: `firebase_options.dart`
  - Environment-specific Firebase configs: `main_dev.dart` vs `main_prod.dart`
- **Logging**: Talker with environment-specific verbosity (debug/info/error)
  - Dev: verbose logging with stack traces
  - Prod: error-level only, integrated with Crashlytics

### Error Handling Pattern (MANDATORY)

- **Result<T> Monad**: All async operations MUST return `Result<Success<T> | Failure<AppException>>`
  - Use `Result.guard(() => async operation)` to wrap calls
  - Handle exhaustively with `.when(success: ..., failure: ...)` or pattern matching
  - Transform with `.map()`, unwrap with `.getOrNull()` or `.getOrElse(fallback)`
- **AppException Hierarchy**: Sealed class with final subtypes (open for extension via core file)
  - Base class is `sealed` - new exception types added only to `lib/core/error/app_exception.dart`
  - All subtypes are `final` - cannot be subclassed outside the core file
  - **Exhaustive Pattern Matching**: Compiler enforces handling all defined cases
  - **Current 5 exception types**:
    - `AuthException` - Firebase Auth errors (with optional code field)
    - `DatabaseException` - Firestore or remote data errors
    - `StorageException` - SharedPreferences or local storage errors
    - `ValidationException` - Client-side validation failures (with optional field)
    - `UnknownException` - Catch-all for unexpected errors (with cause field)
  - **Adding New Exception Types**:
    - New types (e.g., `NetworkException`, `PermissionException`) MUST be added to core file
    - Requires MINOR version bump (backward compatible addition)
    - All existing pattern matches MUST be updated (compiler will enforce)
    - Update tests to cover new exception type
- **Exception Mapping**: Data layer MUST catch platform exceptions and rethrow as AppException
  - Example: `on FirebaseAuthException catch (e) => throw AuthException.fromFirebase(e.code)`
  - Presentation layer NEVER handles Firebase exceptions directly
- **User-Friendly Messages**: All AppException messages MUST be actionable for end users
  - Bad: "Firebase error 503", Good: "No internet connection. Please check your network."

## Domain-Specific Rules

### Canonical Entity Reference

- The full domain entity specification lives in [docs/domain/ENTITIES.md](../../docs/domain/ENTITIES.md)
- The constitution only keeps behavioral rules that depend on those entities

### Time Margin Policy (BUSINESS-CRITICAL)

- Each service defines a configurable time margin (e.g., 5-10 minutes grace period)
- When customer's turn begins (`status: serving`), countdown timer starts
- If customer does NOT check in within the time margin:
  - Appointment `status` automatically changes to `noShow`
  - Queue advances to next appointment
  - Customer receives notification
- Enforcement MUST be server-side (Cloud Functions or Firestore triggers) to prevent client manipulation
- Countdown accuracy: ±5 seconds tolerance
- Auto no-show detection: triggered within 10 seconds of margin expiration
- Admin CAN manually override no-show status if customer arrives late

### MVP Scope Constraints (Out of Scope)

- ❌ Online payments - Display price only, no Stripe/PayPal integration
- ❌ Multi-branch support - Single organization per admin
- ❌ Multi-language support - English only in MVP
- ❌ Advanced analytics dashboards - Basic daily summary only
- ❌ Email notifications - Push notifications only (FCM)

### Security & Compliance

- **Firestore Security Rules** MUST enforce role-based access:
  - Admins: full CRUD on their `organizations/{orgId}` and subcollections
  - Customers: read organization/services/working hours, create appointments (own userId only), read own queue position
  - No public write access without authentication
- User data encrypted at rest (Firebase default) and in transit (HTTPS)
- Authentication tokens refreshed automatically; handle expiration gracefully
- **Secure Credential Storage**: Authentication tokens and sensitive credentials MUST use `flutter_secure_storage`, NOT `SharedPreferences`
  - Configure `AndroidOptions(encryptedSharedPreferences: true)` and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`
  - `SharedPreferences` is acceptable only for non-sensitive UI preferences (e.g., onboarding seen flag, theme selection)
  - Tokens, refresh tokens, and any PII stored locally MUST go to the secure keychain/keystore
- **Input Validation & Sanitization**: All user-supplied input MUST be validated before use
  - Validate email, phone, and URL formats with regex before submitting to Firestore
  - Sanitize text inputs to prevent XSS in any web-rendered content (replace `<`, `>`, `"` with HTML entities)
  - Firestore security rules provide the server-side enforcement layer; client validation is UX only
  - Never construct Firestore queries by string concatenation of user input — always use typed field filters
- **PII Protection**: Names, phone numbers, email MUST NOT be logged in production Talker logs
- Password reset flows MUST use Firebase email verification (no SMS in MVP)
- Google Sign-In consent screens MUST disclose data usage per OAuth policies
- Firebase security rules MUST be tested before deployment (use Firebase Emulator Suite)

### Code Style & Documentation

- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart) and [effective Dart patterns](https://dart.dev/guides/language/effective-dart)
- **Linting**: `analysis_options.yaml` enforced (includes `package:flutter_lints/flutter.yaml`)
  - `prefer_single_quotes: true` - Use single quotes for strings
  - `camel_case_types: true` - PascalCase for classes, camelCase for variables
  - `avoid_print: false` - Use `AppLogger` instead (Talker integration)
  - Generated files excluded: `**/*.config.dart`, `**/*.g.dart`, `**/*.freezed.dart`
- **Public APIs** MUST include dartdoc comments with examples:
  ```dart
  /// Fetches appointments for the given [orgId] within [dateRange].
  ///
  /// Returns [Result<List<AppointmentEntity>>] with appointments ordered
  /// by [scheduledAt] ascending.
  ///
  /// Example:
  /// ```dart
  /// final result = await repo.getAppointments('org123', dateRange);
  /// result.when(
  ///   success: (appointments) => print('Found ${appointments.length}'),
  ///   failure: (e) => print('Error: ${e.message}'),
  /// );
  /// ```
  Future<Result<List<AppointmentEntity>>> getAppointments(
    String orgId,
    DateTimeRange dateRange,
  );
  ```
- **Complex Business Logic** MUST include inline comments explaining *why*, not *what*:
  - Good: `// Wait for margin to expire before marking no-show (business policy)`
  - Bad: `// Set status to noShow` (obvious from code)
- **Architecture Decision Records (ADRs)** for major technical choices:
  - Why Cubit over full BLoC? (Simpler, sufficient for our state needs)
  - Why Result<T> over throwing exceptions? (Explicit error handling, better composition)
  - Store in `docs/adr/` with date and decision number
- **README.md** MUST be updated with:
  - Setup instructions (Firebase config, environment setup)
  - Current project status (% complete, active branch)
  - Link to comprehensive docs (`docs/ARCHITECTURE.md`, `docs/domain/PRD.md`)
- **Entity & Model Documentation**:
  - Every entity MUST document its Firestore path and purpose
  - Every model MUST document serialization format and field mappings
  - See [docs/domain/ENTITIES.md](../../docs/domain/ENTITIES.md) for canonical entity specifications

## Development Workflow

### Code Review Requirements

All pull requests MUST satisfy these gates before merge to `develop`:

✅ **Build and Analysis Passing**
   - Dart analyzer: 0 errors, 0 warnings
   - Build succeeds for target platform (Android/iOS)
   - Any configured automated tests for the change pass

✅ **Architecture Compliance Verified**
   - Layer separation maintained (domain → data, data → presentation)
   - No Firebase imports in domain layer
   - No UI logic in repository implementations
   - Dependency injection used (no direct instantiation of singletons)
   - Constitution Check from plan template satisfied

✅ **Validation Recorded**
   - Changes include appropriate manual or automated validation for the risk level
   - High-risk business logic changes should include targeted tests or emulator checks
   - Test coverage thresholds are advisory, not merge gates

✅ **No Breaking Changes Without Migration Plan**
   - Shared contracts (entities, repository interfaces) changes require version bump
   - Database schema changes require migration strategy
   - Breaking API changes require deprecation period or feature flag

✅ **Performance Impact Assessed**
   - Firestore operations: reviewed for efficient queries (use indexes where needed)
   - New listeners: verify cleanup in dispose() to prevent memory leaks
   - Large lists: ensure ListView.builder (lazy loading) not ListView (eager)
   - Image assets: compressed and appropriately sized

✅ **UI Changes Reviewed**
   - Screenshot or video recording attached to PR for visual changes
   - Tested on multiple screen sizes (small phone, large phone, tablet)
   - Dark mode considered (if theme supports it)
   - Design owner approval (or self-review with justification)

✅ **Code Owner Approval**
   - At least one approval from code owner or senior developer
   - For domain model changes: approval from architect
   - For security rule changes: manual testing with Firebase Emulator

**Auto-Reject Scenarios** (no exceptions):
- Lint errors or warnings present
- Unresolved merge conflicts
- Hardcoded secrets or API keys committed
- PII logged in production code paths

### Quality Gates

- **Pre-commit**: Dart formatter and analyzer (via IDE or git hooks)
- **CI Pipeline**: Static analysis, build validation, and any configured automated tests
- **Staging**: Manual QA on `develop` branch with test data
- **Production**: Release notes, version bump, Firebase rollout (gradual 10%/50%/100%)

### Branching Strategy

- `main`: Production-ready code, protected branch
- `develop`: Integration branch for feature merging
- `feature/###-name`: Individual feature development
- `hotfix/###-description`: Critical production fixes

## Governance

This constitution supersedes all other development practices and standards. All team members, code reviews, and automated checks MUST verify compliance with these principles.

**Amendment Process**:
- Proposed changes require written justification and impact analysis
- Amendments discussed in team meeting with 2/3 majority approval
- Version incremented per semantic rules (MAJOR for principle changes, MINOR for additions, PATCH for clarifications)
- Updated constitution published with migration guidance if needed

**Enforcement**:
- Pull requests violating core principles MUST be rejected with specific citation
- Recurring violations indicate need for tooling, training, or principle revision
- Quarterly constitution review to assess effectiveness and identify gaps

**Living Document**: This constitution evolves with Queue Ease. Pragmatism over dogma—principles serve the project, not vice versa.

**Version**: 2.0.0 | **Ratified**: 2026-02-25 | **Last Amended**: 2026-04-29
