import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/icon_mapper.dart';

/// Widget for displaying weather icons
class WeatherIcon extends StatelessWidget {
  /// The weather condition icon code from API
  final String iconCode;

  /// Size of the icon
  final double size;

  /// The weather condition text (used for fallback)
  final String? condition;

  /// Creates a weather icon widget
  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 50,
    this.condition,
  });

  @override
  Widget build(BuildContext context) {
    final iconAsset = WeatherIconMapper.getIconAsset(iconCode);

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        iconAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // If the specific icon is not available, use a condition-based fallback
          return Image.asset(
            WeatherIconMapper.getFallbackIcon(condition),
            width: size,
            height: size,
            fit: BoxFit.contain,
            // If even the fallback fails, show a simple icon
            errorBuilder: (context, error, stackTrace) {
              IconData iconData = Icons.cloud;

              if (condition != null) {
                final lowercaseCondition = condition!.toLowerCase();
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
              }

              return Icon(iconData, size: size, color: Colors.white);
            },
          );
        },
      ),
    );
  }
}
