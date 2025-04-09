import 'package:flutter/material.dart';

/// Widget to display when network resources fail to load
class NetworkErrorWidget extends StatelessWidget {
  /// The error message to display
  final String? message;

  /// Size of the error icon
  final double iconSize;

  /// Text style for the error message
  final TextStyle? textStyle;

  /// Creates a network error widget
  const NetworkErrorWidget({
    super.key,
    this.message,
    this.iconSize = 40,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: iconSize, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message ?? 'Network error',
            style:
                textStyle ??
                TextStyle(color: Colors.grey.shade700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a fallback weather icon when the network icon fails to load
class FallbackWeatherIcon extends StatelessWidget {
  /// The weather condition to determine which fallback icon to show
  final String? condition;

  /// Size of the icon
  final double size;

  /// Creates a fallback weather icon widget
  const FallbackWeatherIcon({super.key, this.condition, required this.size});

  @override
  Widget build(BuildContext context) {
    // Determine icon based on condition text
    IconData iconData = Icons.cloud;

    final lowercaseCondition = condition?.toLowerCase() ?? '';

    if (lowercaseCondition.contains('sun') ||
        lowercaseCondition.contains('clear')) {
      iconData = Icons.wb_sunny;
    } else if (lowercaseCondition.contains('rain')) {
      iconData = Icons.grain;
    } else if (lowercaseCondition.contains('thunder') ||
        lowercaseCondition.contains('storm')) {
      iconData = Icons.flash_on;
    } else if (lowercaseCondition.contains('snow')) {
      iconData = Icons.ac_unit;
    } else if (lowercaseCondition.contains('mist') ||
        lowercaseCondition.contains('fog')) {
      iconData = Icons.blur_on;
    }

    return Icon(iconData, size: size, color: Colors.white);
  }
}
