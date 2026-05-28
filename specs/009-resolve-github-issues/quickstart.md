# Quickstart: Resolve GitHub Issues

## 1. Review The Fetched Backlog

Use the backlog snapshot in `plan.md` and the detailed inventory in `research.md` to confirm which issues are in scope:

- P1: #17, #18, #19
- P2: #20, #21, #22, #30, #31, #32
- P3: #23, #24, #25, #26, #27, #28, #29

## 2. Triage Before Coding

- Confirm the issue labels and normalize the misspelled `crititcal` label in your working notes.
- Assign each issue to a subsystem and decide whether it belongs in a single PR or a grouped PR.
- Keep P1 issues separate unless two fixes are truly the same code change.

## 3. Implement The Fixes In Order

- Start with #17, #18, and #19 because they are direct blockers.
- Move to the P2 flow regressions once the critical path is stable.
- Finish with the P3 guardrails and cleanup items.

## 4. Validate Each Change

- Use unit tests for repository and use-case changes.
- Use widget tests for `wait_timer_countdown.dart` and cancellation UI changes.
- Use the Firestore rules suite for any rule edits.
- Run the repository's full Flutter test suite before merging a PR.

## 5. Close The Issues

- Reference the issue number in the PR body and in the closing comment.
- Close the issue only after the PR merges and validation passes.
- Record any items intentionally deferred with the reason they were not fixed.
