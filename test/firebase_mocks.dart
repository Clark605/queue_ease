import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

/// Sets up Firebase mocks for testing.
///
/// This should be called in setUpAll() before initializing Firebase.
void setupFirebaseCoreMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreStub();
}

void setupFirebaseCoreStub() {
  FirebasePlatform.instance = _MockFirebaseCore();
}

class _MockFirebaseCore extends FirebasePlatform {
  _MockFirebaseCore() : super();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _MockFirebaseApp(name, _kTestFirebaseOptions);
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return _MockFirebaseApp(name ?? defaultFirebaseAppName, options ?? _kTestFirebaseOptions);
  }

  @override
  List<FirebaseAppPlatform> get apps {
    return [_MockFirebaseApp(defaultFirebaseAppName, _kTestFirebaseOptions)];
  }
}

class _MockFirebaseApp extends FirebaseAppPlatform {
  _MockFirebaseApp(String name, FirebaseOptions options)
      : super(name, options);

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  bool get isAutomaticDataCollectionEnabled => false;
}

/// Stub Firebase options for testing.
const FirebaseOptions _kTestFirebaseOptions = FirebaseOptions(
  apiKey: 'test-api-key',
  appId: 'test-app-id',
  messagingSenderId: 'test-sender-id',
  projectId: 'test-project-id',
);
