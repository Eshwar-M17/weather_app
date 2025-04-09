import 'package:flutter/material.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// A card that displays a specific weather detail
class WeatherDetailCard extends StatelessWidget {
  /// The title or label for the detail (e.g., "HUMIDITY", "WIND", etc.)
  final String title;

  /// The icon to display (typically a weather-related icon)
  final IconData icon;

  /// The primary value to display (e.g., "90%", "9.7 km/h", etc.)
  final String value;

  /// The unit or additional information (optional)
  final String? unit;

  /// Additional description text (optional)
  final String? description;

  /// Widget to display instead of the simple value (optional)
  /// If provided, this will be used instead of the value and unit.
  final Widget? customContent;

  /// Creates a weather detail card
  const WeatherDetailCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.unit,
    this.description,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and icon
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 12),

          // Main content
          if (customContent != null)
            customContent!
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (unit != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
                        child: Text(
                          unit!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ],
            ),

          // Description
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
