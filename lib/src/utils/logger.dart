

/// A logger
abstract class Logger {
  /// Logs something
  /// [level] Log level
  /// [message] Log message
  log(LogLevel level, String message);

  /// Creates a logger that prints to the console
  const factory Logger.print() = _PrintLogger;
}

/// Log level
enum LogLevel {
  debug,
  info,
  warning,
  error
}

/// Prints to console
class _PrintLogger implements Logger {

  const _PrintLogger();

  @override
  log(LogLevel level, String message) {
    print('${DateTime.now().toIso8601String()} - $level: $message');
  }
}