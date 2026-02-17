// ignore_for_file: depend_on_referenced_packages

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/flavor_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  App({super.key});

  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final config = FlavorConfig.instance;

    // Check if DevicePreview is enabled to configure MaterialApp accordingly
    final enablePreview = kDebugMode && config.enableDevicePreview;

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: config.enableDebugOverlays,
      // DevicePreview config (only applies if wrapped in main_dev.dart)
      locale: enablePreview ? DevicePreview.locale(context) : null,
      builder: enablePreview ? DevicePreview.appBuilder : null,
      // Required by DevicePreview until it's updated
      // ignore: deprecated_member_use
      useInheritedMediaQuery: enablePreview,
    );
  }
}
