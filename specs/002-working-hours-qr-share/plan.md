# Implementation Plan: Working Hours Configuration & QR/Share Access

**Branch**: `002-working-hours-qr-share` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/002-working-hours-qr-share/spec.md`

---

## Summary

Implement admin-facing Working Hours configuration and QR/Share Access pages for Sprint 3. Admins can configure a weekly schedule (open/closed toggling, time-range setting per day, optional break periods) and save all 7 days as an atomic batch. They can also view, share, copy, and download a QR code that encodes their organization's booking URL.

**Technical approach**: Extend the existing `lib/shared/organization/` data and domain layers with a new `working_hours_repository` stack following the established `ServiceRepository` / `ServiceRepositoryImpl` pattern. Add two new presentation features — `working_hours` and `share_access` — each backed by a dedicated Cubit. Wire the two new routes into GoRouter and connect the existing stub cards on the admin dashboard and settings page to the real pages. Three new packages are required: `qr_flutter` (QR rendering), `share_plus` (native share sheet), and `gal` (gallery save).

A **blocker must be resolved first**: the existing `firestore.rules` do not allow `breakStart`/`breakEnd` fields in `working_hours` documents. Rules must be updated and deployed before any Firestore write can succeed.

---

## Technical Context

**Language/Version**: Dart 3.9.0+ / Flutter 3.9.0+  
**Primary Dependencies**: flutter_bloc (Cubit), GetIt + Injectable, GoRouter 17.1.0, Firebase (Auth + Firestore + Crashlytics), Talker, qr_flutter, share_plus, gal  
**Storage**: Cloud Firestore — subcollection `organizations/{orgId}/working_hours/{dayOfWeek}`  
**Testing**: Deferred to Sprint 8 (team decision). No test files are created in this sprint.  
**Target Platform**: Android (API 21+), iOS 13+  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Save All write < 2s under poor network; QR code render < 300ms; screen navigation < 300ms  
**Constraints**: Offline-first (Firestore cached reads); domain layer must remain framework-agnostic (no Flutter imports); Firestore rules must be deployed before any write is testable  
**Scale/Scope**: 7 Firestore documents per organization, 2 new screens, 2 new cubits, 1 new repository stack

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Code Quality / Clean Architecture** | ✅ PASS | Domain layer stays framework-free. Repository interface in domain, impl in data. Presentation uses Cubit only — no direct Firestore access. |
| **II. Flexibility & Extensibility** | ✅ PASS | Feature modules in `lib/admin/working_hours/` and `lib/admin/share_access/` are independent. Shared data lives in `lib/shared/organization/`. New features do not touch unrelated feature code. |
| **III. Testing Standards** | ⚠️ DEFERRED | Tests are deferred to Sprint 8 per team decision. Documented as an explicit assumption in spec.md. This is an accepted sprint-level exception. |
| **IV. UX Consistency** | ✅ PASS | Material 3, AppLoadingIndicator, AppErrorWidget reused. Time picker via `showTimePicker`. Snackbar for success/error. All interactive elements ≥ 48×48 tap targets. |
| **V. Fast Delivery** | ✅ PASS | P1 (Working Hours) and P2 (Break Times) are the focus. P3/P4 (QR/Share/Download) are secondary. All stories are independently testable. |
| **VI. Performance Requirements** | ✅ PASS | WriteBatch for atomic 7-doc write. Real-time stream via Firestore snapshots. `const` constructors used throughout. QR generation is client-side, synchronous. |

**Post-design re-check**:
- Constitution Check still passes after Phase 1 design
- **Critical**: Firestore rules update (breaking blocker) is the first implementation task — no principle violation, it's a maintenance fix required by the new break-time feature

---

## Project Structure

### Documentation (this feature)

```text
specs/002-working-hours-qr-share/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/
│   ├── working_hours_repository.dart   ← abstract interface contract
│   └── cubit_states.dart               ← state hierarchy contracts
└── tasks.md             ← Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
firestore.rules                                         ← MODIFY: add breakStart/breakEnd
pubspec.yaml                                            ← MODIFY: add qr_flutter, share_plus, gal
android/app/src/main/AndroidManifest.xml                ← MODIFY: add WRITE_EXTERNAL_STORAGE
ios/Runner/Info.plist                                   ← MODIFY: add NSPhotoLibraryAddUsageDescription

