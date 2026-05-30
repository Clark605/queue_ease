# Data Model: Resolve GitHub Issues

## IssueWorkItem

Represents one GitHub issue tracked in this planning cycle.

### Fields

- `number`: GitHub issue number
- `title`: issue title
- `labels`: raw GitHub labels
- `priority`: P1, P2, or P3 after triage
- `subsystem`: admin, customer, shared domain, Firestore rules, or backlog hygiene
- `affectedFiles`: repository paths affected by the fix
- `rootCause`: short explanation of the defect
- `fixStrategy`: the planned code or rule change
- `testStrategy`: the automated validation that proves the fix
- `prUrl`: PR link once created
- `status`: open, triaged, in_progress, fixed_in_pr, validated, closed, or deferred

### Validation Rules

- Every work item must have a priority and subsystem before implementation starts.
- Every work item must name at least one automated validation artifact.
- P1 work items must not be bundled with unrelated issues.
- A deferred item must include a note explaining why it was not fixed in the current cycle.

### State Transitions

- `open` -> `triaged` -> `in_progress` -> `fixed_in_pr` -> `validated` -> `closed`
- `open` -> `triaged` -> `deferred`

## FixBatch

Represents a grouped set of related issues that can safely share a PR.

### Fields

- `name`: short human-readable batch name
- `issues`: issue numbers included in the batch
- `subsystem`: the shared code area
- `validationHarness`: the test or rules suite used to validate the batch
- `prStrategy`: separate PR or grouped PR

### Relationship

- One batch can contain one or more issues.
- A batch should only span a single subsystem or a tightly related set of files.

## VerificationArtifact

Represents the evidence used to prove a fix.

### Fields

- `type`: unit, widget, rules, or ci
- `command`: the command or test suite name
- `expectedSignal`: the observable success condition
- `status`: pending, passing, or failing

### Relationship

- Each issue must have at least one verification artifact.
- Security-rule changes must include a rules artifact.
- UI regressions that require rebuilds must include a widget or integration artifact.
