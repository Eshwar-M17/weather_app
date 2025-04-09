import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_icon.dart';

/// Widget for displaying current weather information
class CurrentWeatherWidget extends StatelessWidget {
  /// Weather data to display
  final Weather weather;

  /// Creates a current weather widget
  const CurrentWeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.cityName}, ${weather.country}',
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Updated: ${timeFormat.format(weather.timestamp)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),

            const Divider(height: 24),

            // Current temperature and condition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 56,
                          ),
                        ),
                        Text('°C', style: theme.textTheme.headlineSmall),
                      ],
                    ),
                    Text(
                      'Feels like ${weather.feelsLike.round()}°C',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    WeatherIcon(iconCode: weather.iconCode, size: 70),
                    Text(weather.condition, style: theme.textTheme.titleMedium),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weather details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailColumn(
                  context,
                  Icons.water_drop_outlined,
                  '${weather.humidity}%',
                  'Humidity',
                ),
                _buildDetailColumn(
                  context,
                  Icons.air,
                  '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  'Wind',
                ),
                _buildDetailColumn(
                  context,
                  Icons.visibility_outlined,
                  '${weather.visibility} km',
                  'Visibility',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
