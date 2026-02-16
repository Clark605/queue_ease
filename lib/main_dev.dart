import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'core/config/flavor_config.dart';
import 'firebase_options.dart';

/// Development flavor entrypoint.
///
/// Run with: `flutter run --flavor dev -t lib/main_dev.dart`
///
/// Enables:
/// - Device preview in debug mode
/// - Development Firebase project
/// - Verbose logging
/// - Debug overlays
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load development environment variables
  await dotenv.load(fileName: '.env.dev');

  FlavorConfig.initialize(FlavorConfig.dev());

  try {
    await Firebase.initializeApp(
      options: FirebaseOptionsFactory.getOptions(FlavorConfig.instance.flavor),
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    debugPrint(
      '✅ Firebase initialized successfully for ${FlavorConfig.instance.flavor.name} flavor',
    );
  } on PlatformException catch (e) {
    debugPrint('⚠️ Firebase initialization failed: ${e.message}');
    debugPrint(
      '📱 To use Firebase, run on a physical device or emulator with Google Play Services',
    );
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  configureDependencies(environment: FlavorConfig.instance.flavor.name);

  if (kDebugMode && FlavorConfig.instance.enableDevicePreview) {
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => App(),
      ),
    );
  } else {
    runApp(App());
  }
}

