import 'package:logger/logger.dart';

/// Logging utility for Scribble Arena.
/// Wraps the logger package with module-tagged output.
class AppLogger {
  final String _module;
  late final Logger _logger;

  AppLogger(this._module) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      filter: ProductionFilter(),
    );
  }

  /// Log a debug message
  void debug(String message, [dynamic data]) {
    _logger.d('[$_module] $message${data != null ? '\n$data' : ''}');
  }

  /// Log an info message
  void info(String message, [dynamic data]) {
    _logger.i('[$_module] $message${data != null ? '\n$data' : ''}');
  }

  /// Log a warning message
  void warning(String message, [dynamic data]) {
    _logger.w('[$_module] $message${data != null ? '\n$data' : ''}');
  }

  /// Log an error message
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$_module] $message', error: error, stackTrace: stackTrace);
  }

  /// Log a fatal/critical message
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f('[$_module] $message', error: error, stackTrace: stackTrace);
  }
}

/// Production filter: only show warnings and above in release mode
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In debug mode, show everything
    // In release mode, only show warning and above
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());

    if (isDebug) return true;
    return event.level.index >= Level.warning.index;
  }
}
