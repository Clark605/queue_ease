# Queue Ease

Smart queue and appointment management for small clinics and service-based businesses.

![Version](https://img.shields.io/badge/version-1.1.0%2B1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.9.0%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.0%2B-0175C2?logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Coverage](https://img.shields.io/badge/progress-35--40%25-orange)

---

## 📖 What the project does

Queue Ease helps businesses manage appointments and live queues while giving customers a real-time view of their position and estimated wait time. It supports separate admin and customer flows, enabling service setup, working hours, and queue operations for admins, while customers can book or join queues via a shareable link or QR code.

**Key Features:**
- 🔐 Role-based authentication (Admin & Customer)
- 📅 Appointment booking with conflict prevention
- 📊 Live queue management and real-time updates
- ⏱️ Automatic no-show detection with time margins
- 📱 QR code and unique link generation for easy access
- 🔔 Push notifications for queue status
- 📈 Daily summary and analytics

For detailed product requirements, see [docs/PRD.md](docs/PRD.md).

---

## 🎯 Current Project Status

**Last Updated:** February 21, 2026  
**Current Branch:** `feature/auth`

### ✅ Completed (Phase 1 - Foundation)
- ✅ Complete authentication system (email/password, Google Sign-In, password reset)
- ✅ Full RBAC with role-based routing (admin vs. customer)
- ✅ Comprehensive error handling framework (Result type, AppException hierarchy)
- ✅ Complete onboarding flow with custom illustrations
- ✅ Clean architecture with dependency injection
- ✅ ALL 5 core domain entities (Organization, Service, WorkingHours, Appointment, Queue)
- ✅ ALL 5 Firestore models with complete serialization
- ✅ 15+ unit tests covering entities, models, auth, and error handling
- ✅ Comprehensive documentation (Architecture, PRD, Timeline)

### 🚧 Next Up (Phase 2 - Repository Layer)
- Implement Firestore security rules
- Create repositories for all domain entities
- Build Service Management CRUD (admin UI)
- Build Working Hours configuration (admin UI)

**Overall Progress:** ~35-40% complete  
**Estimated MVP Timeline:** 5-6 weeks remaining

---

## 🏗️ Architecture Overview

Queue Ease follows **Clean Architecture** principles with feature-based modular organization:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Pages, Widgets, State Management) │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│     (Entities, Repositories Interface)  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│   (Models, Datasources, Repositories)   │
└─────────────────────────────────────────┘
```

**Key Architectural Decisions:**
- **State Management:** flutter_bloc (Cubit pattern)
- **Dependency Injection:** GetIt + Injectable
- **Navigation:** GoRouter with authentication guards
- **Error Handling:** Sealed Result<T> type with structured exceptions
- **Logging:** Talker with environment-specific verbosity

For comprehensive architecture details, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 📁 Project Structure

```
lib/
├── core/                           # Shared infrastructure
│   ├── app/                        # Application setup (DI, routing)
│   ├── config/                     # Environment configuration
│   ├── error/                      # Error handling framework
│   ├── services/                   # Core services
│   ├── utils/                      # Utilities (logger, validators)
│   └── widgets/                    # Reusable UI components
│
├── shared/                         # Role-agnostic features
│   ├── auth/                       # Authentication (✅ Complete)
│   ├── onboarding/                 # First-time user flow (✅ Complete)
│   ├── organization/               # Organization domain (🚧 Models complete)
│   ├── booking/                    # Appointment domain (🚧 Models complete)
│   └── queue/                      # Queue domain (🚧 Models complete)
│
├── admin/                          # Admin-specific features
│   ├── dashboard/                  # Admin dashboard (✅ Basic UI)
│   ├── services/                   # Service management (⏳ Planned)
│   ├── working_hours/              # Hours configuration (⏳ Planned)
│   ├── queue_management/           # Live queue control (⏳ Planned)
│   ├── share_access/               # QR & link generation (⏳ Planned)
│   └── daily_summary/              # Reports (⏳ Planned)
│
├── customer/                       # Customer-specific features
│   ├── entry/                      # Customer home (✅ Basic UI)
│   ├── booking_flow/               # Booking UI (⏳ Planned)
│   └── queue_status/               # Queue tracking (⏳ Planned)
│
├── firebase_options.dart           # Firebase configuration
├── main_dev.dart                   # Dev entrypoint
└── main_prod.dart                  # Prod entrypoint

test/                               # Mirror of lib/ structure
├── core/error/                     # Error handling tests (✅)
└── shared/
    ├── auth/                       # Auth tests (✅)
    ├── organization/               # Entity & model tests (✅)
    ├── booking/                    # Entity & model tests (✅)
    └── queue/                      # Entity & model tests (✅)

