import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart' hide LogLevel;

import '../config/flavor_config.dart';

/// Application-wide logger backed by [Talker].
///
/// Registered as a singleton via `injectable` so every layer can inject it.
/// Log verbosity is driven by [FlavorConfig.logLevel]:
/// - `verbose` → debug + info + warning + error
/// - `info`    → info + warning + error (suppresses debug)
/// - `error`   → error + critical only
///
/// The underlying [talker] instance is exposed so consumers (e.g. main_dev.dart)
/// can attach [TalkerBlocObserver] or the [TalkerScreen] overlay.
///
/// Example:
/// ```dart
/// final logger = getIt<AppLogger>();
/// logger.info('User signed in', user.uid);
/// logger.error('Sign-in failed', exception, stackTrace);
/// ```
@singleton
class AppLogger {
  AppLogger(this._config) {
    _talker = Talker(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        maxHistoryItems: 500,
      ),
    );
  }

  final FlavorConfig _config;
  late final Talker _talker;

  /// The underlying [Talker] instance.
  ///
  /// Expose this to attach [TalkerBlocObserver] or mount the [TalkerScreen].
  Talker get talker => _talker;

  // --------------------------------------------------------------------------
  // Level gates (derived from FlavorConfig)
  // --------------------------------------------------------------------------

  bool get _isVerbose => _config.logLevel == LogLevel.verbose;
  bool get _isInfoOrAbove =>
      _config.logLevel == LogLevel.verbose || _config.logLevel == LogLevel.info;

  // --------------------------------------------------------------------------
  // Logging methods
  // --------------------------------------------------------------------------

  /// Fine-grained diagnostic messages. Suppressed unless [LogLevel.verbose].
  void debug(String message, [Object? extra]) {
    if (_isVerbose) _talker.debug(message, extra);
  }

  /// Informational messages about normal app behaviour. Suppressed at
  /// [LogLevel.error].
  void info(String message, [Object? extra]) {
    if (_isInfoOrAbove) _talker.info(message, extra);
  }

  /// Warning messages for recoverable, unexpected situations. Suppressed at
  /// [LogLevel.error].
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isInfoOrAbove) _talker.warning(message, error, stackTrace);
  }

  /// Non-fatal errors. Always logged regardless of level.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  /// Fatal / critical errors. Always logged regardless of level.
  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.critical(message, error, stackTrace);
  }
}
