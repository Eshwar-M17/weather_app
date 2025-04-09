import 'package:equatable/equatable.dart';

/// Represents a single forecast item for a specific timestamp
class ForecastItem extends Equatable {
  /// Date and time of the forecast
  final DateTime dateTime;

  /// Temperature in Celsius
  final double temperature;

  /// Feels like temperature in Celsius
  final double feelsLike;

  /// Minimum temperature in Celsius
  final double? tempMin;

  /// Maximum temperature in Celsius
  final double? tempMax;

  /// Weather condition (e.g., "Clear", "Rain", etc.)
  final String condition;

  /// Description of the weather condition
  final String description;

  /// Icon code for the weather condition
  final String iconCode;

  /// Humidity percentage
  final int humidity;

  /// Wind speed in km/h
  final double windSpeed;

  /// Wind direction in degrees (0-360)
  final int windDeg;

  /// Atmospheric pressure in hPa
  final int pressure;

  /// Probability of precipitation (0-1)
  final double pop;

  /// Rainfall amount in mm (optional)
  final double? rain;

  /// Creates a ForecastItem
  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    this.tempMin,
    this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.pop,
    this.rain,
  });

  @override
  List<Object?> get props => [
    dateTime,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    condition,
    description,
    iconCode,
    humidity,
    windSpeed,
    windDeg,
    pressure,
    pop,
    rain,
  ];
}

/// Represents a 5-day weather forecast for a location
class Forecast extends Equatable {
  /// City name
  final String cityName;

  /// Country code
  final String country;

  /// List of forecast items
  final List<ForecastItem> items;

  /// Timestamp of data retrieval
  final DateTime timestamp;

  /// Creates a Forecast entity
  const Forecast({
    required this.cityName,
    required this.country,
    required this.items,
    required this.timestamp,
  });

  @override
  List<Object> get props => [cityName, country, items, timestamp];

  /// Get forecast items grouped by day
  Map<DateTime, List<ForecastItem>> get itemsByDay {
    final Map<DateTime, List<ForecastItem>> result = {};

    for (final item in items) {
      // Create a DateTime with just the date (no time)
      final date = DateTime(
        item.dateTime.year,
        item.dateTime.month,
        item.dateTime.day,
      );

      // Add to the map
      if (result.containsKey(date)) {
        result[date]!.add(item);
      } else {
        result[date] = [item];
      }
    }

    return result;
  }

  /// Get daily forecast with min and max temperatures
  List<DailyForecast> get dailyForecasts {
    final dailyMap = itemsByDay;
    final List<DailyForecast> dailyList = [];

    dailyMap.forEach((date, items) {
      // Calculate min and max temperatures
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      String mostFrequentCondition = '';
      String mostFrequentIconCode = '';

      // Count occurrences of each condition
      final Map<String, int> conditionCounts = {};

      for (final item in items) {
        // Update min and max temperatures
        if (item.temperature < minTemp) {
          minTemp = item.temperature;
        }
        if (item.temperature > maxTemp) {
          maxTemp = item.temperature;
        }

        // Count conditions
        final condition = item.condition;
        conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
      }

      // Find most frequent condition
      int maxCount = 0;
      conditionCounts.forEach((condition, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentCondition = condition;
        }
      });

      // Find icon code for most frequent condition
      for (final item in items) {
        if (item.condition == mostFrequentCondition) {
          mostFrequentIconCode = item.iconCode;
          break;
        }
      }

      // Noon forecast for the representative temperature
      ForecastItem? noonForecast;
      for (final item in items) {
        if (item.dateTime.hour == 12 || item.dateTime.hour == 13) {
          noonForecast = item;
          break;
        }
      }

      // Use noon temperature or average if noon not available
      double dayTemp;
      if (noonForecast != null) {
        dayTemp = noonForecast.temperature;
      } else {
        // Calculate average
        double sum = 0;
        for (final item in items) {
          sum += item.temperature;
        }
        dayTemp = sum / items.length;
      }

      // Create daily forecast
      dailyList.add(
        DailyForecast(
          date: date,
          avgTemp: dayTemp,
          minTemp: minTemp,
          maxTemp: maxTemp,
          condition: mostFrequentCondition,
          iconCode: mostFrequentIconCode,
          hourlyForecasts: items,
        ),
      );
    });

    // Sort by date
    dailyList.sort((a, b) => a.date.compareTo(b.date));

    return dailyList;
  }
}

/// Represents a daily weather forecast
class DailyForecast extends Equatable {
  /// Date of the forecast
  final DateTime date;

  /// Average temperature in Celsius
  final double avgTemp;

  /// Minimum temperature in Celsius
  final double minTemp;

  /// Maximum temperature in Celsius
  final double maxTemp;

  /// Most frequent weather condition of the day
  final String condition;

  /// Icon code for the weather condition
  final String iconCode;

  /// Hourly forecasts for this day
  final List<ForecastItem> hourlyForecasts;

  /// Creates a DailyForecast
  const DailyForecast({
    required this.date,
    required this.avgTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.iconCode,
    required this.hourlyForecasts,
  });

  @override
  List<Object> get props => [
    date,
    avgTemp,
    minTemp,
    maxTemp,
    condition,
    iconCode,
    hourlyForecasts,
  ];
}
