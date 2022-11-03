/// A logger
abstract class Logger {
  /// Logs something
  /// [level] Log level
  /// [message] Log message
  log(LogLevel level, String message);
}

/// Log level
enum LogLevel {
  debug,
  info,
  warning,
  error
}