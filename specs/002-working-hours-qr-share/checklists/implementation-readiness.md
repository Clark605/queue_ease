# Implementation Readiness Checklist: Working Hours Configuration & QR/Share Access

**Purpose**: Implementer self-check — run before starting each phase in tasks.md. Items validate whether the requirements are *written well enough to act on*, and whether they correctly describe the engineering patterns required by `copilot-instructions.md`.
**Created**: 2026-03-10
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md) | [tasks.md](../tasks.md)
**Audience**: Implementer (pre-phase gate)
**Scope**: Pre-implementation readiness + engineering-rule compliance (copilot-instructions.md). Excludes issues already tracked in the consistency analysis report (C1, U1, C3, C4, A1, D1).

---

## Pre-Implementation Completeness

*Are all necessary requirements documented to a level where an implementer can act without re-reading multiple documents?*

- [ ] CHK001 Is the `WorkingHoursEntity` mutation strategy for `_pendingDays` local state specified — specifically, is there documented guidance on how tile `onChanged` callbacks create modified copies of an immutable `const WorkingHoursEntity` (no `copyWith` exists on the entity)? [Completeness, plan.md Task 2-3, Gap]

- [ ] CHK002 Is the `BlocConsumer buildWhen` predicate for `WorkingHoursPage` explicitly enumerated in the requirements — naming each of the states that trigger a rebuild vs. those routed only to the listener? [Completeness, plan.md Task 2-3]

- [ ] CHK003 Is the `asyncMap` double-emission on first load (research.md §5 — datasource calls `_initializeDefaults` then Firestore emits a second snapshot) reflected as a requirement on the page's `buildWhen` or listener — so the implementer knows the second `WorkingHoursLoaded` emission must not overwrite a user's in-progress edits? [Completeness, research.md §5, Gap]

- [ ] CHK004 Is the `bookingLinkSlug` access path for `ShareAccessPage` fully specified — which Cubit class provides it, which state variant carries it, and which field name to read? [Completeness, plan.md Task 3-3, Gap]

- [ ] CHK005 Is the edge case of `bookingLinkSlug` being an empty string (not null) addressed in the requirements — the spec handles missing/null slug but does not define behavior for an empty-string slug? [Completeness, spec.md Edge Cases, Gap]

- [ ] CHK006 Are `Equatable.props` completeness requirements verifiable for all 12 new state classes — do the state contracts confirm every data-carrying field appears in `props` (preventing silent Bloc equality failures)? [Completeness, contracts/cubit_states.dart]

---

## Requirement Clarity & Specificity

*Are requirements specific and unambiguous enough to implement without interpretation?*

- [ ] CHK007 Is "save transient states" in the `BlocConsumer buildWhen` description explicitly enumerated as `WorkingHoursSaving`, `WorkingHoursSaveSuccess`, and `WorkingHoursSaveError` — or is the implementer expected to infer which states are "transient" from the state hierarchy alone? [Clarity, plan.md Task 2-3]

- [ ] CHK008 Is the `_pendingDays` reset-on-loaded behavior specified for ALL `WorkingHoursLoaded` emissions — including those triggered by a remote write from another admin editing concurrently (spec.md Edge Cases) — and is the expected behavior defined when a remote update arrives while the local user has unsaved edits? [Clarity, plan.md Task 2-3, spec.md Edge Cases]

- [ ] CHK009 Is "short-lived" for `WorkingHoursSaveSuccess` quantified in the requirements — is the transition trigger specified (does the listener dismiss after the snackbar duration, or does it wait for the next `WorkingHoursLoaded` emission from the stream re-emit)? [Clarity, contracts/cubit_states.dart]

- [ ] CHK010 Are the break-time picker defaults (12:00 / 13:00) in `BreakTimeSection` specified as hard-coded string literals or as named constants — and if constants, is the constant location defined? [Clarity, tasks.md T013, plan.md Task 2-5]

