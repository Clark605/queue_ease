import 'package:flutter/material.dart';

import 'core/app/app.dart';
import 'core/app/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TODO: Initialize Crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  configureDependencies();

  runApp(App());
}
