import 'dart:convert';

import 'package:weather_app/core/cache/cache_service.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/data/models/daily_forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/weather_model.dart';

/// Interface for the weather local data source
abstract class WeatherLocalDataSource {
  /// Caches current weather data
  ///
  /// Returns true if successful, false otherwise
  Future<bool> cacheCurrentWeather(WeatherModel weather);

  /// Caches forecast data
  ///
  /// Returns true if successful, false otherwise
  Future<bool> cacheForecast(ForecastModel forecast);

  /// Caches weekly forecast data
  ///
  /// Returns true if successful, false otherwise
  Future<bool> cacheWeeklyForecast(WeeklyForecastModel weeklyForecast);

  /// Retrieves cached current weather data
  ///
  /// Throws a [CacheError] if no cached data exists or it's invalid
  Future<WeatherModel> getCachedCurrentWeather();

  /// Retrieves cached weather data for a specific city
  ///
  /// Throws a [CacheError] if no cached data exists or it's invalid for the city
  Future<WeatherModel> getCachedWeatherForCity(String cityName);

  /// Retrieves cached forecast data
  ///
  /// Throws a [CacheError] if no cached data exists or it's invalid
  Future<ForecastModel> getCachedForecast();

  /// Retrieves cached forecast data for a specific city
  ///
  /// Throws a [CacheError] if no cached data exists or it's invalid for the city
  Future<ForecastModel> getCachedForecastForCity(String cityName);

  /// Retrieves cached weekly forecast data
  ///
  /// Throws a [CacheError] if no cached data exists or it's invalid
  Future<WeeklyForecastModel> getCachedWeeklyForecast();

  /// Saves a city to recent searches
  ///
  /// Returns true if successful, false otherwise
  Future<bool> saveToRecentSearches(String cityName);

  /// Retrieves the list of recent searches
  ///
  /// Returns an empty list if no searches exist
  Future<List<String>> getRecentSearches();

  /// Clears all recent searches
  ///
  /// Returns true if successful, false otherwise
  Future<bool> clearRecentSearches();

  /// Checks if cached weather data exists and is still valid
  ///
  /// Returns true if valid cached data exists, false otherwise
  Future<bool> hasCachedWeatherData();

  /// Checks if cached weekly forecast data exists
  ///
  /// Returns true if valid cached data exists, false otherwise
  Future<bool> hasCachedWeeklyForecastData();

  /// Checks if there's cached weather data for a specific city
  ///
  /// Returns true if valid cached data exists for this city, false otherwise
  Future<bool> hasCachedWeatherDataForCity(String cityName);

  /// Checks if there's cached forecast data for a specific city
  ///
  /// Returns true if valid cached data exists for this city, false otherwise
  Future<bool> hasCachedForecastDataForCity(String cityName);
}

