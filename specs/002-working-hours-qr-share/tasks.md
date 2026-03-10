# Tasks: Working Hours Configuration & QR/Share Access

**Input**: Design documents from `/specs/002-working-hours-qr-share/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅
**Tests**: Deferred to Sprint 8 per team decision — no test tasks generated.
**Branch**: `002-working-hours-qr-share`

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Tests omitted — deferred to Sprint 8

---

## Phase 1: Setup — Blocker Resolution

**Purpose**: Unblock all Firestore writes and add the three new packages required by the feature.
Without P0-1, any write that includes `breakStart`/`breakEnd` will be silently rejected by Firestore rules.

**⚠️ CRITICAL**: Deploy `firestore.rules` first — no Firestore writes can be tested until this is live.

- [ ] T001 Update `firestore.rules`: add `breakStart` and `breakEnd` to `hasOnlyAllowedFields` in both `allow create` and `allow update` for the `working_hours` subcollection, and add conditional HH:mm validation for both break fields. Deploy: `firebase deploy --only firestore:rules` — **Note**: `WorkingHoursModel.toMap()` always emits `breakStart`/`breakEnd` keys (even when `null`), so the current rules reject ALL working hours writes — not just those containing break times. No Phase 2 Firestore operations can be tested until this deploy succeeds.
- [ ] T002 [P] Add `qr_flutter: ^4.1.0`, `share_plus: ^12.0.1`, `gal: ^2.3.0` to `pubspec.yaml` dependencies and run `flutter pub get`
- [ ] T003 [P] Add `WRITE_EXTERNAL_STORAGE` (maxSdkVersion 32) and `READ_MEDIA_IMAGES` permissions to `android/app/src/main/AndroidManifest.xml`
- [ ] T004 [P] Add `NSPhotoLibraryAddUsageDescription` key to `ios/Runner/Info.plist`

**Checkpoint**: Rules deployed, new packages resolved, platform permissions declared — data layer can now be built.

---

## Phase 2: Foundational — Data Layer

**Purpose**: Repository stack that all Working Hours user stories depend on. Must complete before US1 or US2 can be implemented.

**⚠️ CRITICAL**: This phase must complete before Phase 3 (US1) begins — blocks all working hours features.

- [ ] T005 Create `WorkingHoursRepository` abstract interface in `lib/shared/organization/domain/repositories/working_hours_repository.dart` — no Flutter imports, two methods: `watchWorkingHours(String orgId)` and `saveAllWorkingHours({orgId, days})`
- [ ] T006 Create `FirestoreWorkingHoursDatasource` in `lib/shared/organization/data/datasources/firestore_working_hours_datasource.dart` — annotate `@lazySingleton`; implement `watchWorkingHours` with `asyncMap` default-init on empty snapshot, `saveAll` with `batch.update()`, and `_initializeDefaults` with `batch.set()`; include explicit `'dayOfWeek': entity.dayOfWeek` write in batch maps
- [ ] T007 Create `WorkingHoursRepositoryImpl` in `lib/shared/organization/data/repositories/working_hours_repository_impl.dart` — annotate `@LazySingleton(as: WorkingHoursRepository)`; implement `saveAllWorkingHours` using `Result.guard`; include `_validateAll` with `_toMinutes` comparing open/close and break window
- [ ] T008 Run `dart run build_runner build --delete-conflicting-outputs` and verify `lib/core/app/di/injection.config.dart` contains entries for both `FirestoreWorkingHoursDatasource` and `WorkingHoursRepository`

**Checkpoint**: `WorkingHoursRepository` is registered in the DI container and all validation/default-init logic is in place.

---

## Phase 3: User Story 1 — Admin Configures Weekly Working Hours (Priority: P1) 🎯 MVP

**Goal**: Admin can navigate to Working Hours, see all 7 days with defaults, toggle open/closed, pick open/close times, and save changes as an atomic batch. Error messages shown for invalid schedules.

**Independent Test**: Toggle Saturday to open, set 10:00–14:00, save. Return to screen — Saturday shows as open 10:00–14:00.

- [ ] T009 [P] [US1] Create `WorkingHoursState` sealed class in `lib/admin/working_hours/presentation/cubit/working_hours_state.dart` — seven states: `Initial`, `Loading`, `Loaded(days)`, `Saving`, `SaveSuccess`, `SaveError(message)`, `StreamError(message)` — all extend `Equatable`
- [ ] T010 [P] [US1] Create `DayWorkingHoursTile` stateful widget in `lib/admin/working_hours/presentation/widgets/day_working_hours_tile.dart` — receives `WorkingHoursEntity` and `onChanged(WorkingHoursEntity)` callback; renders day name + open/closed `Switch`; when open shows two `TextButton` time pickers (openTime, closeTime) using `showTimePicker`; no break section yet (added in US2)
- [ ] T011 [US1] Create `WorkingHoursCubit` in `lib/admin/working_hours/presentation/cubit/working_hours_cubit.dart` — annotate `@injectable`; depends on `WorkingHoursRepository` and `AppLogger`; implement `watchWorkingHours(orgId)` (stream subscription, emits `Loading` then `Loaded`/`StreamError`) and `saveAll({orgId, days})` (emits `Saving` then `SaveSuccess`/`SaveError`); cancel subscription in `close()`
- [ ] T012 [US1] Create `WorkingHoursPage` in `lib/admin/working_hours/presentation/pages/working_hours_page.dart` — reads `orgId` from `OrganizationCubit` in `initState` and calls `cubit.watchWorkingHours(orgId)`; maintains local `_pendingDays` list updated by tile `onChanged` callbacks; `BlocConsumer` with `buildWhen` excluding save transient states; `listener` shows success/error snackbar and resets `_pendingDays` on `Loaded`; `ListView.builder` for 7 `DayWorkingHoursTile` widgets; Save All button (disabled during `Saving`) passes `_pendingDays` to `cubit.saveAll`; `AppLoadingIndicator` for `Loading`, `AppErrorWidget` for `StreamError`

**Checkpoint**: Admin can open Working Hours, see defaults, change day times, and save. Full P1 story testable end-to-end.

---

## Phase 4: User Story 2 — Admin Configures Break Times (Priority: P2)

**Goal**: For any open day, admin can enable an optional break period (e.g. 12:00–13:00). Break times are persisted and validated to be within working hours. Clearing the break toggle removes it.

**Independent Test**: Enable break on Monday 12:00–13:00, save. Return to screen — Monday shows break period 12:00–13:00.

- [ ] T013 [P] [US2] Create `BreakTimeSection` stateful widget in `lib/admin/working_hours/presentation/widgets/break_time_section.dart` — receives `breakStart`, `breakEnd` (nullable strings) and `onChanged(String? breakStart, String? breakEnd)` callback; renders a break-enable `Switch`; when enabled shows two `TextButton` time pickers (breakStart, breakEnd) using `showTimePicker` with defaults 12:00/13:00
- [ ] T014 [US2] Update `DayWorkingHoursTile` in `lib/admin/working_hours/presentation/widgets/day_working_hours_tile.dart` to include `BreakTimeSection` below the open-time row when the day is open; wire `BreakTimeSection.onChanged` to update the entity's `breakStart`/`breakEnd` and call the parent `onChanged` callback

**Checkpoint**: Break time configuration fully functional within the Working Hours page. US1 + US2 both testable end-to-end.

---

## Phase 5: User Story 3 — Admin Views and Shares QR Code (Priority: P3)

**Goal**: Admin navigates to Share Access page, sees QR code encoding their booking URL, can share via native share sheet or copy the link to clipboard. Confirmation snackbar shown for both actions.

**Independent Test**: Navigate to Share Access page, see QR code. Tap "Share" — native share sheet opens. Tap "Copy Link" — URL is copied and snackbar confirms.

- [ ] T015 [P] [US3] Create `ShareAccessState` sealed class in `lib/admin/share_access/presentation/cubit/share_access_state.dart` — five states: `Initial`, `LinkCopied`, `Downloading`, `Downloaded`, `Error(message)` — all extend `Equatable`
- [ ] T016 [P] [US3] Create `QrCodeDisplay` stateless widget in `lib/admin/share_access/presentation/widgets/qr_code_display.dart` — receives `url` string; renders `QrImageView` (data: url, version: auto, size: 220, backgroundColor: white, errorCorrectionLevel: M); no RepaintBoundary here (added at page level in US4)
- [ ] T017 [US3] Create `ShareAccessCubit` in `lib/admin/share_access/presentation/cubit/share_access_cubit.dart` — annotate `@injectable`; depends on `AppLogger` only (no repository); implement `copyLink(String url)` using `Clipboard.setData` then emit `LinkCopied`, reset to `Initial` after 2-second delay; implement `shareContent({url, qrBytes})` using `Share.shareXFiles` with PNG bytes or `Share.share` for URL fallback; emit `Error` on platform failure
- [ ] T018 [US3] Create `ShareActionButtons` stateless widget in `lib/admin/share_access/presentation/widgets/share_action_buttons.dart` — receives `onShare`, `onCopyLink`, `onDownload` callbacks and the current `ShareAccessState`; renders Share (`Icons.share`) and Copy Link (`Icons.copy`) buttons; Download button added in US4
- [ ] T019 [US3] Create `ShareAccessPage` in `lib/admin/share_access/presentation/pages/share_access_page.dart` — reads `bookingLinkSlug` from `OrganizationCubit` and builds `bookingUrl = 'https://queueease.app/org/$slug'`; shows `QrCodeDisplay(url: bookingUrl)` and booking URL text; `BlocListener` on `ShareAccessCubit` shows snackbars for `LinkCopied`, `Downloaded`, `Error`; passes cubit callbacks to `ShareActionButtons`; if slug is missing shows error prompting to contact support

**Checkpoint**: Share Access page fully functional with QR display, native share, and copy-link. US3 testable end-to-end.

---

## Phase 6: User Story 4 — Admin Downloads QR Code as Image (Priority: P4)

**Goal**: Admin taps "Download QR" and the QR code PNG is saved to their device gallery. Success and error feedback via snackbar.

**Independent Test**: Tap "Download QR" — image saved to gallery, success snackbar confirms.

- [ ] T020 [US4] Update `ShareAccessPage` in `lib/admin/share_access/presentation/pages/share_access_page.dart` to wrap `QrCodeDisplay` in `RepaintBoundary` with a `GlobalKey<State>`; add `_captureQrBytes()` async helper using `boundary.toImage(pixelRatio: 3.0)` → `toByteData(ImageByteFormat.png)`; wire `onDownload` callback to call `_captureQrBytes()` then `cubit.downloadQrCode(bytes)` and `onShare` to include `qrBytes` from `_captureQrBytes()`
- [ ] T021 [US4] Add `downloadQrCode(Uint8List pngBytes)` method to `ShareAccessCubit` in `lib/admin/share_access/presentation/cubit/share_access_cubit.dart` — emit `Downloading`, call `Gal.putImageBytes(pngBytes)`, emit `Downloaded`; emit `Error` on `GalException` with permission-hint message
- [ ] T022 [US4] Update `ShareActionButtons` in `lib/admin/share_access/presentation/widgets/share_action_buttons.dart` to add Download QR button (`Icons.download`); show `CircularProgressIndicator` inside the button when state is `ShareAccessDownloading`; disable all buttons during `Downloading`

**Checkpoint**: All four user stories fully functional. Full sprint feature surface testable end-to-end.

---

## Phase 6b: Regenerate DI After Cubits

**Purpose**: `WorkingHoursCubit` (T011, `@injectable`) and `ShareAccessCubit` (T017, `@injectable`) were added after the T008 build_runner run. Without re-running code generation, `getIt<WorkingHoursCubit>()` and `getIt<ShareAccessCubit>()` used in the route definitions (T023) will be missing from the DI container, causing compile-time failures.

**⚠️ REQUIRED**: Must run before Phase 7 — T023 depends on both cubits being registered.

- [ ] T026 Run `dart run build_runner build --delete-conflicting-outputs` and verify `lib/core/app/di/injection.config.dart` now contains registrations for both `WorkingHoursCubit` and `ShareAccessCubit` in addition to the Phase 2 entries

**Checkpoint**: DI container has all four new registrations — `FirestoreWorkingHoursDatasource`, `WorkingHoursRepository`, `WorkingHoursCubit`, `ShareAccessCubit`. Route wiring can now proceed.

---

## Phase 7: Navigation & Integration

**Purpose**: Wire the two new screens into GoRouter and replace all `_showComingSoon` stubs with real navigation.

- [ ] T023 Add route constants `adminWorkingHours = '/a/working-hours'` and `adminShareAccess = '/a/share-access'` to `Routes` abstract class, and add the two corresponding `GoRoute` entries (each with `BlocProvider` wrapping) in `lib/core/app/router/app_router.dart`
- [ ] T024 [P] Replace `_showComingSoon` in the Working Hours `_ManagementCard.onTap` and `_ShareAccessCard.onTap` with `context.push(Routes.adminWorkingHours)` and `context.push(Routes.adminShareAccess)` in `lib/admin/dashboard/presentation/pages/admin_dashboard_tab.dart`
- [ ] T025 [P] Replace both `_showComingSoon` calls in the "Organization" section (Working Hours tile and Share Access tile) with `context.push(Routes.adminWorkingHours)` and `context.push(Routes.adminShareAccess)` in `lib/admin/presentation/pages/settings_page.dart`

**Checkpoint**: Both pages reachable from Admin Dashboard and Settings. Full navigation flow verified.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup / P0)
    ↓
Phase 2 (Foundational — Data Layer)
    ↓
Phase 3 (US1 — Weekly Working Hours) ──┐
    ↓                                  │  can run in parallel after Phase 2
Phase 4 (US2 — Break Times)            │
                                       │
Phase 5 (US3 — QR / Share) ────────────┘
    ↓
Phase 6 (US4 — Download QR)
    ↓
Phase 7 (Navigation & Integration)
```

