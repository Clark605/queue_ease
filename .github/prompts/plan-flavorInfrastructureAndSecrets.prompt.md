# Plan: Flavor Infrastructure Setup + Secure Secrets Management

Extended plan adding comprehensive secret management to the flavor infrastructure. This covers Firebase API keys, future third-party API credentials, signing keys, and environment-specific secrets using a multi-layered approach: obfuscation for Firebase keys, `--dart-define` for runtime secrets, `.env` files for local development, and secure CI/CD injection for production.

## Current Deliverables (In Scope)

**Phase 1: Core Flavor Infrastructure + Basic Secret Management**
- Steps 1-10: Complete flavor setup (FlavorConfig, Firebase project separation, entrypoints, Android Gradle, DI integration)
- Step 11: `.env` files with `flutter_dotenv` for environment variables
- Step 15: `.gitignore` updates to prevent secret leaks

**TL;DR Current Phase:** Set up dev/prod flavors with separate Firebase configs, enable device_preview gating, add `.env` file support for future third-party credentials, and ensure secrets are gitignored.

## Future Enhancements (Out of Current Scope)

Will be implemented before public launch or when needed:
- Step 12: Obfuscation for Firebase keys in release builds
- Step 13: Android release signing configuration with keystores
- Step 14: `--dart-define` for runtime secret injection
- Step 16: Full CI/CD secret management documentation

---

## Original Steps 1-10: Flavor Infrastructure

### 1. Create Flavor Configuration System

Create `lib/core/config/flavor_config.dart`:
- Define `Flavor` enum with values `dev` and `prod`
- Create `FlavorConfig` class with fields:
  - `Flavor flavor`
  - `String appName` ("QueueEase Dev" vs "QueueEase")
  - `String bundleId` ("com.queueease.app.dev" vs "com.queueease.app")
  - `bool enableDevicePreview` (true for dev, false for prod)
  - `bool enableDebugOverlays` (configurable in dev)
  - `String bookingLinkDomain` (placeholder for future: "dev-book.queueease.com" vs "book.queueease.com")
  - `Duration apiTimeout` (10s dev, 3s prod - ready for future HTTP clients)
  - `LogLevel logLevel` enum (verbose dev, error-only prod)
  - `Map<String, dynamic> extras` (extensible for future configs)
- Factory constructors `FlavorConfig.dev()` and `FlavorConfig.prod()` with preset values
- Singleton accessor `FlavorConfig.instance` with nullable `_instance` field
- Static `initialize(FlavorConfig config)` method to set instance once

### 2. Create Flavor-Specific Firebase Options

Split `lib/firebase_options.dart` to support multiple Firebase projects:
- Rename `DefaultFirebaseOptions` class to `FirebaseOptionsFactory`
- Add static method `getOptions(Flavor flavor)` that returns platform-specific `FirebaseOptions`
- Structure: `getOptions` switches on `flavor`, then inside each case, switches on platform (Android/iOS)
- **For dev flavor:** Use new Firebase project config (will be generated in Step 6)
- **For prod flavor:** Keep existing `ease-queue` project config
- Keep backward compatibility: maintain `currentPlatform` getter that uses `FlavorConfig.instance.flavor` if initialized, otherwise defaults to prod

### 3. Create Flavor Entrypoints

Create `lib/main_dev.dart`:
- Initialize `FlavorConfig` with `FlavorConfig.initialize(FlavorConfig.dev())`
- Call `_mainCommon()` helper
- Wrap in `DevicePreview` if `kDebugMode && FlavorConfig.instance.enableDevicePreview`

Create `lib/main_prod.dart`:
- Initialize `FlavorConfig` with `FlavorConfig.initialize(FlavorConfig.prod())`
- Call `_mainCommon()` helper
- No `DevicePreview` wrapper

Refactor `lib/main.dart`:
- Extract current `main()` body to `Future<void> _mainCommon()` helper
- Update Firebase init: `Firebase.initializeApp(options: FirebaseOptionsFactory.getOptions(FlavorConfig.instance.flavor))`
- Keep existing Crashlytics setup
- Keep existing DI call: `configureDependencies()`
- Keep existing `runApp(App())`
- Make `main()` default to prod: call `FlavorConfig.initialize(FlavorConfig.prod())` then `_mainCommon()`

