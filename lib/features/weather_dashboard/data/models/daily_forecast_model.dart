import 'dart:convert';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/json_parser.dart';
import 'package:weather_app/features/weather_dashboard/data/models/forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';

/// Model class for DailyForecast data for serialization/deserialization
class DailyForecastModel extends DailyForecast {
  /// Creates a DailyForecastModel
  const DailyForecastModel({
    required super.date,
    required super.avgTemp,
    required super.minTemp,
    required super.maxTemp,
    required super.condition,
    required super.iconCode,
    required super.hourlyForecasts,
  });

  /// Creates a DailyForecastModel from JSON
  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    try {
      appLogger.d('Parsing daily forecast JSON');
      const logPrefix = 'DailyForecastModel';

      // Parse date
      final date = DateTime.fromMillisecondsSinceEpoch(
        JsonParser.parseInt(json, 'date', logPrefix: logPrefix),
      );

      // Parse temperatures
      final avgTemp = JsonParser.parseDouble(
        json,
        'avgTemp',
        logPrefix: logPrefix,
      );
      final minTemp = JsonParser.parseDouble(
        json,
        'minTemp',
        logPrefix: logPrefix,
      );
      final maxTemp = JsonParser.parseDouble(
        json,
        'maxTemp',
        logPrefix: logPrefix,
      );

      // Parse condition and icon
      final condition = JsonParser.parseString(
        json,
        'condition',
        logPrefix: logPrefix,
      );
      final iconCode = JsonParser.parseString(
        json,
        'iconCode',
        logPrefix: logPrefix,
      );

      // Parse hourly forecasts
      final hourlyForecasts = <ForecastItem>[];
      JsonParser.parseList(
        json,
        'hourlyForecasts',
        (hourly) {
          if (hourly is Map<String, dynamic>) {
            try {
              return ForecastItemModel.fromJson(hourly);
            } catch (e) {
              appLogger.w('Error parsing individual hourly forecast: $e');
              return null;
            }
          }
          return null;
        },
        logPrefix: logPrefix,
      ).whereType<ForecastItem>().forEach((item) => hourlyForecasts.add(item));

      return DailyForecastModel(
        date: date,
        avgTemp: avgTemp,
        minTemp: minTemp,
        maxTemp: maxTemp,
        condition: condition,
        iconCode: iconCode,
        hourlyForecasts: hourlyForecasts,
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing daily forecast JSON', e, stackTrace);
      // Return a default model as fallback
      return DailyForecastModel(
        date: DateTime.now(),
        avgTemp: 0,
        minTemp: 0,
        maxTemp: 0,
        condition: 'Unknown',
        iconCode: '01d',
        hourlyForecasts: [],
      );
    }
  }

  /// Converts DailyForecastModel to JSON
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> hourlyJson =
        hourlyForecasts
            .map((item) => (item as ForecastItemModel).toJson())
            .toList();

    return {
      'date': date.millisecondsSinceEpoch,
      'avgTemp': avgTemp,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'condition': condition,
      'iconCode': iconCode,
      'hourlyForecasts': hourlyJson,
    };
  }

  /// Creates a DailyForecastModel from a DailyForecast entity
  factory DailyForecastModel.fromEntity(DailyForecast forecast) {
    // Convert hourly forecasts to models
    final hourlyModels =
        forecast.hourlyForecasts
            .map((hourly) => ForecastItemModel.fromEntity(hourly))
            .toList();

    return DailyForecastModel(
      date: forecast.date,
      avgTemp: forecast.avgTemp,
      minTemp: forecast.minTemp,
      maxTemp: forecast.maxTemp,
      condition: forecast.condition,
      iconCode: forecast.iconCode,
      hourlyForecasts: hourlyModels,
    );
  }
}

/// Container class for a list of daily forecasts
class WeeklyForecastModel {
  /// City name
  final String cityName;

  /// Country code
  final String country;

  /// List of daily forecasts
  final List<DailyForecastModel> dailyForecasts;

  /// Timestamp of when the forecast was retrieved
  final DateTime timestamp;

  /// Creates a new weekly forecast model
  WeeklyForecastModel({
    required this.cityName,
    required this.country,
    required this.dailyForecasts,
    required this.timestamp,
  });

  /// Creates a WeeklyForecastModel from JSON
  factory WeeklyForecastModel.fromJson(Map<String, dynamic> json) {
    try {
      appLogger.d('Parsing weekly forecast JSON');
      const logPrefix = 'WeeklyForecastModel';

      // Parse city and country
      final cityName = JsonParser.parseString(
        json,
        'cityName',
        logPrefix: logPrefix,
      );
      final country = JsonParser.parseString(
        json,
        'country',
        logPrefix: logPrefix,
      );

      // Parse timestamp
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        JsonParser.parseInt(json, 'timestamp', logPrefix: logPrefix),
      );

      // Parse daily forecasts
      final dailyForecasts = <DailyForecastModel>[];
      JsonParser.parseList(json, 'dailyForecasts', (daily) {
        if (daily is Map<String, dynamic>) {
          try {
            return DailyForecastModel.fromJson(daily);
          } catch (e) {
            appLogger.w('Error parsing individual daily forecast: $e');
            return null;
          }
        }
        return null;
      }, logPrefix: logPrefix).whereType<DailyForecastModel>().forEach(
        (model) => dailyForecasts.add(model),
      );

      return WeeklyForecastModel(
        cityName: cityName,
        country: country,
        dailyForecasts: dailyForecasts,
        timestamp: timestamp,
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing weekly forecast JSON', e, stackTrace);
      // Return empty model as fallback
      return WeeklyForecastModel(
        cityName: 'Unknown',
        country: '',
        dailyForecasts: [],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Converts WeeklyForecastModel to JSON
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> dailyJson =
        dailyForecasts.map((daily) => daily.toJson()).toList();

    return {
      'cityName': cityName,
      'country': country,
      'dailyForecasts': dailyJson,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Creates a WeeklyForecastModel from a Forecast entity
  factory WeeklyForecastModel.fromForecast(Forecast forecast) {
    final dailyForecasts =
        forecast.dailyForecasts
            .map((daily) => DailyForecastModel.fromEntity(daily))
            .toList();

    return WeeklyForecastModel(
      cityName: forecast.cityName,
      country: forecast.country,
      dailyForecasts: dailyForecasts,
      timestamp: forecast.timestamp,
    );
  }
}
