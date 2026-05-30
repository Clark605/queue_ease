# Research: Resolve GitHub Issues

## Fetched Issue Inventory

The current GitHub backlog at planning time contains 16 open issues.

### P1 - Critical Bucket

- #17 Firestore whereIn limit not guarded - queues with 31+ entries crash
- #18 Cancelled appointments still block their time slot from rebooking
- #19 ParseAccessUrlUseCase does not lowercase slug - QR code slug lookup fails on case mismatch

### P2 - High Impact

- #20 SlotPickerCubit fetches working hours once - admin schedule changes not reflected in active sessions
- #21 transactionNext does not skip completed/noShow entries - ghost current entry shown to admin
- #22 OrganizationLandingCubit derives open/closed status from device clock, not server time
- #30 WaitTimerCountdown freezes - stateless widget does not tick over time
- #31 Cancellation only allows booked status - inQueue and waiting appointments cannot be cancelled
- #32 Firestore rules reject admin updates on cancelled appointments - missing status in whitelist

### P3 - Medium and Low

- #23 retrySubmit re-submits a stale slot - creates a conflict loop with no escape path
- #24 WatchCustomerDashboardUseCase silently drops second active appointment from different org
- #25 Service with durationMinutes = 0 corrupts wait estimates for all subsequent queue entries
- #26 Orphaned inQueue appointment from previous day not visible on customer dashboard
- #27 Break time end chip can be set before break start with no inline validation
- #28 No booking horizon limit - customers can book appointments arbitrarily far in the future
- #29 Auto no-show exponential backoff resets on any unrelated queue success event

## Decisions

- Treat the critical bucket as the three P1 blockers and ship each one in its own PR.
- Batch only related P2/P3 issues when they share the same subsystem and validation harness.
- Use unit tests for domain and repository logic, widget tests for UI-driven regressions, and Firestore rules tests for security-rule changes.
- Do not add new dependencies unless a gap is proven during implementation.

## Rationale

- The P1 issues are independent blockers with distinct code paths, so separate PRs keep review and rollback simple.
- The P2 and P3 issues are smaller but still span related subsystems, so grouping by subsystem reduces churn without hiding regressions.
- The repo already has domain, widget, and Firestore rules test surfaces, so the plan can validate each fix in the narrowest useful layer.

## Alternatives Considered

- One mega-PR for all 16 issues: rejected because it is too risky and hard to review.
- One PR per issue for all issues: rejected because several medium and low items are related and safer to batch.
- Manual verification only: rejected because the feature spec requires automated validation for fixes.

## Final Delivery Matrix

| PR | Issues | Scope | Status |
| --- | --- | --- | --- |
| #35 | #17, #18, #19, #20, #21, #22, #23, #24, #25, #26, #27, #28, #29, #30, #31, #32 | Queue loading, booking flows, access portal, working hours, Firestore rules, and related UI regressions | Open; updated to carry the full issue-fix set |

## Deferred Items

- None. The remaining work is PR merge and issue closure after review.
