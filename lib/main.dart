import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:talker/talker.dart' as talker_lib;

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'core/config/flavor_config.dart';
import 'core/utils/app_logger.dart';
import 'firebase_options.dart';
import 'shared/auth/presentation/cubit/auth_cubit.dart';

/// Default entrypoint - uses production flavor.
///
/// For development with device preview, use [main_dev.dart] instead.
/// For explicit production builds, use [main_prod.dart].
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

  // Forward talker error/critical events → Crashlytics in production.
  logger.talker.stream.listen((event) {
    if (event.logLevel == talker_lib.LogLevel.error ||
        event.logLevel == talker_lib.LogLevel.critical) {
      FirebaseCrashlytics.instance.recordError(
        event.exception ?? event.message,
        event.stackTrace,
        fatal: event.logLevel == talker_lib.LogLevel.critical,
        reason: event.message,
      );
    }
  });

  // Catch async errors that escape Flutter's zone.
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.critical('Unhandled async error', error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  logger.info('App started — ${FlavorConfig.instance.flavor.name} flavor');

  await getIt<AuthCubit>().checkAuthStatus();
  runApp(App());
}