### User Story Dependencies

| Story | Depends On | Can Start After |
|-------|-----------|----------------|
| US1 (P1) | Phase 2 complete | T008 |
| US2 (P2) | US1 complete | T012 |
| US3 (P3) | Phase 1 complete (packages only) | T002 |
| US4 (P4) | US3 complete | T019 |

> **Note**: US3/US4 `ShareAccessCubit` has no repository dependency — it only needs the packages from Phase 1. US3 can start once `qr_flutter` and `share_plus` are installed, independently of the data layer.

### Within Each Phase

- Tasks without `[P]` markers must run in sequence (upstream output required)
- Tasks marked `[P]` can be picked up simultaneously by different contributors

### Parallel Opportunities

| Phase | Parallel Tasks |
|-------|---------------|
| Phase 1 | T002, T003, T004 can run in parallel |
| Phase 3 | T009 and T010 can start in parallel |
| Phase 5 | T015 and T016 can start in parallel |
| Phase 7 | T024 and T025 can run in parallel |

---

## Parallel Example: User Story 1 (Phase 3)

```
Start simultaneously:
  Developer A → T009: WorkingHoursState
  Developer B → T010: DayWorkingHoursTile

After T009 completes:
  Developer A → T011: WorkingHoursCubit

After T010 + T011 complete:
  Developer A or B → T012: WorkingHoursPage
```

