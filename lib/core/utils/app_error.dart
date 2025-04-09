import 'package:equatable/equatable.dart';

/// Abstract class for all application-specific errors
///
/// Extends Equatable for easy comparison of error types
abstract class AppError extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const AppError({required this.message, this.stackTrace});

  @override
  List<Object?> get props => [message, stackTrace];
}

/// Error for server failures (API errors, timeouts, etc.)
class ServerError extends AppError {
  const ServerError({required String message, StackTrace? stackTrace})
    : super(message: message, stackTrace: stackTrace);
}

/// Error for network connectivity issues
class NetworkError extends AppError {
  const NetworkError({required String message, StackTrace? stackTrace})
    : super(message: message, stackTrace: stackTrace);
}

/// Error for cache failures (data not found, corrupted cache, etc.)
class CacheError extends AppError {
  const CacheError({required String message, StackTrace? stackTrace})
    : super(message: message, stackTrace: stackTrace);
}

/// Error for location-related failures
class LocationError extends AppError {
  const LocationError({required String message, StackTrace? stackTrace})
    : super(message: message, stackTrace: stackTrace);
}

/// Error when city is not found in the API
class CityNotFoundError extends AppError {
  const CityNotFoundError({required String message, StackTrace? stackTrace})
    : super(message: message, stackTrace: stackTrace);
}