- [ ] CHK011 Is the `bookingUrl` construction formula (`https://queueease.app/org/$slug`) defined in exactly one canonical location that tasks.md T019 points to — or does it appear independently in both plan.md and tasks.md, risking divergence if the URL format changes? [Clarity, plan.md Task 3-3, tasks.md T019]

- [ ] CHK012 Is the `DayWorkingHoursTile` UI behavior when a day is toggled to closed explicitly described — are open/close time fields *hidden* (removed from layout) or *disabled* (visible but non-interactive), and is the rationale (data-model.md invariant: times stored even when closed) communicated to the implementer? [Clarity, plan.md Task 2-4, data-model.md §Invariants]

---

## Cross-Document Consistency

*Do requirements across spec, plan, tasks, contracts, and quickstart align without conflicts?*

- [ ] CHK013 Does the `WorkingHoursSaveSuccess` contract ("stream re-emits `WorkingHoursLoaded` immediately after") align consistently with the page listener spec in plan.md Task 2-3 and tasks.md T012 — specifically, is the ordering of snackbar display and `_pendingDays` reset correctly sequenced in both documents? [Consistency, contracts/cubit_states.dart, plan.md Task 2-3, tasks.md T012]

- [ ] CHK014 Is the `DayWorkingHoursTile` time-field-preservation behavior consistent between plan.md (Task 2-4) and data-model.md (Invariants: `openTime`/`closeTime` stored even when `isOpen = false`) — do both documents agree that the entity's time values are retained in `_pendingDays` when a day is toggled closed? [Consistency, data-model.md §Invariants, plan.md Task 2-4]

- [ ] CHK015 Is `share_plus: ^12.0.1` consistent across all three location references — plan.md P0-2 (`^12.0.1` ✅), tasks.md T002 (`^12.0.1` ✅), and quickstart.md (`^10.1.4` ⚠️ — still shows old version and needs updating)? [Consistency, I2 partial fix, Gap]

---

## Clean Architecture Compliance (copilot-instructions.md Rules 7–9, 11)

*Do the requirements correctly describe Clean Architecture patterns — or do they risk guiding the implementer toward a layer violation?*

- [ ] CHK016 Is the domain-layer purity requirement verifiable from the contract — does `contracts/working_hours_repository.dart` explicitly contain zero Flutter/Firebase imports and zero Injectable annotations, confirming the domain layer is framework-agnostic as required? [Architecture, Rule 7, contracts/working_hours_repository.dart]

- [ ] CHK017 Is the `@injectable` vs `@lazySingleton` distinction correctly and consistently specified — are cubits (`WorkingHoursCubit`, `ShareAccessCubit`) specified as `@injectable` (factory, new instance per route) while datasources and repository impls are `@lazySingleton` (shared singleton)? [Architecture, Rule 11, plan.md Tasks 1-2, 2-2, 3-2]

- [ ] CHK018 Is `WorkingHoursCubit` specified to depend on the **abstract** `WorkingHoursRepository` domain interface — not on `WorkingHoursRepositoryImpl` from the data layer — confirming that the DI container is the only thing that knows the concrete type? [Architecture, Rule 9, plan.md Task 2-2]

- [ ] CHK019 Is `ShareAccessCubit`'s use of `Clipboard` (`flutter/services`) explicitly noted as a presentation-layer Flutter dependency — acceptable in a Cubit but not something that should migrate into a repository or domain use case? [Architecture, Rule 8, plan.md Task 3-2]

- [ ] CHK020 Are all new widget paths specified inside feature folders (`lib/admin/working_hours/presentation/widgets/`, `lib/admin/share_access/presentation/widgets/`) — with no widget accidentally listed under `lib/core/widgets/` without an explicit cross-feature reuse justification? [Architecture, Rule 10, plan.md Project Structure]

---

## Dart/Flutter Engineering Compliance (copilot-instructions.md Rules 2, 5, 6, 15, 17)

*Do the requirements describe implementation patterns that conform to the project's Dart/Flutter engineering rules?*

