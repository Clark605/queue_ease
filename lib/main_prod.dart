import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'core/config/flavor_config.dart';
import 'firebase_options.dart';

/// Production flavor entrypoint.
///
/// Run with: `flutter run --flavor prod -t lib/main_prod.dart`
///
/// Uses:
/// - Production Firebase project
/// - Error-only logging
/// - No debug tools
/// - Optimized timeouts
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load production environment variables
  await dotenv.load(fileName: '.env.prod');

  FlavorConfig.initialize(FlavorConfig.prod());

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
  runApp(App());
}
