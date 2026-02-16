// ignore_for_file: depend_on_referenced_packages

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  App({super.key});

  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return DevicePreview(
        builder: (context) => MaterialApp.router(
          title: 'QueueEase',
          theme: AppTheme.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          // Required by DevicePreview until it's updated
          // ignore: deprecated_member_use
          useInheritedMediaQuery: true,
        ),
      );
    }

    return MaterialApp.router(
      title: 'QueueEase',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
