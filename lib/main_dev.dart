import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'core/config/flavor_config.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'shared/auth/presentation/cubit/auth_cubit.dart';

/// Development flavor entrypoint.
///
/// Run with: `flutter run --flavor dev -t lib/main_dev.dart`
///
/// Enables:
/// - Device preview in debug mode
/// - Development Firebase project
/// - Verbose logging via Talker (with BLoC observer)
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

    // Explicitly disable Crashlytics in dev flavor for faster debugging
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } on PlatformException catch (e) {
    debugPrint('⚠️ Firebase initialization failed: ${e.message}');
    debugPrint(
      '📱 To use Firebase, run on a physical device or emulator with Google Play Services',
    );
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  configureDependencies(environment: FlavorConfig.instance.flavor.name);

  final logger = getIt<AppLogger>();

  // Wire BLoC observer so every event, transition and error is logged.
  Bloc.observer = TalkerBlocObserver(
    talker: logger.talker,
    settings: const TalkerBlocLoggerSettings(
      printEventFullData: false,
      printStateFullData: true,
    ),
  );

  // Catch async errors that escape Flutter's zone.
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.critical('Unhandled async error', error, stack);
    return true;
  };

  logger.info('App started — ${FlavorConfig.instance.flavor.name} flavor');

  await getIt<AuthCubit>().checkAuthStatus();

  final useDevicePreview =
      kDebugMode && FlavorConfig.instance.enableDevicePreview;

  runApp(useDevicePreview ? DevicePreview(builder: (context) => App()) : App());
}