/// Implementation of WeatherLocalDataSource using CacheService
class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final CacheService _cacheService;

  /// Constructor that accepts CacheService for dependency injection
  WeatherLocalDataSourceImpl({required CacheService cacheService})
    : _cacheService = cacheService;

  @override
  Future<bool> cacheCurrentWeather(WeatherModel weather) async {
    appLogger.i(
      'WeatherLocalDataSource: Caching current weather for ${weather.cityName}',
    );

    try {
      // Cache in general key for default/last city
      final result = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cachedCurrentWeather,
        data: weather.toJson(),
        customExpiry: const Duration(
          hours: 1,
        ), // Weather data expires after 1 hour
      );

      // Also cache in city-specific key
      final cityResult = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cityWeatherCacheKey(weather.cityName),
        data: weather.toJson(),
        customExpiry: const Duration(hours: 1),
      );

      appLogger.i(
        'WeatherLocalDataSource: Successfully cached current weather for ${weather.cityName}',
      );
      return result && cityResult;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error caching current weather',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> cacheForecast(ForecastModel forecast) async {
    appLogger.i(
      'WeatherLocalDataSource: Caching forecast for ${forecast.cityName}',
    );

    try {
      // Cache in general key for default/last city
      final result = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cachedForecast,
        data: forecast.toJson(),
        customExpiry: const Duration(
          hours: 3,
        ), // Forecast data expires after 3 hours
      );

      // Also cache in city-specific key
      final cityResult = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cityForecastCacheKey(forecast.cityName),
        data: forecast.toJson(),
        customExpiry: const Duration(hours: 3),
      );

      appLogger.i(
        'WeatherLocalDataSource: Successfully cached forecast for ${forecast.cityName}',
      );
      return result && cityResult;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error caching forecast',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> cacheWeeklyForecast(WeeklyForecastModel weeklyForecast) async {
    appLogger.i(
      'WeatherLocalDataSource: Caching weekly forecast for ${weeklyForecast.cityName}',
    );

    try {
      // Cache in general key for default/last city
      final result = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cachedWeeklyForecast,
        data: weeklyForecast.toJson(),
        customExpiry: const Duration(
          hours: 6,
        ), // Weekly forecast expires after 6 hours
      );

      // Also cache in city-specific key
      final cityResult = await _cacheService.saveData<Map<String, dynamic>>(
        key: CacheConstants.cityWeeklyForecastCacheKey(weeklyForecast.cityName),
        data: weeklyForecast.toJson(),
        customExpiry: const Duration(hours: 6),
      );

      appLogger.i(
        'WeatherLocalDataSource: Successfully cached weekly forecast for ${weeklyForecast.cityName}',
      );
      return result && cityResult;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error caching weekly forecast',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<WeatherModel> getCachedCurrentWeather() async {
    appLogger.i('WeatherLocalDataSource: Getting cached current weather');

    try {
      final weatherJson = _cacheService.getData<Map<String, dynamic>>(
        key: CacheConstants.cachedCurrentWeather,
        fromJson:
            (jsonString) => json.decode(jsonString) as Map<String, dynamic>,
      );

      if (weatherJson == null) {
        appLogger.w('WeatherLocalDataSource: No cached current weather found');
        throw const CacheError(message: 'No cached current weather found');
      }

      return WeatherModel.fromJson(weatherJson);
    } catch (e, stackTrace) {
      if (e is CacheError) {
        rethrow;
      }

      appLogger.e(
        'WeatherLocalDataSource: Error retrieving cached current weather',
        e,
        stackTrace,
      );
      throw CacheError(
        message: 'Failed to retrieve cached current weather: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  /// Get cached weather data for a specific city
  Future<WeatherModel> getCachedWeatherForCity(String cityName) async {
    appLogger.i('WeatherLocalDataSource: Getting cached weather for $cityName');

    try {
      final cityKey = CacheConstants.cityWeatherCacheKey(cityName);
      final weatherJson = _cacheService.getData<Map<String, dynamic>>(
        key: cityKey,
        fromJson:
            (jsonString) => json.decode(jsonString) as Map<String, dynamic>,
      );

      if (weatherJson == null) {
        appLogger.w(
          'WeatherLocalDataSource: No cached weather found for $cityName',
        );
        throw CacheError(message: 'No cached weather found for $cityName');
      }

      return WeatherModel.fromJson(weatherJson);
    } catch (e, stackTrace) {
      if (e is CacheError) {
        rethrow;
      }

      appLogger.e(
        'WeatherLocalDataSource: Error retrieving cached weather for city',
        e,
        stackTrace,
      );
      throw CacheError(
        message: 'Failed to retrieve cached weather for city: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ForecastModel> getCachedForecast() async {
    appLogger.i('WeatherLocalDataSource: Getting cached forecast');

    try {
      final forecastJson = _cacheService.getData<Map<String, dynamic>>(
        key: CacheConstants.cachedForecast,
        fromJson:
            (jsonString) => json.decode(jsonString) as Map<String, dynamic>,
      );

      if (forecastJson == null) {
        appLogger.w('WeatherLocalDataSource: No cached forecast found');
        throw const CacheError(message: 'No cached forecast found');
      }

      return ForecastModel.fromJson(forecastJson);
    } catch (e, stackTrace) {
      if (e is CacheError) {
        rethrow;
      }

      appLogger.e(
        'WeatherLocalDataSource: Error retrieving cached forecast',
        e,
        stackTrace,
      );
      throw CacheError(
        message: 'Failed to retrieve cached forecast: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  /// Get cached forecast data for a specific city
  Future<ForecastModel> getCachedForecastForCity(String cityName) async {
    appLogger.i(
      'WeatherLocalDataSource: Getting cached forecast for $cityName',
    );

    try {
      final cityKey = CacheConstants.cityForecastCacheKey(cityName);
      final forecastJson = _cacheService.getData<Map<String, dynamic>>(
        key: cityKey,
        fromJson:
            (jsonString) => json.decode(jsonString) as Map<String, dynamic>,
      );

      if (forecastJson == null) {
        appLogger.w(
          'WeatherLocalDataSource: No cached forecast found for $cityName',
        );
        throw CacheError(message: 'No cached forecast found for $cityName');
      }

      return ForecastModel.fromJson(forecastJson);
    } catch (e, stackTrace) {
      if (e is CacheError) {
        rethrow;
      }

      appLogger.e(
        'WeatherLocalDataSource: Error retrieving cached forecast for city',
        e,
        stackTrace,
      );
      throw CacheError(
        message: 'Failed to retrieve cached forecast for city: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<WeeklyForecastModel> getCachedWeeklyForecast() async {
    appLogger.i('WeatherLocalDataSource: Getting cached weekly forecast');

    try {
      final weeklyForecastJson = _cacheService.getData<Map<String, dynamic>>(
        key: CacheConstants.cachedWeeklyForecast,
        fromJson:
            (jsonString) => json.decode(jsonString) as Map<String, dynamic>,
      );

      if (weeklyForecastJson == null) {
        appLogger.w('WeatherLocalDataSource: No cached weekly forecast found');
        throw const CacheError(message: 'No cached weekly forecast found');
      }

      return WeeklyForecastModel.fromJson(weeklyForecastJson);
    } catch (e, stackTrace) {
      if (e is CacheError) {
        rethrow;
      }

      appLogger.e(
        'WeatherLocalDataSource: Error retrieving cached weekly forecast',
        e,
        stackTrace,
      );
      throw CacheError(
        message: 'Failed to retrieve cached weekly forecast: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> saveToRecentSearches(String cityName) async {
    appLogger.i('WeatherLocalDataSource: Saving $cityName to recent searches');

    try {
      // Get current list - create a new List from the unmodifiable list
      final currentSearches = List<String>.from(await getRecentSearches());

      // Remove if already present
      currentSearches.remove(cityName);

      // Add to beginning
      currentSearches.insert(0, cityName);

      // Save updated list
      final result = await _cacheService.saveStringList(
        key: AppConstants.recentSearchesKey,
        items: currentSearches,
        maxItems: AppConstants.maxRecentSearches,
      );

      appLogger.i(
        'WeatherLocalDataSource: Successfully saved to recent searches',
      );
      return result;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error saving to recent searches',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    appLogger.i('WeatherLocalDataSource: Getting recent searches');

    try {
      final searches = _cacheService.getStringList(
        key: AppConstants.recentSearchesKey,
      );

      appLogger.i(
        'WeatherLocalDataSource: Found ${searches.length} recent searches',
      );
      return searches;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error retrieving recent searches',
        e,
        stackTrace,
      );
      return [];
    }
  }

  @override
  Future<bool> clearRecentSearches() async {
    appLogger.i('WeatherLocalDataSource: Clearing recent searches');

    try {
      final result = await _cacheService.removeData(
        AppConstants.recentSearchesKey,
      );
      appLogger.i(
        'WeatherLocalDataSource: Successfully cleared recent searches',
      );
      return result;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherLocalDataSource: Error clearing recent searches',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> hasCachedWeatherData() async {
    try {
      return !_cacheService.isExpired(CacheConstants.cachedCurrentWeather);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasCachedWeeklyForecastData() async {
    try {
      return !_cacheService.isExpired(CacheConstants.cachedWeeklyForecast);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasCachedWeatherDataForCity(String cityName) async {
    try {
      // First check if we have any weather data
      if (!await hasCachedWeatherData()) {
        // Before giving up on the default cache, check for a city-specific cache
        final cityKey = CacheConstants.cityWeatherCacheKey(cityName);
        final hasCityCache =
            _cacheService.hasKey(cityKey) && !_cacheService.isExpired(cityKey);

        if (!hasCityCache) {
          return false;
        }

        // We found city-specific cache
        return true;
      }

      // Then check if it's for the specific city in the default cache
      try {
        final cachedWeather = await getCachedCurrentWeather();
        if (cachedWeather.cityName.toLowerCase() == cityName.toLowerCase()) {
          return true;
        }

        // If the default cache isn't for this city, check for a city-specific cache
        final cityKey = CacheConstants.cityWeatherCacheKey(cityName);
        return _cacheService.hasKey(cityKey) &&
            !_cacheService.isExpired(cityKey);
      } catch (e) {
        appLogger.w(
          'WeatherLocalDataSource: Error checking cached weather for city: $cityName',
          e,
        );

        // Check for a city-specific cache
        final cityKey = CacheConstants.cityWeatherCacheKey(cityName);
        return _cacheService.hasKey(cityKey) &&
            !_cacheService.isExpired(cityKey);
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasCachedForecastDataForCity(String cityName) async {
    try {
      // First check if we have any forecast data
      if (!await hasCachedWeeklyForecastData()) {
        // Before giving up on the default cache, check for a city-specific cache
        final cityKey = CacheConstants.cityForecastCacheKey(cityName);
        final hasCityCache =
            _cacheService.hasKey(cityKey) && !_cacheService.isExpired(cityKey);

        if (!hasCityCache) {
          return false;
        }

        // We found city-specific cache
        return true;
      }

      // Then check if it's for the specific city
      try {
        final cachedForecast = await getCachedForecast();
        if (cachedForecast.cityName.toLowerCase() == cityName.toLowerCase()) {
          return true;
        }

        // If the default cache isn't for this city, check for a city-specific cache
        final cityKey = CacheConstants.cityForecastCacheKey(cityName);
        return _cacheService.hasKey(cityKey) &&
            !_cacheService.isExpired(cityKey);
      } catch (e) {
        appLogger.w(
          'WeatherLocalDataSource: Error checking cached forecast for city: $cityName',
          e,
        );

        // Check for a city-specific cache
        final cityKey = CacheConstants.cityForecastCacheKey(cityName);
        return _cacheService.hasKey(cityKey) &&
            !_cacheService.isExpired(cityKey);
      }
    } catch (e) {
      return false;
    }
  }
}
