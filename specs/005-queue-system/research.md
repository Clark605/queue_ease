# Research: Queue System (Sprint 5)

**Date**: 2026-03-14  
**Feature**: `005-queue-system`

## R-001: Queue Eligibility Source Set

**Decision**: Generate active queue entries from today's appointments where `status == booked` only.

**Rationale**: The spec clarification explicitly constrained eligibility to `booked` for same-day operations, which keeps queue generation deterministic and prevents duplicate lifecycle transitions for already-progressed appointments.

**Alternatives considered**:
- Include `inQueue`/`serving` in generation set — rejected: reintroduces already-active entries.
- Include all except terminal statuses — rejected: ambiguous for reruns and backfills.

---

## R-002: Queue Action Atomicity & Idempotency

**Decision**: Use Firestore transaction-based queue actions that validate current state and apply exactly one transition per action invocation.

**Rationale**: Even with single-admin scope, retries, stale client state, and duplicate taps can create inconsistent transitions. Transactional precondition checks prevent duplicate status changes and preserve queue order integrity.

**Alternatives considered**:
- Plain update writes without transaction — rejected: race/retry hazards.
- Client-only lock flags — rejected: unreliable across reconnect/restart.

---

## R-003: Skipped Rejoin Policy

**Decision**: Rejoin of skipped customer is an explicit admin action that appends the entry to the end of the waiting queue.

**Rationale**: This matches clarified business policy and avoids fairness ambiguity around original-position insertion.

**Alternatives considered**:
- No rejoin support — rejected: fails explicit requirement.
- Rejoin at original position — rejected: increases operational disputes.

---

## R-004: Wait Time Formula

**Decision**: Compute estimated wait time as the sum of service durations of active queue entries ahead of the customer.

**Rationale**: Uses existing appointment/service duration data, produces deterministic estimates, and aligns with clarified scope.

**Alternatives considered**:
- Fixed average per position — rejected: inaccurate across mixed service durations.
- Hybrid heuristic — rejected: unnecessary complexity for MVP.

---

## R-005: Customer Privacy Boundary

**Decision**: Customer queue view exposes only the authenticated customer's own queue status plus current-serving indicator; no other customer identities are shown.

**Rationale**: Meets privacy clarification while still conveying actionable queue progress.

**Alternatives considered**:
- Show anonymized full queue — rejected: extra UI complexity and potential inference risk.
- Show full names — rejected: violates privacy requirement.

---

## R-006: Repository/Use Case Placement

**Decision**: Extend existing `admin/queue_management` and `customer/booking` repository contracts, then orchestrate logic through new queue-focused domain use cases and cubits.

**Rationale**: Fits existing feature-first architecture and avoids introducing parallel abstractions for similar appointment/queue operations.

**Alternatives considered**:
- Create cross-feature super-repository in `core/` — rejected: unnecessary broad coupling.
- Put queue logic directly in cubits — rejected: violates domain ownership rule.

---

## R-007: Firestore Data Access Pattern

**Decision**: Keep queue document as ordering source (`orderedAppointmentIds`, `currentServingIndex`) and use appointment documents for status/duration details.

**Rationale**: Reuses existing `QueueModel` and `AppointmentEntity` with minimal schema disruption, while enabling consistent ordered rendering and wait-time recomputation.

**Alternatives considered**:
- Duplicate full appointment payload inside queue doc — rejected: denormalization drift risk.
- Status-only queue without ordered IDs — rejected: unstable ordering semantics.

---

## R-008: Testing Scope for Plan Implementation

**Decision**: Include unit tests for queue use cases and cubit state transitions plus repository tests with mocked datasource behavior before merge.

**Rationale**: Constitution requires comprehensive tests before PR merge; Sprint 5 queue logic is business-critical and state-transition heavy.

**Alternatives considered**:
- Defer tests to later sprint — rejected: violates constitution testing standards.

---

## R-009: Flutter + Firebase Technical Baseline

**Decision**: Implement with Flutter (Dart 3.9), Firestore transactions/streams, Firebase Auth identity checks, and existing Talker + AppException patterns.

**Rationale**: This is the current project stack and already integrated in adjacent features; using the same stack minimizes risk and onboarding overhead.

**Alternatives considered**:
- Cloud Functions for queue actions in Sprint 5 — rejected: outside clarified scope and adds deployment overhead.
