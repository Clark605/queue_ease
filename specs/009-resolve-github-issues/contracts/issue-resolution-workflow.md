# Issue Resolution Workflow Contract

## Purpose

Define the expected inputs, outputs, and review rules for resolving GitHub issues in this repository.

## Inputs

- GitHub issue number
- issue title and labels
- affected code surface
- triage priority
- planned test or rules coverage

## Outputs

- one or more PRs that reference the issue number
- a validation note describing the automated tests that were run
- a closure comment or release note entry after merge

## Rules

- P1 issues must be delivered in separate PRs.
- Related P2 and P3 issues can be grouped only when they share the same subsystem and test harness.
- Every fix must include at least one automated validation artifact.
- Any Firestore rules change must be paired with rules tests.
- UI fixes that change runtime behavior must be paired with widget or integration tests when appropriate.

## Required Fields

| Field | Description |
| --- | --- |
| `issue_number` | The GitHub issue being resolved |
| `priority` | P1, P2, or P3 after triage |
| `root_cause` | The underlying defect or mismatch |
| `affected_files` | Repository paths touched by the fix |
| `test_strategy` | Automated validation used for the fix |
| `pr_link` | The PR that closes the issue |