docs/                               # Documentation
├── ARCHITECTURE.md                 # Comprehensive architecture guide (✅)
├── PRD.md                          # Product requirements (✅)
├── FEATURE_CHECKLIST.md            # Implementation tracking (✅)
├── PROJECT_TIMELINE.md             # Timeline & Gantt charts (✅)
├── entities.md                     # Domain model specs (✅)
└── README.md                       # Documentation index (✅)
```

**Legend:** ✅ Complete | 🚧 In Progress | ⏳ Planned

For detailed documentation, see [docs/](docs/) folder.

---

## 🛠️ Technologies Used

### Core Framework
- **Flutter** 3.9.0+ - Cross-platform UI framework
- **Dart** 3.9.0+ - Programming language

### State Management & Architecture
- **flutter_bloc** 9.1.1 - State management (Cubit pattern)
- **Equatable** 2.0.7 - Value equality for domain entities

### Backend & Services
- **Firebase Core** 4.4.0 - Firebase integration
- **Firebase Auth** 6.1.4 - Authentication
- **Cloud Firestore** 6.1.2 - NoSQL database
- **Firebase Crashlytics** 5.0.7 - Crash reporting
- **Google Sign-In** 7.2.0 - OAuth authentication

### Navigation & Routing
- **GoRouter** 17.1.0 - Declarative routing with guards

### Dependency Injection
- **GetIt** 9.2.0 - Service locator
- **Injectable** 2.5.0 - Code generation for DI

### Utilities
- **Intl** 0.20.2 - Internationalization and date formatting
- **UUID** 4.5.1 - Unique ID generation
- **flutter_dotenv** 5.1.0 - Environment variables

### Local Storage
- **SharedPreferences** 2.3.3 - Key-value persistence

### UI Components
- **smooth_page_indicator** 2.0.1 - Page indicators

### Logging & Debugging
- **Talker** 4.9.3 - Advanced logging
- **Talker Flutter** 4.9.3 - Flutter-specific logger
- **Talker BLoC Logger** 4.9.3 - BLoC event/state logging
- **Device Preview** 1.3.1 - Multi-device testing (dev only)

### Testing
- **flutter_test** - Unit and widget testing
- **bloc_test** 10.0.0 - BLoC testing utilities
- **mocktail** 1.0.4 - Mocking framework

### Build Tools
- **build_runner** 2.4.15 - Code generation
- **injectable_generator** 2.7.0 - DI code generation
- **flutter_native_splash** 2.4.5 - Splash screen generation

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.9.0 or higher
- **Dart SDK** 3.9.0 or higher
- **Android Studio** / **Xcode** for device builds
- **Firebase Account** (for backend services)
- **Git** for version control

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Clark605/queue_ease.git
   cd queue_ease
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate dependency injection code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure environment variables:**
   
   Copy the example environment files:
   ```bash
   cp .env.example .env.dev
   cp .env.example .env.prod
   ```
   
   Update `.env.dev` and `.env.prod` with your actual configuration.
   
   **Note:** `.env.dev` and `.env.prod` are git-ignored to protect sensitive data.

5. **Firebase setup:**
   
   Ensure Firebase is configured for your project:
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `firebase_options.dart` if needed

### Running the App

**Development Build (with debugging tools):**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Features enabled in dev:
- Device preview
- Verbose logging
- Debug overlays
- In-app log viewer at `/debug/logs`

**Production Build:**

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

Production optimizations:
- Error-only logging
- No debug tools
- Performance optimizations

**VS Code Launch Configurations:**

Use the pre-configured launch options in `.vscode/launch.json`:
- **Dev** - Development flavor
- **Prod** - Production flavor

---

## 🧪 Testing

### Run all tests:
```bash
flutter test
```

### Run specific test file:
```bash
flutter test test/shared/auth/auth_cubit_test.dart
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Current Test Coverage:
- ✅ Auth: AuthCubit (comprehensive)
- ✅ Core: Result type, AppException hierarchy
- ✅ Entities: Organization, Service, WorkingHours, Appointment, Queue
- ✅ Models: All 5 Firestore models with serialization round-trips
- ✅ Onboarding: Integration test

**Total Test Files:** 15+

---

## 📚 Documentation

All documentation is located in the [docs/](docs/) folder:

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Comprehensive technical architecture guide |
| [PRD.md](docs/PRD.md) | Product requirements and specifications |
| [FEATURE_CHECKLIST.md](docs/FEATURE_CHECKLIST.md) | Feature implementation tracking |
| [PROJECT_TIMELINE.md](docs/PROJECT_TIMELINE.md) | Timeline, Gantt charts, milestones |
| [entities.md](docs/entities.md) | Domain entity specifications |
| [README.md](docs/README.md) | Documentation index |

---

## 🔄 GitHub Workflow

This repository uses a feature-branch workflow:

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Commit focused changes:**
   ```bash
   git add .
   git commit -m "feat: add user authentication"
   ```

3. **Push and create a pull request:**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Review, iterate, and merge** to `main`