**Note:** Using separate entrypoints (`main_dev.dart` / `main_prod.dart`) is simpler than `--dart-define` for this project stage and aligns with Flutter flavor best practices.

### 4. Update App Widget for Conditional Device Preview

Update `lib/core/app/app.dart`:
- Import `FlavorConfig` and `kDebugMode`
- Modify `MaterialApp.router`:
  - **If** `FlavorConfig.instance.enableDevicePreview && kDebugMode`:
    - Keep `locale: DevicePreview.locale(context)`
    - Keep `builder: DevicePreview.appBuilder`
  - **Else:**
    - Remove those lines or set `locale: null`, `builder: null`
- Update `title` property: `FlavorConfig.instance.appName`
- Optional: Add visual debug banner in dev using `WidgetsApp.debugShowCheckedModeBanner: !FlavorConfig.instance.enableDebugOverlays` (inverted logic example)

**Implementation approach:** Use conditional assignments or ternary operators to pass null/actual values based on flavor config.

### 5. Configure Android Gradle for Flavors

Update `android/app/build.gradle.kts`:

**After `defaultConfig` block, add:**
```kotlin
flavorDimensions += "environment"

productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "QueueEase Dev")
    }
    
    create("prod") {
        dimension = "environment"
        resValue("string", "app_name", "QueueEase")
    }
}
```

**Inside `buildTypes.release`, add flavor-specific signing configs if needed:**
- For now, keep debug signing for both flavors
- Document TODO for production signing setup

**Verify:**
- `namespace = "com.queueease.app"` stays unchanged (line 12)
- `defaultConfig.applicationId = "com.queueease.app"` serves as base (line 26)
- Flavors modify via suffix

### 6. Set Up Flavor-Specific Firebase Configs

**Create Firebase projects in Firebase Console:**
1. **Dev project:** Create new project (e.g., `ease-queue-dev`)
2. **Prod project:** Keep existing `ease-queue` project

**Generate and organize configs:**

**For Android dev:**
- Add Android app to `ease-queue-dev` project with bundle ID `com.queueease.app.dev`
- Download `google-services.json`
- Place at: `android/app/src/dev/google-services.json`
- Run `flutterfire configure` with `--project=ease-queue-dev --out=lib/firebase_options_dev.dart --platforms=android`

**For Android prod:**
- Verify existing `ease-queue` project has app with bundle ID `com.queueease.app`
- Move existing `android/app/google-services.json` to `android/app/src/prod/google-services.json`
- If not already configured, run `flutterfire configure` with `--project=ease-queue --out=lib/firebase_options_prod.dart --platforms=android`

**Merge generated options into `lib/firebase_options.dart`:**
- Copy dev `FirebaseOptions` constants into `getOptions(Flavor flavor)` dev case
- Copy prod `FirebaseOptions` constants into prod case
- Delete temporary `firebase_options_dev.dart` and `firebase_options_prod.dart` files after merging

**Update .gitignore:**
- Ensure `.gitignore` includes `**/google-services.json` patterns
- Verify src-folder configs are tracked: add `!android/app/src/*/google-services.json` if needed (or keep gitignored and document manual setup)

### 7. Integrate Flavor with Dependency Injection

Update `lib/core/app/di/injection.dart`:
- Modify `configureDependencies()` signature: add optional `String? environment` parameter
- Pass environment to `getIt.init()`: `getIt.init(environment: environment)`
- In flavor entrypoints, call `configureDependencies(environment: FlavorConfig.instance.flavor.name)`

**Register FlavorConfig in injectable:**
- Create `lib/core/config/config_module.dart`
- Use `@module` abstract class
- Register `FlavorConfig.instance` as lazy singleton: 
  ```dart
  @module
  abstract class ConfigModule {
    @lazySingleton
    FlavorConfig get config => FlavorConfig.instance;
  }
  ```
- Run `flutter pub run build_runner build --delete-conflicting-outputs`

This allows any injectable service to depend on `FlavorConfig` via constructor injection.

