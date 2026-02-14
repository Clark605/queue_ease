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
- **Utilities:** `intl`, `uuid`

---

### 3. Create Clean Architecture Folder Structure
```
lib/
├── main.dart                        # Bootstrap + Firebase.initializeApp
├── core/                            # Shared app infrastructure + shared features
│   ├── app/                         # App widget, router, theme, DI
│   ├── auth/                        # Login/signup, role resolution (shared)
│   ├── organization/                # Org landing, services catalog (shared read)
│   ├── booking/                     # Time slot selection, create booking (shared)
│   ├── queue/                       # Queue status domain (shared read)
│   ├── widgets/                     # Shared UI widgets
│   └── utils/                       # Shared helpers, constants
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
   ├── dashboard/                   # Admin home, navigation hub
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
   ├── share_access/                # QR code & booking link generation
   │   └── presentation/
   └── daily_summary/               # End-of-day stats
      ├── domain/
      ├── data/
      └── presentation/
```

**Structure rules:**
- `core/` = shared app infrastructure and shared features used by both roles.
- `customer/` = customer module with its own feature folders.
- `admin/` = admin module with sub-features, each with its own Clean Architecture layers where needed.
- Sub-features that are presentation-only (dashboard, share_access) skip `domain/` and `data/` layers.

Each feature/sub-feature follows Clean Architecture layers as needed:
- `domain/` → entities, repository contracts, use cases
- `data/` → datasources, models, repository implementations
- `presentation/` → bloc, pages, widgets

---

### 4. Role-Based Access Control (RBAC)

**Concept:** Two roles - `admin` and `customer`. Role is stored in Firestore `users/{uid}` doc and resolved after login.

**Client-side enforcement:**
1. `AuthBloc` emits authenticated state including resolved `role`.
2. `go_router` redirect logic checks role:
   - `/a/...` routes require `role == admin`; otherwise redirect to customer home.
   - `/c/...` routes require `role == customer`; otherwise redirect to admin home.
   - Unauthenticated users on protected routes redirect to `/login` with return path.
3. Deep link `/o/:orgId` resolves to `/c/o/:orgId` for customers (admins access their own org differently).

**Server-side enforcement (critical):**
- Firestore Security Rules check `request.auth.uid` and role from user doc before allowing writes.
- Admin-only mutations (queue actions, service management) require `role == admin` in rules or callable Cloud Functions.

---

### 5. Initialize Firebase (Android-only MVP)
- Create Firebase project; add Android app with finalized `applicationId`.
- Run `flutterfire configure` to generate `firebase_options.dart`.
- Add Google Services plugin to Android Gradle files.
- Wire `Firebase.initializeApp()` in `main.dart`.

---

### 6. Assets & Theme Scaffold
- Create `assets/images/`, `assets/icons/`, `assets/fonts/` (add Inter font).
- Register in `pubspec.yaml`.
- Add `lib/src/app/theme/` with Material 3 theme matching UI mocks (colors, typography, card radii).

---

### 7. Git Workflow & Branching Strategy

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

### 8. CI/CD Pipeline (GitHub Actions)

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
   - Upload APK artifact

3. **firebase-deploy.yml** (optional, for Functions/Hosting)
   - Deploy Cloud Functions on push to `main`
   - Deploy Firestore rules on push to `main`

**Secrets required:** `FIREBASE_TOKEN` (or use Workload Identity Federation).

---

### 9. Testing Strategy (Init Phase)

| Layer | What to test | Tools |
|-------|--------------|-------|
| Unit | Use cases, BLoC logic, pure functions | `flutter_test`, `bloc_test`, `mocktail` |
| Widget | Individual widgets render correctly | `flutter_test` |
| Integration | Full user flows (auth, booking) | `integration_test` package |

**Init deliverable:** Create `test/` mirror of `lib/src/features/` structure with placeholder test files so CI passes from day one.

---

### 10. Verification Checklist
- [ ] `flutter analyze` passes with no issues.
- [ ] `flutter test` runs (even if tests are minimal placeholders).
- [ ] App launches on Android emulator -> splash -> login screen.
- [ ] Firebase Auth (email + Google) works end-to-end.
- [ ] Role resolution redirects to correct home (admin vs customer).
- [ ] CI pipeline runs green on a test PR.

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
| Branching | GitHub Flow (main + develop + feature branches) |
| CI/CD | GitHub Actions |

---

**Out of scope for this init plan:** Data model details, feature implementation, notifications, analytics. Those belong in dedicated feature plans.
