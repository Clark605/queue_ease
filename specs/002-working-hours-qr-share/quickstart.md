# Quickstart: Working Hours & QR/Share Access
**Sprint**: Sprint 3 | **Branch**: `002-working-hours-qr-share`

---

## Prerequisites

- Flutter SDK ≥ 3.9.0 on the `stable` channel (`flutter channel stable && flutter upgrade`)
- Dart SDK ≥ 3.9.0 (bundled with Flutter)
- Firebase CLI authenticated (`firebase login`)
- Branch checked out: `git checkout 002-working-hours-qr-share`

---

## 1. Add New Packages

```bash
flutter pub add qr_flutter share_plus gal
```

Then verify `pubspec.yaml` reflects the additions, and run:

```bash
flutter pub get
```

Expected new entries in `pubspec.yaml`:
```yaml
qr_flutter: ^4.1.0
share_plus: ^10.1.4
gal: ^2.3.0
```

---

## 2. Platform Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

Add inside `<manifest>` (before `<application>`):
```xml
<!-- Required by gal for saving to gallery on Android < 13 (API 33) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

Add inside `<application>`:
```xml
android:requestLegacyExternalStorage="true"
```

### iOS (`ios/Runner/Info.plist`)

Add inside the root `<dict>`:
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>QueueEase needs access to your photo library to save your QR code image.</string>
```

---

## 3. Update Firestore Security Rules

Edit `firestore.rules` — in the `working_hours` subcollection block, update both `allow create` and `allow update` `hasOnlyAllowedFields` calls to include `breakStart` and `breakEnd`:

```
# Before:
hasOnlyAllowedFields(['orgId','dayOfWeek','isOpen','openTime','closeTime','createdAt','updatedAt'])

# After (both create and update):
hasOnlyAllowedFields(['orgId','dayOfWeek','isOpen','openTime','closeTime','breakStart','breakEnd','createdAt','updatedAt'])
```

Also add HH:mm format validation for break fields in the conditional block.

Deploy updated rules to the dev Firebase project:
```bash
firebase deploy --only firestore:rules --project <dev-project-id>
```

---

## 4. Regenerate DI After Adding New Registrations

After adding `@lazySingleton` / `@LazySingleton` / `@injectable` annotations to new classes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/core/app/di/injection.config.dart`. The new datasource, repository, and cubits are automatically registered in the DI container once their annotations are in place.

---

## 5. Run the App

```bash
# Dev flavor (uses Firebase dev project)
flutter run --target lib/main_dev.dart --flavor dev

# Or release build for testing
flutter run --target lib/main_dev.dart --flavor dev --release
```

Navigate: **Admin Dashboard → Working Hours card** (or **Settings → Organization → Working Hours**)

---

## 6. Verify Working Hours Flow

1. Launch app as an admin with a linked organization
2. Navigate to Working Hours page
3. Confirm all 7 days appear with defaults (Mon–Fri open 09:00–17:00, Sat–Sun closed)
4. Toggle Saturday to open, set times to 10:00–14:00
5. Tap Save All — confirm success snackbar
6. Navigate away and back — confirm Saturday shows 10:00–14:00

---

## 7. Verify QR/Share Flow

1. Navigate to Share Access page (Admin Dashboard → Share Access card)
2. Confirm QR code is displayed (encodes `https://queueease.app/org/{slug}`)
3. Tap "Copy Link" — confirm clipboard toast
4. Tap "Share" — confirm native share sheet opens
5. Tap "Download QR" — confirm image saved to device gallery

---

## Key File Locations

| What | Where |
|------|-------|
| Domain entity | `lib/shared/organization/domain/entities/working_hours_entity.dart` |
| Firestore model | `lib/shared/organization/data/models/working_hours_model.dart` |
| Repository interface | `lib/shared/organization/domain/repositories/working_hours_repository.dart` |
| Datasource | `lib/shared/organization/data/datasources/firestore_working_hours_datasource.dart` |
| Repository impl | `lib/shared/organization/data/repositories/working_hours_repository_impl.dart` |
| Working Hours cubit | `lib/admin/working_hours/presentation/cubit/` |
| Working Hours page | `lib/admin/working_hours/presentation/pages/working_hours_page.dart` |
| Share Access cubit | `lib/admin/share_access/presentation/cubit/` |
| Share Access page | `lib/admin/share_access/presentation/pages/share_access_page.dart` |
| Routes | `lib/core/app/router/app_router.dart` |
| Security rules | `firestore.rules` |