### 8. Update Launch Configurations

Create or update `.vscode/launch.json` (if using VS Code):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Prod",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

**Android Studio / IntelliJ:**
- Create run configurations with program path `lib/main_dev.dart` and additional args `--flavor dev`
- Repeat for prod

### 9. Document Flavor Usage

Add section to `README.md`:

**"Running Flavors" section:**
- Command line: 
  - Dev: `flutter run --flavor dev -t lib/main_dev.dart`
  - Prod: `flutter run --flavor prod -t lib/main_prod.dart`
- Build APK:
  - Dev debug: `flutter build apk --flavor dev -t lib/main_dev.dart --debug`
  - Prod release: `flutter build apk --flavor prod -t lib/main_prod.dart --release`
- Explain flavor-specific features:
  - Device preview in dev
  - Separate Firebase projects
  - App naming and bundle IDs

**"Adding New Flavor Configs" section:**
- Reference `lib/core/config/flavor_config.dart`
- Provide examples: adding `String apiBaseUrl`, `bool enableMockMode`, etc.
- Show how to access in services: inject `FlavorConfig` via constructor

### 10. Create Config Extension File (Optional Quality-of-Life)

Create `lib/core/config/flavor_extensions.dart`:
- Extension on `Flavor` enum:
  - `bool get isDev => this == Flavor.dev`
  - `bool get isProd => this == Flavor.prod`
  - `String get displayName => ...`
- Convenience getters for common checks
- Reduces boilerplate in feature code

---

## Current Phase: Basic Secret Management

### 11. Add Environment Variable Package & Configuration (IN SCOPE)

**Add `flutter_dotenv` to `pubspec.yaml`:**
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

**Create environment files:**
- `.env.dev` for development secrets
- `.env.prod` for production secrets (template only, never commit actual values)
- `.env.example` as a template with placeholder values

**Example `.env.dev` structure:**
```dotenv
# Firebase (optional - can use from firebase_options.dart)
FIREBASE_API_KEY=AIzaSyCM70DyzvDa9QqjJQ0q_aZoHaxJjDGHZK8
FIREBASE_PROJECT_ID=ease-queue-dev

# Future API integrations
BOOKING_LINK_BASE_URL=https://dev-book.queueease.com
PAYMENT_GATEWAY_KEY=test_pk_xxxxx
ANALYTICS_WRITE_KEY=dev_analytics_key_xxxxx

# Feature flags via env
ENABLE_MOCK_MODE=true
ENABLE_DEBUG_LOGGING=true
```

**Example `.env.example` (commit this):**
```dotenv
# Copy this to .env.dev or .env.prod and fill in actual values
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_project_id
BOOKING_LINK_BASE_URL=https://your-domain.com
PAYMENT_GATEWAY_KEY=your_payment_key
ANALYTICS_WRITE_KEY=your_analytics_key
ENABLE_MOCK_MODE=false
ENABLE_DEBUG_LOGGING=false
```

**Update `pubspec.yaml` assets:**
```yaml
flutter:
  assets:
    - .env.dev
    - .env.prod
```

**Load in flavor entrypoints:**

Update `lib/main_dev.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev");
  FlavorConfig.initialize(FlavorConfig.dev());
  await _mainCommon();
}
```

Update `lib/main_prod.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.prod");
  FlavorConfig.initialize(FlavorConfig.prod());
  await _mainCommon();
}
```

**Access secrets in code:**
```dart
// In services or config classes
final apiKey = dotenv.env['PAYMENT_GATEWAY_KEY'] ?? '';
```

### 15. Update .gitignore for Secret Files (IN SCOPE)

**Update `.gitignore`:**
```gitignore
# Environment files with secrets
.env.dev
.env.prod
.env.*.local

# Dart define files
dart_defines.*.json
*.secrets.json

# Android signing
android/key.properties
android/app/*.jks
android/app/*.keystore

# iOS signing (future)
ios/Runner/GoogleService-Info.plist
ios/Runner/GoogleService-Info-Dev.plist

# Firebase config (if not using src folders)
android/app/google-services.json

# Keep src-folder configs (flavor-specific)
!android/app/src/*/google-services.json
```

