import 'package:flutter/material.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// Enhanced widget for displaying error states with user-friendly messages
class WeatherErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Callback for retry action
  final VoidCallback onRetry;

  /// Whether this is a network error
  final bool isNetworkError;

  /// Creates a weather error widget with enhanced UX
  const WeatherErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildErrorCard(context);
  }

  Widget _buildErrorCard(BuildContext context) {
    // Determine error type and appropriate icon/message
    final ErrorType errorType = _determineErrorType();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon with circle background
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: errorType.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(errorType.icon, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 24),

          // Error title
          Text(
            errorType.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Error message
          Text(
            _getUserFriendlyMessage(errorType),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Retry button
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Debug info expandable section
          if (errorType != ErrorType.unknown) const SizedBox(height: 24),

          if (errorType != ErrorType.unknown) _buildDebugInfoSection(),
        ],
      ),
    );
  }

  Widget _buildDebugInfoSection() {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white70,
      ),
      child: ExpansionTile(
        title: const Text(
          'Debug Info',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determines the type of error from the error message
  ErrorType _determineErrorType() {
    if (isNetworkError ||
        message.contains('Network Error') ||
        message.contains('internet connection') ||
        message.contains('No internet') ||
        message.contains('network error')) {
      return ErrorType.network;
    } else if (message.contains('city not found') ||
        message.contains('City not found') ||
        message.contains('spelling')) {
      return ErrorType.cityNotFound;
    } else if (message.contains('Server Error') ||
        message.contains('server error') ||
        message.contains('timed out') ||
        message.contains('timeout')) {
      return ErrorType.server;
    } else if (message.contains('API key') ||
        message.contains('api key') ||
        message.contains('unauthorized')) {
      return ErrorType.authorization;
    } else if (message.contains('Cache Error') ||
        message.contains('cache error') ||
        message.contains('No cached')) {
      return ErrorType.cache;
    }

    return ErrorType.unknown;
  }

  /// Returns a user-friendly message based on the error type
  String _getUserFriendlyMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.cityNotFound:
        return 'We couldn\'t find the city you\'re looking for. Please check the spelling and try again.';
      case ErrorType.server:
        return 'Our weather service is experiencing some issues. Please try again in a few moments.';
      case ErrorType.authorization:
        return 'There\'s an issue with the app\'s weather service access. Please contact support.';
      case ErrorType.cache:
        return 'We couldn\'t load saved weather data. Try searching for a city.';
      case ErrorType.unknown:
      default:
        return message;
    }
  }
}

/// Enum representing different types of errors
enum ErrorType { network, cityNotFound, server, authorization, cache, unknown }

/// Extension to add properties to error types
extension ErrorTypeProperties on ErrorType {
  /// Gets the icon for this error type
  IconData get icon {
    switch (this) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.cityNotFound:
        return Icons.location_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.authorization:
        return Icons.lock_rounded;
      case ErrorType.cache:
        return Icons.storage_rounded;
      case ErrorType.unknown:
      default:
        return Icons.error_outline_rounded;
    }
  }

  /// Gets the title for this error type
  String get title {
    switch (this) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.cityNotFound:
        return 'City Not Found';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.authorization:
        return 'Access Error';
      case ErrorType.cache:
        return 'Data Error';
      case ErrorType.unknown:
      default:
        return 'Error';
    }
  }

  /// Gets the background color for the icon
  Color get iconBackground {
    switch (this) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.cityNotFound:
        return Colors.purple;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authorization:
        return Colors.red.shade800;
      case ErrorType.cache:
        return Colors.blue;
      case ErrorType.unknown:
      default:
        return Colors.red;
    }
  }
}
