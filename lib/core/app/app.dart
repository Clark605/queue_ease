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
    return DevicePreview(
      enabled: kDebugMode,
      builder: (context) => MaterialApp.router(
        title: 'QueueEase',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        // ignore: deprecated_member_use
        // Required by DevicePreview until it's updated
        useInheritedMediaQuery: true,
      ),
    );
  }
}