---

## Implementation Strategy

### MVP Scope (Phase 1 + 2 + 3)

Deliver US1 first — it is the only story that the downstream Sprint 4 booking flow depends on.
```
T001 → T002–T004 → T005 → T006 → T007 → T008 → T009+T010 → T011 → T012 → T026 → T023 → T024+T025
```
At this point: admin can configure weekly working hours end-to-end.

### Incremental Delivery

| Increment | Tasks | Deliverable |
|-----------|-------|-------------|
| 1 | T001–T012 + T026 + T023–T025 | Full US1 (Weekly schedule) shipped |
| 2 | T013–T014 | US2 (Break times) layered on top |
| 3 | T015–T019 | US3 (QR view + share + copy) shipped |
| 4 | T020–T022 | US4 (QR download to gallery) shipped |

### Total Task Count

| Phase | Tasks | User Story |
|-------|-------|-----------|
| Phase 1 — Setup | 4 (T001–T004) | — |
| Phase 2 — Foundational | 4 (T005–T008) | — |
| Phase 3 — Weekly Hours | 4 (T009–T012) | US1 (P1) |
| Phase 4 — Break Times | 2 (T013–T014) | US2 (P2) |
| Phase 5 — QR/Share | 5 (T015–T019) | US3 (P3) |
| Phase 6 — Download QR | 3 (T020–T022) | US4 (P4) |
| Phase 6b — Regen DI | 1 (T026) | — |
| Phase 7 — Navigation | 3 (T023–T025) | — |
| **Total** | **26 tasks** | |