**Update `android/.gitignore`:**
```gitignore
# Already has key.properties - verify it's there
key.properties

# Add if missing
*.jks
*.keystore
google-services.json
```

---

## Future Enhancements: Advanced Secret Management

### 12. Obfuscate Firebase Options in Release Builds (FUTURE)

Firebase API keys are not truly secret (they're client IDs meant for public use with Firebase Security Rules protection), but obfuscation prevents casual scraping from decompiled APKs.

**Create `lib/core/config/secrets_config.dart`:**
```dart
/// Obfuscated secrets - use with --obfuscate flag
class SecretsConfig {
  // These will be obfuscated in release builds
  static const String _firebaseApiKeyDev = String.fromEnvironment(
    'FIREBASE_API_KEY_DEV',
    defaultValue: '', // Empty in source
  );
  
  static const String _firebaseApiKeyProd = String.fromEnvironment(
    'FIREBASE_API_KEY_PROD',
    defaultValue: '',
  );
  
  static String getFirebaseApiKey(Flavor flavor) {
    return flavor == Flavor.dev ? _firebaseApiKeyDev : _firebaseApiKeyProd;
  }
}
```

**Update Firebase options in `lib/firebase_options.dart`:**
- Replace hardcoded `apiKey` values with `SecretsConfig.getFirebaseApiKey(flavor)`
- OR continue using hardcoded keys (acceptable for Firebase since keys are protected by Security Rules)
- Document that Firebase API keys are NOT sensitive secrets (Firebase best practice)

**Build with obfuscation:**
```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### 13. Set Up Android Signing Configuration (FUTURE)

**Create `android/key.properties` template:**
```properties
# NEVER commit this file - template only
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

**Create `android/key.properties.example`:**
```properties
# Copy to key.properties and fill in actual values
# Generate keystore: keytool -genkey -v -keystore queueease-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias queueease
storePassword=
keyPassword=
keyAlias=
storeFile=
```

**Update `android/app/build.gradle.kts`:**

Add before `android` block:
```kotlin
// Load signing config from key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Add inside `android` block, after `kotlinOptions`:
```kotlin
signingConfigs {
    create("release") {
        if (keystoreProperties.isNotEmpty()) {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
}
```

Update `buildTypes.release`:
```kotlin
buildTypes {
    release {
        signingConfig = if (keystoreProperties.isNotEmpty()) {
            signingConfigs.getByName("release")
        } else {
            signingConfigs.getByName("debug") // Fallback for CI or local dev
        }
        // Optional: enable ProGuard/R8 for code shrinking
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

**Create `android/app/proguard-rules.pro`:**
```proguard
# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Preserve line numbers for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
```

### 14. Use --dart-define for Runtime Secret Injection (FUTURE)

For secrets that absolutely must not be in source code (future payment keys, private API tokens), use `--dart-define`:

**Access in code:**
```dart
const paymentApiKey = String.fromEnvironment('PAYMENT_API_KEY', defaultValue: '');
const stripePublishableKey = String.fromEnvironment('STRIPE_KEY', defaultValue: '');
```

**Build command:**
```bash
flutter build apk \
  --flavor prod \
  -t lib/main_prod.dart \
  --release \
  --dart-define=FIREBASE_API_KEY_PROD=AIzaSy... \
  --dart-define=PAYMENT_API_KEY=sk_live_... \
  --dart-define=STRIPE_KEY=pk_live_...
```

**Or use `--dart-define-from-file` (Flutter 3.7+):**

Create `dart_defines.dev.json` (gitignored):
```json
{
  "FIREBASE_API_KEY_DEV": "AIzaSy...",
  "PAYMENT_API_KEY": "sk_test_...",
  "ENABLE_MOCK_MODE": "true"
}
```

Command:
```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_defines.dev.json
```

### 16. Document CI/CD Secret Management (FUTURE)

Add section to `README.md` or create `docs/SECRETS.md`:

**"Secret Management" section:**

#### Local Development
1. Copy `.env.example` to `.env.dev` and fill in dev credentials
2. Copy `android/key.properties.example` to `android/key.properties` (only for release builds)
3. Never commit actual secret files - they're gitignored

#### Firebase API Keys
- Firebase API keys in `firebase_options.dart` are **not sensitive secrets**
- They're meant to be public and protected by Firebase Security Rules
- Obfuscation is optional but recommended for release builds

#### Third-Party API Keys (Future)
- Payment gateways (Stripe, etc.): Use `--dart-define` or `.env` files
- Analytics keys: Store in `.env` files per flavor
- OAuth secrets: NEVER commit - use environment variables

#### CI/CD Setup
**GitHub Actions example:**
```yaml
- name: Build APK
  env:
    FIREBASE_API_KEY_PROD: ${{ secrets.FIREBASE_API_KEY_PROD }}
    PAYMENT_API_KEY: ${{ secrets.PAYMENT_API_KEY }}
  run: |
    flutter build apk \
      --flavor prod \
      -t lib/main_prod.dart \
      --release \
      --dart-define=FIREBASE_API_KEY_PROD=$FIREBASE_API_KEY_PROD \
      --dart-define=PAYMENT_API_KEY=$PAYMENT_API_KEY
```

**Signing in CI:**
1. Encode keystore to base64: `base64 queueease-release-key.jks`
2. Store in GitHub Secrets: `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`
3. Decode in CI:
```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release.jks
- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.STORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=release.jks" >> android/key.properties
```

#### Rotation Strategy
- Rotate signing keys: NEVER (Android doesn't allow)
- Rotate API keys: Quarterly or on suspected compromise
- Rotate Firebase projects: Create new project, migrate data with Firebase Admin SDK

#### Security Checklist
- [ ] `.env.dev` and `.env.prod` are gitignored
- [ ] `key.properties` is gitignored
- [ ] No hardcoded secrets in source code
- [ ] Firebase Security Rules are properly configured
- [ ] Release builds use `--obfuscate` flag
- [ ] CI secrets are stored in secure vault (GitHub Secrets, etc.)
- [ ] Team members use personal dev Firebase projects, not shared credentials

---

## Verification Steps

### Original Infrastructure Verification

1. **Build verification:**
   - Run `cd android && ./gradlew :app:tasks --all` (Windows: `gradlew.bat`)
   - Confirm flavor tasks appear: `assembleDevDebug`, `assembleDevRelease`, `assembleProdDebug`, `assembleProdRelease`

2. **Dev flavor run:**
   - Execute: `flutter run --flavor dev -t lib/main_dev.dart`
   - Verify device preview frame appears (if in debug mode)
   - Check app name in task switcher: "QueueEase Dev"
   - Verify Firebase connects to dev project (check Firestore logs or Firebase console)

3. **Prod flavor run:**
   - Execute: `flutter run --flavor prod -t lib/main_prod.dart`
   - Verify NO device preview frame
   - Check app name: "QueueEase"
   - Verify Firebase connects to prod project

4. **Side-by-side install:**
   - Install both flavors on same device: `flutter install --flavor dev -t lib/main_dev.dart`, then `flutter install --flavor prod -t lib/main_prod.dart`
   - Confirm two separate apps appear (different bundle IDs prevent collision)

5. **Build runner:**
   - Run: `flutter pub run build_runner build --delete-conflicting-outputs`
   - Confirm no errors and `lib/core/app/di/injection.config.dart` regenerates successfully with `ConfigModule`

6. **Crashlytics integration:**
   - Trigger a test crash in dev flavor
   - Check Firebase Crashlytics console for dev project
   - Confirm crash appears under dev project, not prod

### Secret Management Verification

7. **Secret file protection:**
   - Run: `git status`
   - Verify `.env.dev`, `.env.prod`, `key.properties` are NOT listed (should be ignored)
   - Try: `git add .env.dev` → Should see "ignored by .gitignore" warning

---

## Verification Steps (Current Phase)

### Flavorle APK (jadx or similar)
   - Verify class/method names are obfuscated (e.g., `a.b.c()` instead of `MyClass.myMethod()`)

9. **Signing verification:**
   - Generate test keystore: `keytool -genkey -v -keystore test.jks -keyalg RSA -keysize 2048 -validity 10000 -alias test`
   - Create `android/key.properties` with test credentials
   - Build: `flutter build apk --flavor prod -t lib/main_prod.dart --release`
   - Verify APK signature: `jarsigner -verify -verbose build/app/outputs/flutter-apk/app-prod-release.apk`

10. **Environment variable access:**
    - Add debug print in `FlavorConfig`: `print('Payment key: ${dotenv.env['PAYMENT_GATEWAY_KEY']}')`
    - Run dev flavor
    - Verify console shows value from `.env.dev` (then remove debug print)

---

## Priority Recommendations

### Secret Management Priority

**Implement Now (MVP Phase):**
1. **.gitignore updates** (Step 15): Prevent accidental secret commits immediately
2. **Signing configuration** (Step 13): Required for Google Play release
3. **Firebase config isolation** (Step 6): Separate dev/prod projects

**Implement Before Public Launch:**
4. **Obfuscation** (Step 12): Makes reverse engineering harder
5. **ProGuard/R8 rules** (Step 13): Reduces APK size and adds security
6. **CI/CD secret injection** (Step 16): Automate release builds securely
Basic Secret Management Verification

7. **Secret file protection:**
   - Run: `git status`
   - Verify `.env.dev`, `.env.prod` are NOT listed (should be ignored)
   - Try: `git add .env.dev` → Should see "ignored by .gitignore" warning
   - Create `.env.dev` with test values and verify app loads dotenv successfully

8. **Environment variable access:**
   - Add test key to `.env.dev`: `TEST_KEY=test_value`
   - Add debug print in app startup: `print('Test: ${dotenv.env['TEST_KEY']}')`
   - Run dev flavor
   - Verify console shows value from `.env.dev` (then remove debug print)

---

## Future Verification Steps

These verification steps apply to the advanced secret management features (Steps 12-14, 16):

9. **Obfuscated build (FUTURE):**
   - Build release: `flutter build apk --flavor prod -t lib/main_prod.dart --release --obfuscate --split-debug-info=build/symbols`
   - Decompile APK (jadx or similar)
   - Verify class/method names are obfuscated (e.g., `a.b.c()` instead of `MyClass.myMethod()`)

10.Implementation Priority & Phasing

### Phase 1: Current Deliverables (Implement Now)

**Core Infrastructure (Steps 1-10):**
1. FlavorConfig system (Step 1)
2. Firebase project separation (Steps 2, 6)
3. Flavor entrypoints (Step 3)
4. Conditional device preview (Step 4)
5. Android Gradle flavors (Step 5)
6. DI integration (Step 7)
7. Launch configurations (Step 8)
8. Documentation (Step 9)
9. Flavor extensions (Step 10)

**Basic Secret Management (Steps 11, 15):**
1. `.env` file setup with `flutter_dotenv` (Step 11)
2. `.gitignore` updates (Step 15)

### Phase 2: Before Public Launch (Future)

**Advanced Secret Management:**
1. **Signing configuration** (Step 13): Required for Google Play release
2. **Obfuscation** (Step 12): Makes reverse engineering harder
3. **ProGuard/R8 rules** (Step 13): Reduces APK size and adds security
4. **CI/CD secret injection** (Step 16): Automate release builds securely

### Phase 3: Post-MVP (When Needed)

**Production-Grade Secrets:**
1. **--dart-define** (Step 14): For truly sensitive secrets (payment keys, OAuth) that must not appear in .env files

## Future Extension Points

Once this infrastructure is in place, adding new configurations is straightforward:
1. Add field to `FlavorConfig` class
2. Set values in factory constructors (`.dev()` / `.prod()`)
3. Access via `FlavorConfig.instance.newField` anywhere in app
4. For injectable services, inject `FlavorConfig` and derive behavior from config

Examples ready to plug in:
- HTTP client configuration (base URLs, timeouts)
- Feature flags (enable experimental admin queue reordering)
- Deep link schemes (for QR code booking flow testing)
- Logging providers (verbose console in dev, structured remote in prod)
- Mock data providers (fake appointments/queue without Firebase)
