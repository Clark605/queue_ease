# Research: Working Hours Configuration & QR/Share Access
**Sprint**: Sprint 3 | **Branch**: `002-working-hours-qr-share`

---

## 1. Firestore Collection Path

**Decision**: `organizations/{orgId}/working_hours/{dayOfWeek}`

**Rationale**: The Firestore security rules at `firestore.rules` define `match /working_hours/{dayOfWeek}` under the organization path — snake_case, not camelCase. Any datasource must use `'organizations/$orgId/working_hours'` as the collection path. Using the wrong casing would bypass security rules entirely (Firestore is case-sensitive on collection names).

**Alternatives considered**: `workingHours` (camelCase) — rejected because it does not match the existing security rules.

---

## 2. Firestore Document Write Strategy

**Decision**: Separate `set()` for initialization, `update()` for "Save All".

**Rationale**: The security rules enforce `createdAtNotModified()` on updates. Using `batch.update()` for the "Save All" operation avoids any risk of overwriting `createdAt`. The initialization path uses `batch.set()` with a full document map including `createdAt: FieldValue.serverTimestamp()`. The `saveAll` path uses `batch.update()` with only mutable fields plus `updatedAt: FieldValue.serverTimestamp()`.

**Alternatives considered**:
- `set(merge: true)` for all writes — rejected because it obscures intent: creating vs updating is meaningfully different and the separation is explicit in the rules too.
- Single write method — rejected because `update()` fails when a document does not exist, and the two paths require different field sets.

---

## 3. Firestore Security Rules: Break Fields Gap (CRITICAL)

**Finding**: The existing `firestore.rules` `hasOnlyAllowedFields` lists for `working_hours` do NOT include `breakStart` or `breakEnd`:
```
['orgId','dayOfWeek','isOpen','openTime','closeTime','createdAt','updatedAt']
```
Any write containing `breakStart` or `breakEnd` will be **denied** until the rules are updated.

**Decision**: Update `firestore.rules` as the first task of the implementation — add `breakStart` and `breakEnd` to both the `allow create` and `allow update` `hasOnlyAllowedFields` lists. Add null/string validation for break fields.

**Alternatives considered**: Omitting break fields from writes (store them separately) — rejected; this contradicts the spec and creates fragmented data.

---

## 4. dayOfWeek Field in Firestore Document

