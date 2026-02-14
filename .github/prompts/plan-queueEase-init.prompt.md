## Plan: Project Initialization (Flutter + Firebase MVP)

Initialize the repo from the default Flutter template into an MVP-ready scaffold: folder structure, dependencies, Firebase wiring, RBAC setup, Git workflow, and CI/CD pipelines. Feature implementation details belong in separate plans.

---

### 1. Lock Project Identifiers
- Set Android `applicationId` in `android/app/build.gradle.kts` (e.g. `com.yourcompany.queueease`).
- Update app display name in Android manifest resources.
- Keep `dart format` and `flutter_lints` as non-negotiable.

---

### 2. Add Core Packages
Update `pubspec.yaml`:
- **Navigation:** `go_router`
- **State:** `flutter_bloc`, `equatable`
- **Firebase:** `firebase_core`, `firebase_auth`, `google_sign_in`, `cloud_firestore`
- **Crash reporting:** `firebase_crashlytics`
- **Utilities:** `intl`, `uuid`
- **DI:** `get_it`, `injectable`
- **Dev (codegen):** `build_runner`, `injectable_generator`

---

### 3. Create Clean Architecture Folder Structure
```
lib/
├── main.dart                        # Bootstrap + Firebase.initializeApp
├── core/                            # Shared app infrastructure
│   ├── app/                         # App widget, router, theme, DI
│   ├── widgets/                     # Shared UI widgets
│   └── utils/                       # Shared helpers, constants
│
├── shared/                          # Shared features (used by both roles)
│   ├── auth/                        # Login/signup, role resolution
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── organization/                # Org landing, services catalog (read)
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── booking/                     # Time slot selection, create booking
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── queue/                       # Queue status domain (shared read)
│       ├── domain/
│       ├── data/
│       └── presentation/
│
├── customer/                        # Customer module (contains sub-features)
│   ├── entry/                       # QR/link entry flow
│   │   └── presentation/
│   ├── booking_flow/                # Customer booking screens
│   │   └── presentation/
│   └── queue_status/                # Customer live queue UI
│       └── presentation/
│
└── admin/                           # Admin module (contains sub-features)
   ├── dashboard/                   # Admin home, navigation hub (presentation-only)
   │   └── presentation/
   ├── services/                    # Service management (CRUD)
   │   ├── domain/
   │   ├── data/
   │   └── presentation/
   ├── working_hours/               # Working hours setup
   │   ├── domain/
   │   ├── data/
   │   └── presentation/
   ├── queue_management/            # Today's queue actions (next, skip, no-show, reorder)
   │   ├── domain/
   │   ├── data/
   │   └── presentation/
   ├── share_access/                # QR code & booking link generation (presentation-only)
   │   └── presentation/
   └── daily_summary/               # End-of-day stats
      ├── domain/
      ├── data/
      └── presentation/
```

**Structure rules:**
- `core/` = shared app infrastructure only.
- `shared/` = shared features used by both roles; each shared feature uses `domain/`, `data/`, `presentation/`.
- `customer/` = customer module with its own feature folders; use `domain/` and `data/` if customer-only logic appears.
- `admin/` = admin module with sub-features, each with its own Clean Architecture layers where needed.
- Sub-features that are presentation-only (dashboard, share_access) skip `domain/` and `data/` layers.

Each feature/sub-feature follows Clean Architecture layers as needed:
- `domain/` → entities, repository contracts, use cases
- `data/` → datasources, models, repository implementations
- `presentation/` → bloc, pages, widgets

---

### 4. Role-Based Access Control (RBAC)

**Concept:** Two roles - `admin` and `customer`. Role is stored in Firestore `users/{uid}` doc and resolved after login.
**Role assignment:** Admin role is assigned during signup via whitelist/invite checks (stored in Firestore), with the first admin set manually.

**Client-side enforcement:**
1. `AuthBloc` emits authenticated state including resolved `role`.
2. `go_router` redirect logic checks role:
   - `/a/...` routes require `role == admin`; otherwise redirect to `/c/...`.
   - `/c/...` routes require `role == customer`; otherwise redirect to `/a/...`.
   - Unauthenticated users on protected routes redirect to `/login` with return path.
3. Deep link `/o/:orgId` resolves to `/c/o/:orgId` for customers; admins are redirected to `/a/customer-view/:orgId` which renders the customer org landing in the admin shell.

**Server-side enforcement (critical):**
- Firestore Security Rules check `request.auth.uid` and role from user doc before allowing writes.
- Admin-only mutations (queue actions, service management) require `role == admin` in rules or callable Cloud Functions.

---