- [ ] CHK021 Are `const` constructors specified for all new **stateless** widgets (`QrCodeDisplay`, `ShareActionButtons`) — both in plan.md code samples and tasks.md task descriptions? [Rule 15, plan.md Tasks 3-4, 3-5]

- [ ] CHK022 Is the 30-line function risk for `WorkingHoursPage.build()` acknowledged in the requirements — the method must handle `BlocConsumer` wrapping, `AppLoadingIndicator`, `AppErrorWidget`, `ListView.builder` with 7 tiles, a Save All button, and save-state disabling in one method? [Rule 2, tasks.md T012]

- [ ] CHK023 Are all 10 new Dart file names specified in `snake_case` — `working_hours_cubit.dart`, `working_hours_state.dart`, `working_hours_page.dart`, `day_working_hours_tile.dart`, `break_time_section.dart`, `share_access_cubit.dart`, `share_access_state.dart`, `share_access_page.dart`, `qr_code_display.dart`, `share_action_buttons.dart`? [Rule 6, plan.md Project Structure]

- [ ] CHK024 Are all `catch` blocks in the plan's code samples specified to either re-throw, log with full context via `AppLogger`, or emit a named error state — with no generic `catch (e)` that logs nothing or swallows the exception silently? [Rule 17, plan.md Tasks 1-2, 3-2]

- [ ] CHK025 Is the `_toMinutes()` utility in `WorkingHoursRepositoryImpl` confirmed as non-duplicate — a codebase search of `lib/` finds no existing HH:mm parser in `core/utils/`, confirming a new private helper is the correct DRY-compliant approach? [Rule 5, research.md §6, Note: verified — `_toMinutes` does not exist in lib/ as of 2026-03-10]

---

## Phase Readiness

*Are individual tasks in tasks.md specific enough to execute without consulting additional documents for basic orientation?*

- [ ] CHK026 Does T001 direct the implementer to the specific function names in `firestore.rules` that need updating (`hasOnlyAllowedFields` in `allow create` and `allow update` under `match /working_hours/{dayOfWeek}`) — rather than leaving the implementer to scan the entire rules file? [Readiness, tasks.md T001]

- [ ] CHK027 Is the Android `android:requestLegacyExternalStorage="true"` attribute placement specified as inside the `<application>` tag (not as a `<uses-permission>` entry) — required for API 29–32 when saving images to gallery? [Readiness, research.md §9, tasks.md T003]

- [ ] CHK028 Is the `OrganizationCubit` availability on admin routes confirmed as a prerequisite before T011 (`WorkingHoursCubit`) and T017 (`ShareAccessCubit`) are implemented — specifically, that `context.read<OrganizationCubit>()` is accessible within the `/a/...` route subtree as expected? [Readiness, Gap]

- [ ] CHK029 Is the `StreamSubscription` cancellation strategy in `WorkingHoursCubit.close()` specified — should `_subscription?.cancel()` be `await`ed (ensures clean cancellation) or called without `await` (avoids blocking `close()`)? The plan uses `_subscription?.cancel()` without `await` — is this correct and intentional? [Readiness, plan.md Task 2-2, Gap]

- [ ] CHK030 Is the T019 → T020 `RepaintBoundary` sequencing explicitly warned — T019 creates `ShareAccessPage` and wires `onShare` with `qrBytes: null`, while T020 adds the `RepaintBoundary` and `GlobalKey`; without this warning an implementer may attempt to call `_captureQrBytes()` in T019 and encounter a `StateError` from an unattached key? [Readiness, tasks.md T019–T020]

---

## Notes

- Check items off as completed: `[x]`
- Items marked `[Gap]` identify requirements that are **missing** and should be added to plan.md or tasks.md before implementation begins
- Items marked `[Consistency]` identify specific documents that need reconciliation
- CHK015 requires a concrete fix: update `quickstart.md` line 30 from `share_plus: ^10.1.4` to `share_plus: ^12.0.1`
- CHK025 is already verified (factual note included) — mark complete
