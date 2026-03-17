# Research: Business Logic & Automation

## Decision 1: Keep the implementation inside the existing Flutter + Firebase stack

- Decision: Implement Sprint 6 using the current Flutter mobile app, `flutter_bloc` Cubits, Firestore transactions, Firestore rules, and existing GetIt/Injectable wiring. Do not introduce Cloud Functions or new packages.
- Rationale: The repository already ships queue generation and queue actions through `AdminQueueDatasource`, `AdminQueueRepositoryImpl`, and `QueueManagementCubit`. Reusing the same stack keeps the change aligned with the constitution, avoids new operational dependencies, and respects the stated sprint scope.
- Alternatives considered:
  - Cloud Functions for timer enforcement: rejected because Sprint 6 explicitly keeps automation client-triggered.
  - A new timer package or scheduler dependency: rejected because Dart timers plus existing Firestore listeners are sufficient.

## Decision 2: Fix the root cause by changing queue flow semantics, not only the UI

- Decision: Replace the current implicit "first entry becomes serving" flow with an explicit front-of-queue automation state model. The queue pointer remains the source of truth for the current customer, but pre-booking entries stay action-locked and no-show eligible entries remain distinct from `serving` until the admin explicitly starts service.
- Rationale: The current datasource generates the queue and immediately promotes the first appointment to `serving`, while Firestore rules only allow skip and no-show from `serving`. That conflicts with the clarified spec: pre-booking entries must be locked, no-show eligibility ends only when the admin marks `serving`, and auto no-show applies before that point. A UI-only disablement would leave invalid persisted state in Firestore.
- Alternatives considered:
  - Keep implicit promotion and only disable buttons before `scheduledAt`: rejected because the data layer would still claim the customer is already `serving` before arrival.
  - Add a completely new persisted queue status enum: rejected because the repo already has workable `AppointmentStatus` and queue pointer concepts; the simpler change is to derive automation state from existing data plus one explicit service-start transition.

## Decision 3: Derive automation state from existing documents instead of adding a new collection

- Decision: Compute countdown state, action availability, effective time margin, and no-show deadline from `Appointment.scheduledAt`, `Appointment.status`, `QueueEntity.currentServingIndex`, and `Service.timeMarginMinutes`. Extend `QueueEntryView` and `AdminQueueSnapshot` instead of creating a new Firestore document type.
- Rationale: The existing repository already joins queue and appointment documents into `QueueEntryView`. Extending that projection keeps business rules centralized in the data/domain boundary and avoids extra synchronization burden.
- Alternatives considered:
  - Persist a dedicated automation document per appointment: rejected because it duplicates existing queue and appointment data.
  - Compute all gating rules directly inside widgets: rejected by the constitution because presentation must not own business logic.

## Decision 4: Use Firestore as the canonical source for persisted times, and local time only for rendering and eligibility checks

- Decision: Treat Firestore `scheduledAt` values and persisted service configuration as canonical inputs. Use local ticking in the app for the visible countdown, while all writes remain guarded by transaction preconditions and Firestore rules.
- Rationale: The app must render a per-second countdown without server round-trips, but all authoritative business inputs already live in Firestore. Transactions and rules can still reject premature or invalid state changes.
- Alternatives considered:
  - Poll Firestore every second for a server-aligned now value: rejected as costly and unnecessary.
  - Leave timing fully device-driven with no transaction/rules guardrails: rejected because it weakens consistency and makes race conditions more likely.

## Decision 5: Add a small but explicit UI contract for current-entry states and allowed actions

- Decision: Formalize four operational states for the front queue entry: `not_due_yet`, `awaiting_arrival`, `overdue`, and `serving`. Tie admin action availability to those states and mirror no-show status clearly in the customer queue-status UI.
- Rationale: The current `CurrentQueueCard` assumes a serving-only card with `Next`, `Skip`, and `No-Show`. Sprint 6 needs state-specific behavior, action lockouts, and customer-facing no-show messaging. Writing the contract now keeps plan, tests, and implementation aligned.
- Alternatives considered:
  - Keep behavior implicit in Cubit code only: rejected because it makes widget and test behavior harder to verify.
  - Document only data changes and defer UI semantics: rejected because the spec has explicit acceptance criteria for disabled actions, `Not due yet`, countdowns, and customer messaging.