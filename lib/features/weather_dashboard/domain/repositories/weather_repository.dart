import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/features/weather_dashboard/data/models/daily_forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import '../../data/models/air_quality_model.dart';

/// Interface for the weather repository
abstract class WeatherRepository {
  /// Get current weather for a city
  ///
  /// Returns Either a [Weather] entity or an [AppError]
  Future<Either<AppError, Weather>> getCurrentWeather(String cityName);

  /// Get 5-day forecast for a city
  ///
  /// Returns Either a [Forecast] entity or an [AppError]
  Future<Either<AppError, Forecast>> getForecast(String cityName);

  /// Get list of recent searches
  ///
  /// Returns Either a List of city names or an [AppError]
  Future<Either<AppError, List<String>>> getRecentSearches();

  /// Save a city to recent searches
  ///
  /// Returns true if successful, false otherwise
  Future<bool> saveToRecentSearches(String cityName);

  /// Clear all recent searches
  ///
  /// Returns true if successful, false otherwise
  Future<bool> clearRecentSearches();

  /// Checks if there is cached weather data
  ///
  /// Returns true if cached data exists and is still valid
  Future<bool> hasCachedWeatherData();

  /// Checks if there is cached weekly forecast data
  ///
  /// Returns true if cached data exists and is still valid
  Future<bool> hasCachedWeeklyForecastData();

  /// Get cached current weather
  ///
  /// Returns Either a [Weather] entity or an [AppError]
  Future<Either<AppError, Weather>> getCachedCurrentWeather();

  /// Get cached forecast
  ///
  /// Returns Either a [Forecast] entity or an [AppError]
  Future<Either<AppError, Forecast>> getCachedForecast();

  /// Get cached weekly forecast
  ///
  /// Returns Either a [WeeklyForecastModel] or an [AppError]
  Future<Either<AppError, WeeklyForecastModel>> getCachedWeeklyForecast();

  /// Checks if the device has an internet connection
  ///
  /// Returns true if connected, false otherwise
  Future<bool> isConnected();

  /// Checks if there's cached weather data for a specific city
  ///
  /// Returns true if valid cached data exists for this city, false otherwise
  Future<bool> hasCachedWeatherDataForCity(String cityName);

  /// Checks if there's cached forecast data for a specific city
  ///
  /// Returns true if valid cached data exists for this city, false otherwise
  Future<bool> hasCachedForecastDataForCity(String cityName);

  /// Retrieves cached weather data for a specific city
  ///
  /// Returns Either<AppError, Weather> containing the cached weather data or an error
  Future<Either<AppError, Weather>> getCachedWeatherForCity(String cityName);

  /// Retrieves cached forecast data for a specific city
  ///
  /// Returns Either<AppError, Forecast> containing the cached forecast data or an error
  Future<Either<AppError, Forecast>> getCachedForecastForCity(String cityName);

  /// Gets air quality data for the specified latitude and longitude
  ///
  /// Returns [Either] with [AirQualityModel] on success, or an [Error] on failure
  Future<Either<Error, AirQualityModel>> getAirQuality(double lat, double lon);
}