**Finding**: The security rules `allow create` rule requires `request.resource.data.dayOfWeek == int(dayOfWeek)`, meaning `dayOfWeek` must be written as an integer field in the document. However, the existing `WorkingHoursModel.toMap()` does NOT include `dayOfWeek` (it's the doc ID, not a doc field).

**Decision**: The datasource adds `'dayOfWeek': entity.dayOfWeek` explicitly in the write map, alongside the `createdAt`/`updatedAt` timestamps. The model's `toMap()` is not modified — timestamps and the doc-ID field are always a datasource concern (consistent with how `createdAt` is set by `FieldValue.serverTimestamp()` in OrganizationDatasource).

**Alternatives considered**: Adding `dayOfWeek` to `WorkingHoursModel.toMap()` — rejected; the model was built in Sprint 1 and toMap() is tested. Modifying it without a test update risks breaking existing tests.

---

## 5. Default Initialization Flow

**Decision**: `FirestoreWorkingHoursDatasource.watchWorkingHours()` uses `.snapshots().asyncMap()`. When the snapshot is empty (new organization), it calls `_initializeDefaults(orgId)` and immediately returns the 7 default entities. Firestore then emits a second snapshot with the just-written docs, which the stream converts to the same 7 entities. The brief double-emission is transparent to the UI.

**Rationale**: Keeps initialization self-contained in the datasource layer. The cubit and repository need no special initialization logic. The UI always gets a non-empty list within one stream cycle.

**Alternatives considered**:
- Separate `ensureInitialized(orgId)` call from the cubit — rejected; adds complexity to cubit flow and requires the cubit to orchestrate multiple async operations before subscribing.
- Lazy init on first `saveAll` — rejected; the spec (FR-003) requires defaults to appear on first page access, before any save.

---

## 6. Validation Location

**Decision**: Validation of time ranges and break constraints lives in `WorkingHoursRepositoryImpl._validateAll()`. This is a private method called at the top of `saveAllWorkingHours()` before delegating to the datasource.

**Rationale**: Matches the established pattern — `ServiceRepositoryImpl` and `OrganizationRepositoryImpl` both have private `_validate()` methods. The repository impl is the application boundary where business rules are enforced before touching Firestore.

**Time comparison method**: Pure Dart helper `_timeToMinutes(String time)` parses `"HH:mm"` to total minutes — no Flutter import needed, keeps domain layer pure.

**Alternatives considered**: Validation in the entity — rejected; entities are value objects with no behavior in this codebase (`Equatable` only). Validation in the cubit — rejected; business rules must not live in the presentation layer.

---

## 7. QR Code Generation Package

**Decision**: `qr_flutter: ^4.1.0`

**Rationale**: The standard Flutter QR display package. Actively maintained, compatible with Flutter 3.x/Dart 3.x, renders via `QrImageView` widget. For download, the widget is wrapped in `RepaintBoundary`; `RenderRepaintBoundary.toImage()` produces a `dart:ui.Image` that is converted to PNG bytes via `image.toByteData(format: ImageByteFormat.png)`.

**Alternatives considered**: `pretty_qr_code` — rejected; extra customization overhead not needed for this sprint. Server-side generation — rejected; spec FR-015 explicitly requires client-side generation.

---

## 8. Native Share Package

**Decision**: `share_plus: ^10.1.4`

**Rationale**: The standard Flutter share package. Found as a transitive dependency in the Android build folder, confirming compatibility with the existing dependency tree. Supports sharing text, URLs, and files (XFile) via the native share sheet on both iOS and Android.

**Alternatives considered**: `flutter_share_me` — rejected; less maintained. Direct clipboard-only — rejected; spec FR-016 requires native share sheet.

---

## 9. QR Image Save to Gallery

**Decision**: `gal: ^2.3.0`

**Rationale**: Lightweight, modern package for saving images to the system gallery. Handles Android `MediaStore` API (no `WRITE_EXTERNAL_STORAGE` needed on API 33+) and iOS `PHPhotoLibrary` internally. Simpler API than `image_gallery_saver` (`Gal.putImageBytes(bytes)`).

**Required permissions**:
- **Android** (`AndroidManifest.xml`): `WRITE_EXTERNAL_STORAGE` for API < 33 (optional — `gal` requests at runtime on newer APIs). Add `android:requestLegacyExternalStorage="true"` in `<application>` for API 29-32 if needed.
- **iOS** (`Info.plist`): `NSPhotoLibraryAddUsageDescription` string — required by App Store.

**Alternatives considered**: `image_gallery_saver` — older package, fewer recent updates. `path_provider` + file write — requires manual permission handling, OS-specific gallery integration.

---

## 10. ShareAccessCubit Design — No Repository Needed

**Decision**: `ShareAccessCubit` depends only on `AppLogger`. It receives the `bookingLinkSlug` from the parent context (read from the already-loaded `OrganizationCubit` state in the page widget), constructs the URL, and performs share/copy/download actions.

**Rationale**: Share Access has zero Firestore reads or writes. All operations are local UI actions (clipboard, native share, gallery write). Injecting `OrganizationRepository` would be over-engineering for this use case.

**Alternatives considered**: `ShareAccessCubit(OrganizationRepository)` — rejected; unnecessary Firestore read when org data is already in scope via `OrganizationCubit`. Stateless widget with direct actions — rejected; download is async with failure states that need cubit management.

---

## 11. WorkingHoursCubit States Design

**Decision**: Two distinct error states: `WorkingHoursStreamError` (for read stream failures) and `WorkingHoursSaveError` (for write failures). This mirrors the `ServiceCubit` pattern (`ServiceError` vs `ServiceMutationError`).

**Rationale**: Stream errors are persistent (the stream is broken; user may need to retry or restart the page). Save errors are transient (the loaded list is still valid; user edits are preserved and can be retried). Mixing them into one `error` state would force the UI to re-render the full page on a save failure, discarding the user's in-progress edits.

**Alternatives considered**: Single error state with a boolean `isStreamError` flag — rejected; sealed class exhaustive matching gives compile-time safety and clearer UI branching.

---

## 12. Admin Navigation: Dashboard Updates Required

**Finding**: The Admin Dashboard (`admin_dashboard_tab.dart`) already has:
- A `_ManagementCard` for "Working Hours" calling `_showComingSoon`
- A `_ShareAccessCard` (full-width CTA) calling `_showComingSoon`

The Admin Settings page (`settings_page.dart`) already has:
- An "Organization" section with "Working Hours" and "Share Access" tiles — both calling `_showComingSoon`

**Decision**: Replace both `_showComingSoon` calls in the dashboard AND the settings page tiles with actual `context.push(Routes.adminWorkingHours)` / `context.push(Routes.adminShareAccess)` navigation. No structural changes to either page are needed — only wiring up existing stubs.

**Alternatives considered**: Adding a new "Organization Settings" section to the dashboard — rejected; the spec FR-000 says "expose a new Organization Settings section" which already exists structurally in both the management grid and the settings page. The "section" requirement is satisfied by the existing layout.

---

## 13. GoRouter Routes to Add

```
/a/working-hours   → WorkingHoursPage
/a/share-access    → ShareAccessPage
```

Both fall under the existing `/a/...` auth guard — no additional redirect logic needed. `BlocProvider<WorkingHoursCubit>` and `BlocProvider<ShareAccessCubit>` wrap their respective pages in the route `builder`.
