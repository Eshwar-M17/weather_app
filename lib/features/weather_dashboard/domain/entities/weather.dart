import 'package:equatable/equatable.dart';

/// Represents weather data at a specific location
///
/// This entity contains current weather conditions and related
/// meteorological data for a specific location.
class Weather extends Equatable {
  /// City name
  final String cityName;

  /// Country code (ISO 3166 country codes)
  final String country;

  /// Current temperature in Celsius
  final double temperature;

  /// Weather condition (e.g., "Clear", "Rain", etc.)
  final String condition;

  /// Description of the weather condition
  final String description;

  /// Icon code for the weather condition
  final String iconCode;

  /// Humidity percentage (0-100)
  final int humidity;

  /// Wind speed in meters per second
  final double windSpeed;

  /// Wind direction in degrees (0-360, where 0 is North)
  final int? windDeg;

  /// Atmospheric pressure in hectopascals (hPa)
  final int pressure;

  /// Visibility distance in kilometers
  final int visibility;

  /// Feels like temperature in Celsius
  final double feelsLike;

  /// Timestamp of data retrieval
  final DateTime timestamp;

  /// Air quality index (optional, 1-5 where 1 is good, 5 is hazardous)
  final int? airQualityIndex;

  /// UV index (optional, 0-11+ where 0 is low, 11+ is extreme)
  final double? uvIndex;

  /// Sunrise time
  final DateTime sunrise;

  /// Sunset time
  final DateTime sunset;

  /// Rainfall in last hour in millimeters (optional)
  final double? rainLastHour;

  /// Expected rainfall in next 24h in millimeters (optional)
  final double? rainForecast;

  /// Creates a Weather entity
  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.feelsLike,
    required this.timestamp,
    required this.sunrise,
    required this.sunset,
    this.airQualityIndex,
    this.uvIndex,
    this.rainLastHour,
    this.rainForecast,
  });

  @override
  List<Object?> get props => [
    cityName,
    country,
    temperature,
    condition,
    description,
    iconCode,
    humidity,
    windSpeed,
    windDeg,
    pressure,
    visibility,
    feelsLike,
    timestamp,
    airQualityIndex,
    uvIndex,
    sunrise,
    sunset,
    rainLastHour,
    rainForecast,
  ];

  /// Creates a copy of this Weather with the given fields replaced
  Weather copyWith({
    String? cityName,
    String? country,
    double? temperature,
    String? condition,
    String? description,
    String? iconCode,
    int? humidity,
    double? windSpeed,
    int? windDeg,
    int? pressure,
    int? visibility,
    double? feelsLike,
    DateTime? timestamp,
    int? airQualityIndex,
    double? uvIndex,
    DateTime? sunrise,
    DateTime? sunset,
    double? rainLastHour,
    double? rainForecast,
  }) {
    return Weather(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDeg: windDeg ?? this.windDeg,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      feelsLike: feelsLike ?? this.feelsLike,
      timestamp: timestamp ?? this.timestamp,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      uvIndex: uvIndex ?? this.uvIndex,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      rainLastHour: rainLastHour ?? this.rainLastHour,
      rainForecast: rainForecast ?? this.rainForecast,
    );
  }

  /// Returns a string representation of this Weather instance
  @override
  String toString() =>
      'Weather(cityName: $cityName, temperature: $temperature°C, '
      'condition: $condition, timestamp: $timestamp)';
}
