import 'dart:math';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/json_parser.dart';

/// Model class for Weather data from API
class WeatherModel extends Weather {
  /// Creates a WeatherModel
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.condition,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.windDeg,
    required super.pressure,
    required super.visibility,
    required super.feelsLike,
    required super.timestamp,
    required super.sunrise,
    required super.sunset,
    super.airQualityIndex,
    super.uvIndex,
    super.rainLastHour,
    super.rainForecast,
  });

  /// Creates a WeatherModel from JSON
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    try {
      appLogger.d(
        'Parsing weather JSON: ${json.toString().substring(0, min(100, json.toString().length))}...',
      );

      const logPrefix = 'WeatherModel';

      // Get weather data from the first weather item
      final weather =
          JsonParser.getFirstListItem(json, 'weather', logPrefix: logPrefix) ??
          {'main': 'Unknown', 'description': '', 'icon': '01d'};

      // Get nested objects
      final main =
          JsonParser.getNestedObject(json, 'main', logPrefix: logPrefix) ?? {};
      final wind =
          JsonParser.getNestedObject(json, 'wind', logPrefix: logPrefix) ?? {};
      final sys =
          JsonParser.getNestedObject(json, 'sys', logPrefix: logPrefix) ?? {};
      final rain = JsonParser.getNestedObject(
        json,
        'rain',
        logPrefix: logPrefix,
      );

      // Parse values with JsonParser
      final cityName = JsonParser.parseString(
        json,
        'name',
        defaultValue: 'Unknown',
        logPrefix: logPrefix,
      );
      final country = JsonParser.parseString(
        sys,
        'country',
        defaultValue: '',
        logPrefix: logPrefix,
      );

      // Temperature and feels like
      final temperature = JsonParser.parseDouble(
        main,
        'temp',
        logPrefix: logPrefix,
      );
      final feelsLike = JsonParser.parseDouble(
        main,
        'feels_like',
        logPrefix: logPrefix,
      );

      // Weather condition data
      final condition = JsonParser.parseString(
        weather,
        'main',
        defaultValue: 'Unknown',
        logPrefix: logPrefix,
      );
      final description = JsonParser.parseString(
        weather,
        'description',
        defaultValue: '',
        logPrefix: logPrefix,
      );
      final iconCode = JsonParser.parseString(
        weather,
        'icon',
        defaultValue: '01d',
        logPrefix: logPrefix,
      );

      // Other weather metrics
      final humidity = JsonParser.parseInt(
        main,
        'humidity',
        logPrefix: logPrefix,
      );
      final pressure = JsonParser.parseInt(
        main,
        'pressure',
        defaultValue: 1013,
        logPrefix: logPrefix,
      );
      final windSpeed = JsonParser.parseDouble(
        wind,
        'speed',
        logPrefix: logPrefix,
      );
      final windDeg = JsonParser.parseInt(wind, 'deg', logPrefix: logPrefix);

      // Visibility (convert from meters to kilometers)
      final visibilityMeters = JsonParser.parseInt(
        json,
        'visibility',
        defaultValue: 10000,
        logPrefix: logPrefix,
      );
      final visibilityKm = visibilityMeters ~/ 1000;

      // Rain amount
      double? rainLastHour;
      if (rain != null) {
        rainLastHour = JsonParser.parseDouble(rain, '1h', logPrefix: logPrefix);
      }

      // Timestamps
      final now = DateTime.now();
      final timestamp = JsonParser.parseDateTime(
        json,
        'dt',
        defaultValue: now,
        logPrefix: logPrefix,
      );
      final sunrise = JsonParser.parseDateTime(
        sys,
        'sunrise',
        defaultValue: now.subtract(const Duration(hours: 6)),
        logPrefix: logPrefix,
      );
      final sunset = JsonParser.parseDateTime(
        sys,
        'sunset',
        defaultValue: now.add(const Duration(hours: 6)),
        logPrefix: logPrefix,
      );

      return WeatherModel(
        cityName: cityName,
        country: country,
        temperature: temperature,
        condition: condition,
        description: description,
        iconCode: iconCode,
        humidity: humidity,
        windSpeed: windSpeed,
        windDeg: windDeg,
        pressure: pressure,
        visibility: visibilityKm,
        feelsLike: feelsLike,
        timestamp: timestamp,
        sunrise: sunrise,
        sunset: sunset,
        rainLastHour: rainLastHour,
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing weather JSON', e, stackTrace);
      // Create a fallback weather model with default values
      return WeatherModel(
        cityName: 'Error',
        country: '',
        temperature: 0,
        condition: 'Error',
        description: 'Failed to load weather data',
        iconCode: '01d',
        humidity: 0,
        windSpeed: 0,
        windDeg: 0,
        pressure: 0,
        visibility: 0,
        feelsLike: 0,
        timestamp: DateTime.now(),
        sunrise: DateTime.now().subtract(const Duration(hours: 6)),
        sunset: DateTime.now().add(const Duration(hours: 6)),
      );
    }
  }

  /// Converts WeatherModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {
        'country': country,
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {'main': condition, 'description': description, 'icon': iconCode},
      ],
      'wind': {'speed': windSpeed, 'deg': windDeg},
      'visibility': visibility * 1000, // Convert back to meters
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      'rain': rainLastHour != null ? {'1h': rainLastHour} : null,
      'air_quality_index': airQualityIndex,
      'uv_index': uvIndex,
      'rain_forecast': rainForecast,
    };
  }

  /// Creates a WeatherModel from a Weather entity
  factory WeatherModel.fromEntity(Weather weather) {
    return WeatherModel(
      cityName: weather.cityName,
      country: weather.country,
      temperature: weather.temperature,
      condition: weather.condition,
      description: weather.description,
      iconCode: weather.iconCode,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
      windDeg: weather.windDeg,
      pressure: weather.pressure,
      visibility: weather.visibility,
      feelsLike: weather.feelsLike,
      timestamp: weather.timestamp,
      sunrise: weather.sunrise,
      sunset: weather.sunset,
      airQualityIndex: weather.airQualityIndex,
      uvIndex: weather.uvIndex,
      rainLastHour: weather.rainLastHour,
      rainForecast: weather.rainForecast,
    );
  }

  // Helper function to get the minimum of two integers
  static int min(int a, int b) => a < b ? a : b;
}