### 5. Initialize Firebase (Android-only MVP)
- Create Firebase project; add Android app with finalized `applicationId`.
- Run `flutterfire configure` to generate `firebase_options.dart`.
- Add Google Services plugin to Android Gradle files.
- Wire `Firebase.initializeApp()` in `main.dart`.
- Enable Crashlytics:
   - Add Crashlytics Gradle plugin for Android.
   - Initialize Crashlytics in app startup and forward Flutter errors.
   - Disable Crashlytics in debug builds by default (use flavors to gate it if needed).

---

### 6. Assets & Theme Scaffold
- Create `assets/images/`, `assets/icons/`, `assets/fonts/`.
- Add initial assets from design mocks:
   - App icon (adaptive + legacy) and app logo.
   - UI icons used in queue status and admin actions.
   - Fonts (Inter family files).
- Register assets and fonts in `pubspec.yaml`.
- Add `lib/core/app/theme/` with starter files:
   - `app_colors.dart` for brand colors and semantic colors.
   - `app_theme.dart` for `ThemeData` with typography and component defaults.
   - `app_text_styles.dart` for common text styles.

---

### 7. Native Splash (flutter_native_splash)
- Add `flutter_native_splash` to `dev_dependencies`.
- Create `flutter_native_splash` config in `pubspec.yaml`:
   - Background color matches brand primary.
   - Centered logo from `assets/images/`.
- Run `dart run flutter_native_splash:create` after assets are in place.

---

### 8. Dependency Injection Setup (get_it + injectable)
- Create `lib/core/app/di/`.
- Add `di.config.dart` generation via `build_runner`.
- Register core singletons (Firebase, repositories, blocs) through `injectable`.

---

### 9. Git Workflow & Branching Strategy

**Branches:**
| Branch | Purpose |
|--------|---------|
| `main` | Production-ready; protected; deploy trigger |
| `develop` | Integration branch; PR target for features |
| `feature/<name>` | One feature or task; branch from `develop` |
| `fix/<name>` | Bug fixes; branch from `develop` or `main` (hotfix) |
| `release/<version>` | Release prep; created from `develop` before deploy |

**Rules:**
- All changes via PR; no direct pushes to `main` or `develop`.
- Require at least 1 approval + passing CI before merge.
- Squash-merge features; merge commits for releases.

---

### 10. CI/CD Pipeline (GitHub Actions)

**Workflows to create:**

1. **ci.yml** (runs on every PR and push to `develop`/`main`)
   - Checkout + setup Flutter
   - `flutter pub get`
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`

2. **build-android.yml** (runs on push to `main` or manual trigger)
   - Same setup as CI
   - `flutter build apk --release`
   - Upload **unsigned** release APK artifact (no keystore in CI)

3. **firebase-deploy.yml** (optional, for Functions/Hosting)
   - Deploy Cloud Functions on push to `main`
   - Deploy Firestore rules on push to `main`

**Secrets required:** `FIREBASE_TOKEN` (or use Workload Identity Federation).

---

### 11. Testing Strategy (Init Phase)

| Layer | What to test | Tools |
|-------|--------------|-------|
| Unit | Use cases, BLoC logic, pure functions | `flutter_test`, `bloc_test`, `mocktail` |
| Widget | Individual widgets render correctly | `flutter_test` |
| Integration | Full user flows (auth, booking) | `integration_test` package |

**Init deliverable:** Create `test/` mirror of `lib/shared/`, `lib/customer/`, and `lib/admin/` with placeholder test files so CI passes from day one.

---

### 12. Verification Checklist
- [ ] `flutter analyze` passes with no issues.
- [ ] `flutter test` runs (even if tests are minimal placeholders).
- [ ] App launches on Android emulator -> splash -> login screen.
- [ ] Firebase Auth (email + Google) works end-to-end.
- [ ] Role resolution redirects to correct home (admin vs customer).
- [ ] CI pipeline runs green on a test PR.

---

### Deliverables (Initialization Complete)
- App boots with Firebase initialized and routing wired.
- Core folder structure and admin/customer modules created.
- RBAC redirects implemented and validated on a test role.
- Native splash configured and generated.
- Base theme files in place (`app_colors.dart`, `app_theme.dart`, `app_text_styles.dart`).
- Assets registered (icons, fonts, logo).
- DI container bootstrapped with `get_it` + `injectable`.
- Crashlytics wired for crash reporting.
- CI runs green (format, analyze, test) and Android build workflow works.
- CI produces an **unsigned** release APK artifact.

---

### Decisions Summary
| Decision | Choice |
|----------|--------|
| State management | BLoC + Equatable |
| Navigation | go_router |
| Auth | Firebase Auth (Email/Password + Google) |
| Backend | Firestore + Cloud Functions |
| Platform (MVP) | Android only |
| Deep links | App Links (HTTPS URL with orgId) |
| Branching | GitFlow-style (main + develop + feature/release) |
| CI/CD | GitHub Actions |

---

**Out of scope for this init plan:** Data model details, feature implementation, notifications, analytics. Those belong in dedicated feature plans.
