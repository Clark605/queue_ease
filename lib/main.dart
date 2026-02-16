import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    // Firebase initialization failed - continue without it
    // This can happen in test environments or if Firebase is misconfigured
    debugPrint('Firebase initialization failed: $e');
  }

  configureDependencies();

  runApp(App());
}
