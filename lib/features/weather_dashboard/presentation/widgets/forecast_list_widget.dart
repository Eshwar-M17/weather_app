import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_icon.dart';

/// Widget for displaying a 5-day forecast
class ForecastListWidget extends StatelessWidget {
  /// Forecast data to display
  final Forecast forecast;

  /// Creates a forecast list widget
  const ForecastListWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final dailyForecasts = forecast.dailyForecasts;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Daily forecast items
            ...dailyForecasts
                .map((daily) => _buildDailyForecastItem(context, daily))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecastItem(BuildContext context, DailyForecast forecast) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('E, MMM d'); // e.g., "Mon, Apr 10"

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date
          SizedBox(
            width: 100,
            child: Text(
              dateFormat.format(forecast.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Weather condition icon
          WeatherIcon(iconCode: forecast.iconCode, size: 40),

          // Weather condition
          SizedBox(
            width: 80,
            child: Text(
              forecast.condition,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Temperature range
          Row(
            children: [
              Text(
                '${forecast.minTemp.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
              Text(' / '),
              Text(
                '${forecast.maxTemp.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
