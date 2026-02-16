import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    debugPrint('✅ Firebase initialized successfully');
  } on PlatformException catch (e) {
    // Firebase requires Google Play Services on Android
    // This error occurs when running on emulators without Play Services
    debugPrint('⚠️ Firebase initialization failed: ${e.message}');
    debugPrint('📱 To use Firebase, run on a physical device or emulator with Google Play Services');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  configureDependencies();

  runApp(App());
}