**Branch Naming Convention:**
- `feature/` - New features
- `bugfix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates

---

## 🚢 Deployment

### Firebase App Distribution with Fastlane

Queue Ease uses Fastlane to automate distribution of builds to Firebase App Distribution for testing.

**Manual Distribution:**

```bash
# Development build
cd android
fastlane android distribute_dev

# Production build
fastlane android distribute_prod
```

**CI/CD Automation:**

Builds are automatically distributed via GitHub Actions:
- **Dev builds:** Pushed to `develop` branch
- **Prod builds:** Pushed to `main` branch

**Required GitHub Secrets:**
- `FIREBASE_TOKEN` - Firebase CLI authentication token
- `FIREBASE_APP_ID_DEV` - Dev Firebase app ID
- `FIREBASE_APP_ID_PROD` - Prod Firebase app ID

**Troubleshooting:**
- **"Firebase token required" error**: Make sure `FIREBASE_TOKEN` environment variable is set
- **Firebase permission error**: Verify you have owner/editor permissions on the Firebase project
- **Tester group not found**: Create the "developers" group in Firebase Console > App Distribution > Testers

---

## 🎓 Skills Learned

- ✅ Building multi-role Flutter apps (admin + customer)
- ✅ Implementing Clean Architecture in Flutter
- ✅ Real-time data flows with Firestore
- ✅ Firebase Auth integration (email/password, Google Sign-In)
- ✅ Advanced state management with flutter_bloc
- ✅ Dependency injection with GetIt + Injectable
- ✅ Role-based access control (RBAC) with GoRouter
- ✅ Structured error handling with Result types
- ✅ Comprehensive testing strategies
- ✅ Environment-based configuration (Dev/Prod flavors)

---

## 🎥 Demo

> **Coming Soon:** Video demonstration of implemented features

UI mockups and design references: [docs/ui-screens](docs/ui-screens/)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Update documentation
6. Submit a pull request

**Before submitting:**
- Ensure all tests pass: `flutter test`
- Follow established code conventions (see [ARCHITECTURE.md](docs/ARCHITECTURE.md))
- Update relevant documentation

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📞 Contact & Support

**Repository:** [github.com/Clark605/queue_ease](https://github.com/Clark605/queue_ease)  
**Current Branch:** `feature/auth`  
**Issues:** [GitHub Issues](https://github.com/Clark605/queue_ease/issues)

---

## 🗺️ Roadmap

### ✅ Phase 1: Foundation (COMPLETE)
- Complete authentication system
- Clean architecture setup
- All domain entities & models
- Comprehensive testing

### 🚧 Phase 2: Repository Layer (In Progress)
- Firestore security rules
- Repository implementations
- Admin service management UI
- Working hours configuration UI

### ⏳ Phase 3-8: Upcoming
- Customer booking flow
- Queue generation system
- Real-time updates
- Notifications
- Testing & deployment

**Estimated MVP Completion:** 5-6 weeks

For detailed timeline, see [PROJECT_TIMELINE.md](docs/PROJECT_TIMELINE.md)

---

**Built with ❤️ using Flutter**
flutter run --flavor prod -t lib/main_prod.dart
```

**VS Code Launch Configurations:**

You can also use the pre-configured launch options in VS Code:
- **Dev** - Runs development flavor with device preview
- **Prod** - Runs production flavor

### Firebase App Distribution with Fastlane

QueueEase uses Fastlane to automate distribution of builds to Firebase App Distribution for testing.



**CI/CD Automation:**

Builds are automatically distributed via GitHub Actions:
- **Dev builds**: Automatically distributed when code is pushed to `develop` branch
- **Prod builds**: Automatically distributed when code is pushed to `main` branch

**Required GitHub Secrets:**
- `FIREBASE_TOKEN`: Firebase CLI authentication token
- `FIREBASE_APP_ID_DEV`: Firebase app ID for dev flavor
- `FIREBASE_APP_ID_PROD`: Firebase app ID for prod flavor

**Troubleshooting:**

- **"Firebase token required" error**: Make sure `FIREBASE_TOKEN` environment variable is set
- **Firebase permission error**: Verify you have owner/editor permissions on the Firebase project
- **Tester group not found**: Create the "developers" group in Firebase Console > App Distribution > Testers

### Environment Configuration

The app uses `.env` files for environment-specific configuration:

1. Copy `.env.example` to create your environment files:
   ```bash
   cp .env.example .env.dev
   cp .env.example .env.prod
   ```

2. Update the values in `.env.dev` and `.env.prod` with your actual API keys and configuration.

**Note:** `.env.dev` and `.env.prod` are git-ignored to protect sensitive data. Never commit these files.

### Install and run

```bash
flutter pub get
```

If you use `injectable`, generate DI code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

### Firebase setup (optional)

If you enable Firebase, add the platform configuration files and initialize Firebase in your app entry point. See the Firebase docs and follow the setup steps for Flutter.

### Usage example

- Admins sign in to configure services and manage today’s queue.
- Customers open a shared link or QR code to book a service and track their position.