lib/
├── core/
│   └── app/
│       └── router/
│           └── app_router.dart                         ← MODIFY: add /a/working-hours, /a/share-access
│
├── shared/
│   └── organization/
│       ├── domain/
│       │   └── repositories/
│       │       └── working_hours_repository.dart       ← NEW: abstract interface
│       └── data/
│           ├── datasources/
│           │   └── firestore_working_hours_datasource.dart  ← NEW
│           └── repositories/
│               └── working_hours_repository_impl.dart  ← NEW
│
├── admin/
│   ├── dashboard/
│   │   └── presentation/
│   │       └── pages/
│   │           └── admin_dashboard_tab.dart            ← MODIFY: wire stub cards
│   │
│   ├── presentation/
│   │   └── pages/
│   │       └── settings_page.dart                      ← MODIFY: wire stub tiles
│   │
│   ├── working_hours/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── working_hours_cubit.dart             ← NEW
│   │       │   └── working_hours_state.dart             ← NEW
│   │       ├── pages/
│   │       │   └── working_hours_page.dart              ← NEW
│   │       └── widgets/
│   │           ├── day_working_hours_tile.dart          ← NEW
│   │           └── break_time_section.dart              ← NEW
│   │
│   └── share_access/
│       └── presentation/
│           ├── cubit/
│           │   ├── share_access_cubit.dart              ← NEW
│           │   └── share_access_state.dart              ← NEW
│           ├── pages/
│           │   └── share_access_page.dart               ← NEW
│           └── widgets/
│               ├── qr_code_display.dart                 ← NEW
│               └── share_action_buttons.dart            ← NEW
│
└── core/
    └── app/
        └── di/
            └── injection.config.dart                    ← AUTO-GENERATED by build_runner

test/                                                    ← No test files this sprint
```

**Structure Decision**: Shared data/domain layers (`WorkingHoursRepository`, `FirestoreWorkingHoursDatasource`, `WorkingHoursRepositoryImpl`) live in `lib/shared/organization/` to follow the existing `ServiceRepository` / `OrganizationRepository` pattern. Presentation layers (cubits, pages, widgets) are isolated in their respective admin feature folders (`working_hours/`, `share_access/`). This mirrors `lib/admin/services/` exactly.

---

## Implementation Phases

### Phase 0: Blocker Resolution

**Must be done first** — Firestore writes will be silently rejected until rules are deployed.

#### Task P0-1: Update Firestore Security Rules

**File**: `firestore.rules`

In the `match /working_hours/{dayOfWeek}` block, add `'breakStart'` and `'breakEnd'` to `hasOnlyAllowedFields` in both `allow create` and `allow update`. Also add conditional HH:mm validation for break fields:

```
// allow create — change this line:
hasOnlyAllowedFields(['orgId','dayOfWeek','isOpen','openTime','closeTime','createdAt','updatedAt'])
// to:
hasOnlyAllowedFields(['orgId','dayOfWeek','isOpen','openTime','closeTime','breakStart','breakEnd','createdAt','updatedAt'])

