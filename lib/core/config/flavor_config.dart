/// Application flavor/environment enumeration
enum Flavor {
  /// Development environment
  dev,

  /// Production environment
  prod,
}

/// Log level for application logging
enum LogLevel {
  /// Verbose logging (all messages)
  verbose,

  /// Info level logging
  info,

  /// Error level logging only
  error,
}

/// Centralized configuration for different app flavors/environments.
///
/// This class provides flavor-specific settings like app name, bundle ID,
/// feature flags, and timeout configurations. Initialize once at app startup
/// using [FlavorConfig.initialize] and access via [FlavorConfig.instance].
///
/// Example:
/// ```dart
/// // In main_dev.dart
/// FlavorConfig.initialize(FlavorConfig.dev());
///
/// // Anywhere in app
/// final isDevMode = FlavorConfig.instance.flavor == Flavor.dev;
/// ```
class FlavorConfig {
  const FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.bundleId,
    required this.enableDevicePreview,
    required this.displayDebugIndicators,
    required this.bookingLinkDomain,
    required this.apiTimeout,
    required this.logLevel,
    this.extras = const {},
  });

  /// Current flavor/environment
  final Flavor flavor;

  /// Application display name
  final String appName;

  /// Platform-specific bundle/application ID
  final String bundleId;

  /// Whether to enable device_preview in debug mode
  final bool enableDevicePreview;

  /// Whether to enable debug indicators (e.g. debug banner)
  final bool displayDebugIndicators;

  /// Base domain for booking links (QR codes)
  final String bookingLinkDomain;

  /// API request timeout duration
  final Duration apiTimeout;

  /// Logging verbosity level
  final LogLevel logLevel;

  /// Extensible map for additional flavor-specific configs
  final Map<String, dynamic> extras;

  static FlavorConfig? _instance;

  /// Singleton accessor for current flavor configuration.
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static FlavorConfig get instance {
    if (_instance == null) {
      throw StateError(
        'FlavorConfig not initialized. Call FlavorConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the flavor configuration singleton.
  ///
  /// Must be called once at app startup before accessing [instance].
  /// Subsequent calls will throw [StateError].
  static void initialize(FlavorConfig config) {
    if (_instance != null) {
      throw StateError(
        'FlavorConfig already initialized. Do not call initialize() more than once.',
      );
    }
    _instance = config;
  }

  /// Creates a development flavor configuration.
  ///
  /// Enables device preview, debug overlays, verbose logging, and uses
  /// longer timeouts for debugging.
  factory FlavorConfig.dev() {
    return const FlavorConfig._(
      flavor: Flavor.dev,
      appName: 'QueueEase Dev',
      bundleId: 'com.queueease.app.dev',
      enableDevicePreview: true,
      displayDebugIndicators: true,
      bookingLinkDomain: 'dev-book.queueease.com',
      apiTimeout: Duration(seconds: 10),
      logLevel: LogLevel.verbose,
      extras: {'enableMockMode': false, 'showPerformanceOverlay': false},
    );
  }

  /// Creates a production flavor configuration.
  ///
  /// Disables debug features, uses error-only logging, and shorter timeouts
  /// for production performance.
  factory FlavorConfig.prod() {
    return const FlavorConfig._(
      flavor: Flavor.prod,
      appName: 'QueueEase',
      bundleId: 'com.queueease.app',
      enableDevicePreview: false,
      displayDebugIndicators: false,
      bookingLinkDomain: 'book.queueease.com',
      apiTimeout: Duration(seconds: 3),
      logLevel: LogLevel.error,
      extras: {},
    );
  }

  /// Check if current flavor is development
  bool get isDev => flavor == Flavor.dev;

  /// Check if current flavor is production
  bool get isProd => flavor == Flavor.prod;

  @override
  String toString() {
    return 'FlavorConfig(flavor: ${flavor.name}, appName: $appName, bundleId: $bundleId)';
  }
}
