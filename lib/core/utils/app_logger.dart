import 'package:logger/logger.dart';

/// AppLogger is a utility class for consistent logging throughout the app.
/// It provides methods for logging different types of messages: debug, info, warning, and error.
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  // Create a singleton instance
  static final AppLogger _instance = AppLogger._();

  // Factory constructor to return the singleton instance
  factory AppLogger() => _instance;

  // Create a logger instance with custom settings
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to display
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Print time for each log message
    ),
  );

  /// Log a debug message
  ///
  /// Used for detailed information during development
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  ///
  /// Used for general information about app operation
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  ///
  /// Used for potential issues that aren't errors
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  ///
  /// Used for errors and exceptions
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// Create a global instance for easy access
final appLogger = AppLogger();
