# QueueEase

Smart queue and appointment management for small clinics and service-based businesses.

![Version](https://img.shields.io/badge/version-1.0.0%2B1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.9.0-0175C2?logo=dart&logoColor=white)

## What the project does

QueueEase helps businesses manage appointments and live queues while giving customers a real-time view of their position and estimated wait time. It supports separate admin and customer flows, enabling service setup, working hours, and queue operations for admins, while customers can book or join queues via a shareable link or QR code.

For detailed product requirements, see [docs/PRD.md](docs/PRD.md).

## Why the project is useful

- Reduces booking conflicts with structured scheduling rules.
- Keeps customers informed with live queue status and ETA.
- Streamlines daily operations for small businesses.
- Supports role-based experiences for admins and customers.

## A picture of whole app UI

![App UI](docs/ui-screens/app-ui.png)

> Replace the image above with a full-app UI snapshot when available.

UI references and screen mockups live in [docs/ui-screens](docs/ui-screens).

## Folder Structure

| Path | Purpose |
| --- | --- |
| [lib](lib) | Application source code |
| [lib/admin](lib/admin) | Admin features (services, queue, dashboard, etc.) |
| [lib/customer](lib/customer) | Customer booking and queue status flows |
| [lib/core](lib/core) | App setup, DI, shared app logic |
| [lib/shared](lib/shared) | Shared UI and feature modules |
| [assets](assets) | Images, icons, and other assets |
| [docs](docs) | Product docs and UI references |
| [test](test) | Widget and unit tests |
| [android](android) / [ios](ios) | Platform-specific build targets |

## Technologies Used

- Flutter, Dart
- Firebase (Auth, Firestore, Crashlytics)
- State management with BLoC
- Navigation with `go_router`
- Dependency injection with `get_it` + `injectable`
- Intl, UUID utilities
- Testing: `flutter_test`, `bloc_test`, `mocktail`

## GitHub workflow

This repository uses a simple feature-branch workflow:

1. Create a branch from `main` (example: `feature/queue-status-ui`).
2. Commit focused changes.
3. Open a pull request to `main`.
4. Review, iterate, and merge.

## Skills learned

- Building multi-role Flutter apps (admin + customer)
- Real-time data flows for queues and appointments
- Firebase Auth + Firestore integration
- BLoC architecture and state management
- Dependency injection and testable app structure

## Video demo

TBD: Add a demo link here (example: https://youtu.be/REPLACE_ME)

## How users can get started

### Prerequisites

- Flutter SDK (3.x)
- Dart SDK (^3.9.0)
- Android Studio / Xcode for device builds

### Running Flavors

QueueEase supports separate development and production environments (flavors) with different configurations:

**Development Flavor:**
- Uses Firebase dev project (`ease-queue-dev`)
- Enables device preview in debug mode
- Verbose logging enabled
- Debug overlays and tools

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Production Flavor:**
- Uses Firebase production project (`ease-queue`)
- Error-only logging
- No debug tools
- Optimized for release builds

```bash
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
