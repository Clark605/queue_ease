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

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