// Also add to the conditional block (after openTime/closeTime validation):
&& (!('breakStart' in request.resource.data) || (
  request.resource.data.breakStart is string
  && request.resource.data.breakStart.matches('^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
  && request.resource.data.breakEnd is string
  && request.resource.data.breakEnd.matches('^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
))
```

Apply the same change to `allow update`. Then deploy:
```bash
firebase deploy --only firestore:rules --project <dev-project-id>
```

#### Task P0-2: Add Packages and Platform Permissions

**File**: `pubspec.yaml`

```yaml
dependencies:
  # QR code rendering (client-side)
  qr_flutter: ^4.1.0
  # Native share sheet (text + files)
  share_plus: ^12.0.1
  # Save image to device gallery
  gal: ^2.3.0
```

Run `flutter pub get` after editing.

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**File**: `ios/Runner/Info.plist`
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>QueueEase needs access to your photo library to save your QR code image.</string>
```

---

### Phase 1: Data Layer — Working Hours

#### Task 1-1: `WorkingHoursRepository` Abstract Interface

**File**: `lib/shared/organization/domain/repositories/working_hours_repository.dart`

```dart
import '../entities/working_hours_entity.dart';
import '../../../../core/error/result.dart';

abstract class WorkingHoursRepository {
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId);

  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  });
}
```

No annotations — domain layer is framework-free.

---

#### Task 1-2: `FirestoreWorkingHoursDatasource`

**File**: `lib/shared/organization/data/datasources/firestore_working_hours_datasource.dart`

```dart
@lazySingleton
class FirestoreWorkingHoursDatasource {
  FirestoreWorkingHoursDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _collection(String orgId) =>
      _firestore.collection('organizations/$orgId/working_hours');

  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) =>
      _collection(orgId).orderBy(FieldPath.documentId).snapshots().asyncMap(
        (snapshot) async {
          if (snapshot.docs.isEmpty) {
            _logger.info('FirestoreWorkingHoursDatasource: initializing defaults → orgId=$orgId');
            await _initializeDefaults(orgId);
            return _defaultEntities(orgId);
          }
          return snapshot.docs
              .map((doc) => WorkingHoursModel.fromDoc(doc, orgId: orgId).toEntity())
              .toList();
        },
      );

  Future<void> saveAll(String orgId, List<WorkingHoursEntity> days) async {
    _logger.debug('FirestoreWorkingHoursDatasource: saveAll → orgId=$orgId, days=${days.length}');
    try {
      final batch = _firestore.batch();
      for (final entity in days) {
        final docRef = _collection(orgId).doc(entity.dayOfWeek.toString());
        batch.update(docRef, {
          ...WorkingHoursModel(
            orgId: entity.orgId,
            dayOfWeek: entity.dayOfWeek,
            isOpen: entity.isOpen,
            openTime: entity.openTime,
            closeTime: entity.closeTime,
            breakStart: entity.breakStart,
            breakEnd: entity.breakEnd,
          ).toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } on FirebaseException catch (e, st) {
      _logger.error('FirestoreWorkingHoursDatasource: saveAll failed', e, st);
      throw DatabaseException('Failed to save working hours.', stackTrace: st);
    } catch (e, st) {
      _logger.error('FirestoreWorkingHoursDatasource: saveAll unexpected error', e, st);
      throw UnknownException('Unexpected error saving working hours.', cause: e, stackTrace: st);
    }
  }

  Future<void> _initializeDefaults(String orgId) async {
    final batch = _firestore.batch();
    for (final entity in _defaultEntities(orgId)) {
      final docRef = _collection(orgId).doc(entity.dayOfWeek.toString());
      batch.set(docRef, {
        'orgId': orgId,
        'dayOfWeek': entity.dayOfWeek,
        'isOpen': entity.isOpen,
        'openTime': entity.openTime,
        'closeTime': entity.closeTime,
        'breakStart': entity.breakStart,
        'breakEnd': entity.breakEnd,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  List<WorkingHoursEntity> _defaultEntities(String orgId) => List.generate(7, (i) =>
      WorkingHoursEntity(
        orgId: orgId,
        dayOfWeek: i,
        isOpen: i < 5,      // Mon–Fri open, Sat–Sun closed
        openTime: '09:00',
        closeTime: '17:00',
      ));
}
```

---

#### Task 1-3: `WorkingHoursRepositoryImpl`

**File**: `lib/shared/organization/data/repositories/working_hours_repository_impl.dart`

```dart
@LazySingleton(as: WorkingHoursRepository)
class WorkingHoursRepositoryImpl implements WorkingHoursRepository {
  WorkingHoursRepositoryImpl(this._datasource, this._logger);

  final FirestoreWorkingHoursDatasource _datasource;
  final AppLogger _logger;

  @override
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) =>
      _datasource.watchWorkingHours(orgId);

  @override
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  }) {
    return Result.guard(() async {
      _validateAll(days);
      await _datasource.saveAll(orgId, days);
    });
  }

  void _validateAll(List<WorkingHoursEntity> days) {
    for (final day in days.where((d) => d.isOpen)) {
      final open = _toMinutes(day.openTime);
      final close = _toMinutes(day.closeTime);
      if (close <= open) {
        throw ValidationException(
          'Day ${day.dayOfWeek}: close time must be after open time.',
          field: 'closeTime',
        );
      }
      if (day.breakStart != null || day.breakEnd != null) {
        if (day.breakStart == null || day.breakEnd == null) {
          throw ValidationException(
            'Day ${day.dayOfWeek}: both break start and end are required.',
            field: 'breakStart',
          );
        }
        final bs = _toMinutes(day.breakStart!);
        final be = _toMinutes(day.breakEnd!);
        if (bs < open || be > close || be <= bs) {
          throw ValidationException(
            'Day ${day.dayOfWeek}: break must be within working hours and have a positive duration.',
            field: 'breakStart',
          );
        }
      }
    }
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
```

#### Task 1-4: Regenerate DI

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify `injection.config.dart` contains entries for `FirestoreWorkingHoursDatasource` and `WorkingHoursRepository`.

---

### Phase 2: Working Hours Presentation

#### Task 2-1: `WorkingHoursState`

**File**: `lib/admin/working_hours/presentation/cubit/working_hours_state.dart`

```dart
sealed class WorkingHoursState extends Equatable { const WorkingHoursState(); }

final class WorkingHoursInitial extends WorkingHoursState { const WorkingHoursInitial(); @override List<Object?> get props => []; }
final class WorkingHoursLoading extends WorkingHoursState { const WorkingHoursLoading(); @override List<Object?> get props => []; }
final class WorkingHoursLoaded extends WorkingHoursState {
  const WorkingHoursLoaded(this.days);
  final List<WorkingHoursEntity> days;
  @override List<Object?> get props => [days];
}
final class WorkingHoursSaving extends WorkingHoursState { const WorkingHoursSaving(); @override List<Object?> get props => []; }
final class WorkingHoursSaveSuccess extends WorkingHoursState { const WorkingHoursSaveSuccess(); @override List<Object?> get props => []; }
final class WorkingHoursSaveError extends WorkingHoursState {
  const WorkingHoursSaveError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
final class WorkingHoursStreamError extends WorkingHoursState {
  const WorkingHoursStreamError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
```

---

#### Task 2-2: `WorkingHoursCubit`

**File**: `lib/admin/working_hours/presentation/cubit/working_hours_cubit.dart`

```dart
@injectable
class WorkingHoursCubit extends Cubit<WorkingHoursState> {
  WorkingHoursCubit(this._repository, this._logger)
      : super(const WorkingHoursInitial());

  final WorkingHoursRepository _repository;
  final AppLogger _logger;
  StreamSubscription<List<WorkingHoursEntity>>? _subscription;

  Future<void> watchWorkingHours(String orgId) async {
    _logger.info('WorkingHoursCubit: watchWorkingHours → $orgId');
    emit(const WorkingHoursLoading());
    await _subscription?.cancel();
    _subscription = _repository.watchWorkingHours(orgId).listen(
      (days) => emit(WorkingHoursLoaded(days)),
      onError: (error, stackTrace) {
        _logger.error('WorkingHoursCubit: stream error', error, stackTrace);
        emit(WorkingHoursStreamError(
          error is AppException ? error.message : 'Failed to load working hours.',
        ));
      },
    );
  }

  Future<void> saveAll({
    required String orgId,
    required List<WorkingHoursEntity> days,
  }) async {
    _logger.info('WorkingHoursCubit: saveAll → orgId=$orgId');
    emit(const WorkingHoursSaving());
    final result = await _repository.saveAllWorkingHours(orgId: orgId, days: days);
    switch (result) {
      case Success():
        emit(const WorkingHoursSaveSuccess());
      case Failure(:final exception):
        _logger.error('WorkingHoursCubit: saveAll failed', exception);
        emit(WorkingHoursSaveError(exception.message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

---

#### Task 2-3: `WorkingHoursPage`

**File**: `lib/admin/working_hours/presentation/pages/working_hours_page.dart`

Key responsibilities:
- `initState`: reads `orgId` from `OrganizationCubit` and calls `cubit.watchWorkingHours(orgId)`
- Local state: `List<WorkingHoursEntity> _pendingDays` — copy of the stream data, modified by tile interactions
- `BlocConsumer` on `WorkingHoursCubit`:
  - `buildWhen`: only rebuilds on `WorkingHoursLoaded` and `WorkingHoursStreamError` (not on saving/success/saveError to avoid resetting tile state)
  - `listenWhen`: listens on all states for snackbar/overlay feedback
  - `listener`: shows success snackbar on `WorkingHoursSaveSuccess`, error snackbar on `WorkingHoursSaveError`, resets `_pendingDays` from stream data on `WorkingHoursLoaded`
- **Save All button**: passes `_pendingDays` to `cubit.saveAll(orgId, _pendingDays)`; disabled while `WorkingHoursSaving`
- Uses `AppLoadingIndicator` for `WorkingHoursLoading` state, `AppErrorWidget` for `WorkingHoursStreamError`
- `ListView.builder` for 7 `DayWorkingHoursTile` widgets

---

#### Task 2-4: `DayWorkingHoursTile`

**File**: `lib/admin/working_hours/presentation/widgets/day_working_hours_tile.dart`

A `StatefulWidget` representing one day row. Receives a `WorkingHoursEntity` and an `onChanged(WorkingHoursEntity)` callback.

UI layout:
- Row: day name (Mon/Tue …) + open/closed `Switch`
- If open: `TextButton` for open time + `TextButton` for close time (taps open `showTimePicker`)
- If open: `BreakTimeSection` widget (optional break toggle + break times)

On any change, calls `onChanged` with the updated entity, so the page can update `_pendingDays`.

---

#### Task 2-5: `BreakTimeSection`

**File**: `lib/admin/working_hours/presentation/widgets/break_time_section.dart`

A `StatefulWidget` shown inside `DayWorkingHoursTile` when the day is open.

- Break toggle switch
- If break enabled: two `TextButton` time pickers (breakStart, breakEnd)
- Calls its `onChanged(String? breakStart, String? breakEnd)` callback

---

### Phase 3: Share Access Presentation

#### Task 3-1: `ShareAccessState`

**File**: `lib/admin/share_access/presentation/cubit/share_access_state.dart`

```dart
sealed class ShareAccessState extends Equatable { const ShareAccessState(); }
final class ShareAccessInitial extends ShareAccessState { ... }
final class ShareAccessLinkCopied extends ShareAccessState { ... }
final class ShareAccessDownloading extends ShareAccessState { ... }
final class ShareAccessDownloaded extends ShareAccessState { ... }
final class ShareAccessError extends ShareAccessState {
  const ShareAccessError(this.message);
  final String message;
  ...
}
```

---

#### Task 3-2: `ShareAccessCubit`

**File**: `lib/admin/share_access/presentation/cubit/share_access_cubit.dart`

```dart
@injectable
class ShareAccessCubit extends Cubit<ShareAccessState> {
  ShareAccessCubit(this._logger) : super(const ShareAccessInitial());
  final AppLogger _logger;

  Future<void> copyLink(String url) async {
    _logger.info('ShareAccessCubit: copyLink');
    await Clipboard.setData(ClipboardData(text: url));
    emit(const ShareAccessLinkCopied());
    // Reset to initial after brief feedback window
    await Future.delayed(const Duration(seconds: 2));
    if (!isClosed) emit(const ShareAccessInitial());
  }

  Future<void> shareContent({
    required String url,
    required Uint8List? qrBytes,
  }) async {
    _logger.info('ShareAccessCubit: shareContent');
    try {
      if (qrBytes != null) {
        await Share.shareXFiles(
          [XFile.fromData(qrBytes, mimeType: 'image/png', name: 'qr_code.png')],
          text: url,
        );
      } else {
        await Share.share(url);
      }
    } catch (e, st) {
      _logger.error('ShareAccessCubit: shareContent failed', e, st);
      emit(const ShareAccessError('Failed to open share sheet. Try copying the link instead.'));
    }
  }

  Future<void> downloadQrCode(Uint8List pngBytes) async {
    _logger.info('ShareAccessCubit: downloadQrCode');
    emit(const ShareAccessDownloading());
    try {
      await Gal.putImageBytes(pngBytes);
      emit(const ShareAccessDownloaded());
    } catch (e, st) {
      _logger.error('ShareAccessCubit: downloadQrCode failed', e, st);
      emit(const ShareAccessError('Could not save QR code to gallery. Check app permissions.'));
    }
  }
}
```

No repository — clipboard, share, and gallery are pure Flutter platform calls.

---

#### Task 3-3: `ShareAccessPage`

**File**: `lib/admin/share_access/presentation/pages/share_access_page.dart`

Key responsibilities:
- Reads `OrganizationCubit` from context to extract `bookingLinkSlug` → constructs `bookingUrl = 'https://queueease.app/org/$slug'`
- Uses `GlobalKey<State>` on `RepaintBoundary` wrapping `QrCodeDisplay` for PNG capture
- `BlocListener` on `ShareAccessCubit`: shows snackbar on `ShareAccessLinkCopied`, `ShareAccessDownloaded`, `ShareAccessError`
- Renders: `QrCodeDisplay`, booking URL text, three action buttons (`ShareActionButtons`)

PNG capture helper:
```dart
Future<Uint8List?> _captureQrBytes() async {
  final boundary = _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
```

---

#### Task 3-4: `QrCodeDisplay`

**File**: `lib/admin/share_access/presentation/widgets/qr_code_display.dart`

```dart
class QrCodeDisplay extends StatelessWidget {
  const QrCodeDisplay({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => QrImageView(
    data: url,
    version: QrVersions.auto,
    size: 220,
    backgroundColor: Colors.white,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );
}
```

Wrapped in `RepaintBoundary` at the page level for PNG capture.

---

#### Task 3-5: `ShareActionButtons`

**File**: `lib/admin/share_access/presentation/widgets/share_action_buttons.dart`

Three labeled buttons with icons:
- **Share**: `Icons.share` → calls `cubit.shareContent(url: url, qrBytes: captureQr())`
- **Copy Link**: `Icons.copy` → calls `cubit.copyLink(url)`
- **Download QR**: `Icons.download` → calls `cubit.downloadQrCode(captureQr())`

Download button shows `CircularProgressIndicator` during `ShareAccessDownloading` state.

---

### Phase 4: Navigation & Integration

#### Task 4-1: Add Routes to `app_router.dart`

**File**: `lib/core/app/router/app_router.dart`

```dart
abstract final class Routes {
  // ... existing routes ...
  static const String adminWorkingHours = '/a/working-hours';
  static const String adminShareAccess  = '/a/share-access';
}
```

Add two `GoRoute` entries in the admin routes list:
```dart
GoRoute(
  path: Routes.adminWorkingHours,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<WorkingHoursCubit>(),
    child: const WorkingHoursPage(),
  ),
),
GoRoute(
  path: Routes.adminShareAccess,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<ShareAccessCubit>(),
    child: const ShareAccessPage(),
  ),
),
```

The existing `/a/...` redirect guard covers both routes — no additional RBAC logic needed.

---

#### Task 4-2: Wire Dashboard Card Stubs

**File**: `lib/admin/dashboard/presentation/pages/admin_dashboard_tab.dart`

Replace the `_showComingSoon` callsite inside the existing "Working Hours" `_ManagementCard.onTap`:
```dart
// Before:
onTap: () => _showComingSoon(context),
// After:
onTap: () => context.push(Routes.adminWorkingHours),
```

Replace the `_showComingSoon` callsite inside `_ShareAccessCard.onTap`:
```dart
// Before:
onTap: () => _showComingSoon(context),
// After:
onTap: () => context.push(Routes.adminShareAccess),
```

---

#### Task 4-3: Wire Settings Page Tiles

**File**: `lib/admin/presentation/pages/settings_page.dart`

Replace both `_showComingSoon` calls under the "Organization" section:
```dart
// Working Hours tile
onTap: () => context.push(Routes.adminWorkingHours),

// Share Access tile
onTap: () => context.push(Routes.adminShareAccess),
```

---

## Dependency Graph

```
firestore.rules fix (P0-1)
    ↓
pubspec packages (P0-2)
    ↓
WorkingHoursRepository (1-1)
    ↓
FirestoreWorkingHoursDatasource (1-2)
    ↓
WorkingHoursRepositoryImpl (1-3)
    ↓
build_runner (1-4)
    ↓
WorkingHoursState (2-1)         ShareAccessState (3-1)
    ↓                               ↓
WorkingHoursCubit (2-2)         ShareAccessCubit (3-2)
    ↓                               ↓
WorkingHoursPage + Widgets      ShareAccessPage + Widgets
(2-3, 2-4, 2-5)                 (3-3, 3-4, 3-5)
    ↓                               ↓
        Routes & Navigation (4-1, 4-2, 4-3)
```

---

## Key Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Firestore collection name | `working_hours` (snake_case) | Matches existing security rules |
| dayOfWeek in doc data | Written by datasource | Security rules require `data.dayOfWeek == int(docId)` |
| Default initialization | `asyncMap` in datasource | Self-contained, no cubit orchestration needed |
| Write for save vs init | `batch.update()` for save, `batch.set()` for init | `createdAtNotModified()` rule enforcement |
| Validation location | `WorkingHoursRepositoryImpl._validateAll()` | Matches ServiceRepo / OrgRepo pattern |
| QR package | `qr_flutter` | Standard Flutter QR widget, actively maintained |
| Share package | `share_plus` | Standard cross-platform share sheet |
| Gallery save | `gal` | Lightweight, modern API, handles permissions internally |
| ShareAccessCubit dependencies | `AppLogger` only | No Firestore ops — clipboard, share, gallery are platform calls |
| Tests | Deferred Sprint 8 | Team decision; documented as explicit assumption in spec |
