import 'package:injectable/injectable.dart';

import 'flavor_config.dart';

/// Injectable module for registering flavor configuration.
///
/// This module makes [FlavorConfig.instance] available for dependency injection
/// throughout the app. Services can depend on FlavorConfig via constructor injection.
@module
abstract class ConfigModule {
  /// Provides the current flavor configuration as a lazy singleton.
  ///
  /// FlavorConfig must be initialized before dependency injection setup.
  @lazySingleton
  FlavorConfig get config => FlavorConfig.instance;
}
