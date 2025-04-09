import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/json_parser.dart';

/// Model class for ForecastItem data from API
class ForecastItemModel extends ForecastItem {
  /// Creates a ForecastItemModel
  const ForecastItemModel({
    required super.dateTime,
    required super.temperature,
    required super.feelsLike,
    super.tempMin,
    super.tempMax,
    required super.condition,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.windDeg,
    required super.pressure,
    required super.pop,
    super.rain,
  });

  /// Creates a ForecastItemModel from JSON
  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    try {
      const logPrefix = 'ForecastItemModel';

      // Get nested objects
      final weather =
          JsonParser.getFirstListItem(json, 'weather', logPrefix: logPrefix) ??
          {'main': 'Unknown', 'description': '', 'icon': '01d'};
      final main =
          JsonParser.getNestedObject(json, 'main', logPrefix: logPrefix) ?? {};
      final wind =
          JsonParser.getNestedObject(json, 'wind', logPrefix: logPrefix) ?? {};
      final rain = JsonParser.getNestedObject(
        json,
        'rain',
        logPrefix: logPrefix,
      );

      // Parse values with JsonParser
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

      // Min/Max temperatures (may be null in some forecast responses)
      final tempMin = JsonParser.parse<double>(
        main,
        'temp_min',
        (value) => (value as num).toDouble(),
        logPrefix: logPrefix,
      );

      final tempMax = JsonParser.parse<double>(
        main,
        'temp_max',
        (value) => (value as num).toDouble(),
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

      // Other metrics
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
      final pop = JsonParser.parseDouble(
        json,
        'pop',
        logPrefix: logPrefix,
      ); // Probability of precipitation

      // Parse timestamp
      final dateTime = JsonParser.parseDateTime(
        json,
        'dt',
        defaultValue: DateTime.now(),
        logPrefix: logPrefix,
      );

      // Rain amount (optional)
      double? rainAmount;
      if (rain != null) {
        rainAmount = JsonParser.parseDouble(rain, '3h', logPrefix: logPrefix);
      }

      return ForecastItemModel(
        dateTime: dateTime,
        temperature: temperature,
        feelsLike: feelsLike,
        tempMin: tempMin,
        tempMax: tempMax,
        condition: condition,
        description: description,
        iconCode: iconCode,
        humidity: humidity,
        windSpeed: windSpeed,
        windDeg: windDeg,
        pressure: pressure,
        pop: pop,
        rain: rainAmount,
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing forecast item JSON', e, stackTrace);
      // Create a fallback forecast item with default values
      return ForecastItemModel(
        dateTime: DateTime.now(),
        temperature: 0,
        feelsLike: 0,
        condition: 'Error',
        description: 'Failed to load forecast data',
        iconCode: '01d',
        humidity: 0,
        windSpeed: 0,
        windDeg: 0,
        pressure: 0,
        pop: 0,
      );
    }
  }

  /// Converts ForecastItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {'main': condition, 'description': description, 'icon': iconCode},
      ],
      'wind': {'speed': windSpeed, 'deg': windDeg},
      'pop': pop,
      'rain': rain != null ? {'3h': rain} : null,
    };
  }

  /// Creates a ForecastItemModel from a ForecastItem entity
  factory ForecastItemModel.fromEntity(ForecastItem forecastItem) {
    return ForecastItemModel(
      dateTime: forecastItem.dateTime,
      temperature: forecastItem.temperature,
      feelsLike: forecastItem.feelsLike,
      tempMin: forecastItem.tempMin,
      tempMax: forecastItem.tempMax,
      condition: forecastItem.condition,
      description: forecastItem.description,
      iconCode: forecastItem.iconCode,
      humidity: forecastItem.humidity,
      windSpeed: forecastItem.windSpeed,
      windDeg: forecastItem.windDeg,
      pressure: forecastItem.pressure,
      pop: forecastItem.pop,
      rain: forecastItem.rain,
    );
  }
}

/// Model class for Forecast data from API
class ForecastModel extends Forecast {
  /// Creates a ForecastModel
  const ForecastModel({
    required super.cityName,
    required super.country,
    required super.items,
    required super.timestamp,
  });

  /// Creates a ForecastModel from JSON
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    try {
      const logPrefix = 'ForecastModel';

      // Get city information
      final city =
          JsonParser.getNestedObject(json, 'city', logPrefix: logPrefix) ?? {};
      final cityName = JsonParser.parseString(
        city,
        'name',
        defaultValue: 'Unknown',
        logPrefix: logPrefix,
      );
      final country = JsonParser.parseString(
        city,
        'country',
        defaultValue: '',
        logPrefix: logPrefix,
      );

      // Parse forecast items
      final items = <ForecastItemModel>[];
      JsonParser.parseList(
        json,
        'list',
        (item) {
          if (item is Map<String, dynamic>) {
            try {
              return ForecastItemModel.fromJson(item);
            } catch (e) {
              appLogger.w('Error parsing individual forecast item: $e');
              return null;
            }
          }
          return null;
        },
        logPrefix: logPrefix,
      ).whereType<ForecastItemModel>().forEach((item) => items.add(item));

      return ForecastModel(
        cityName: cityName,
        country: country,
        items: items,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing forecast JSON', e, stackTrace);
      // Return empty forecast with default values
      return ForecastModel(
        cityName: 'Error',
        country: '',
        items: [],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Converts ForecastModel to JSON
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> itemsJson =
        items.map((item) => (item as ForecastItemModel).toJson()).toList();

    return {
      'city': {'name': cityName, 'country': country},
      'list': itemsJson,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Creates a ForecastModel from a Forecast entity
  factory ForecastModel.fromEntity(Forecast forecast) {
    // Convert items to ForecastItemModel
    final List<ForecastItemModel> itemModels =
        forecast.items
            .map((item) => ForecastItemModel.fromEntity(item))
            .toList();

    return ForecastModel(
      cityName: forecast.cityName,
      country: forecast.country,
      items: itemModels,
      timestamp: forecast.timestamp,
    );
  }
}
