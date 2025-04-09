import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/network_info.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_local_data_source.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/features/weather_dashboard/data/models/daily_forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/weather_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/air_quality_model.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';

/// Implementation of WeatherRepository
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  /// Constructor that accepts data sources and network info
  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<AppError, Weather>> getCurrentWeather(String cityName) async {
    appLogger.i('WeatherRepository: Getting current weather for $cityName');

    try {
      if (!await networkInfo.isConnected) {
        appLogger.w(
          'WeatherRepository: Offline, checking for cached data for this city',
        );

        // Check if we have cached data for this specific city
        if (await hasCachedWeatherDataForCity(cityName)) {
          appLogger.i('WeatherRepository: Found cached data for $cityName');
          try {
            // Get the city-specific cached data
            final cachedWeather = await localDataSource.getCachedWeatherForCity(
              cityName,
            );
            return Right(cachedWeather);
          } catch (e) {
            // Fallback to general cache if city-specific retrieval fails
            final cachedResult = await getCachedCurrentWeather();
            return cachedResult.fold(
              (error) => Left(error),
              (weather) =>
                  weather.cityName.toLowerCase() == cityName.toLowerCase()
                      ? Right(weather)
                      : Left(
                        const NetworkError(
                          message:
                              'No internet connection and no cached data for this city',
                        ),
                      ),
            );
          }
        }

        return Left(
          const NetworkError(
            message: 'No internet connection and no cached data for this city',
          ),
        );
      }

      final remoteWeather = await remoteDataSource.getCurrentWeather(cityName);
      appLogger.i(
        'WeatherRepository: Successfully fetched remote weather data',
      );

      // Save to cache first
      final cachingSuccess = await localDataSource.cacheCurrentWeather(
        remoteWeather,
      );

      if (!cachingSuccess) {
        appLogger.w(
          'WeatherRepository: Failed to cache weather data for $cityName',
        );
      } else {
        appLogger.i(
          'WeatherRepository: Successfully cached weather data for $cityName',
        );

        // Also save to recent searches since we have the data
        await saveToRecentSearches(cityName);
      }

      return Right(remoteWeather);
    } on ServerError catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Server exception getting current weather',
        e,
        stackTrace,
      );

      // Try to get cached data for this city as fallback
      if (await hasCachedWeatherDataForCity(cityName)) {
        appLogger.i(
          'WeatherRepository: Falling back to cached data for $cityName',
        );
        try {
          final cachedWeather = await localDataSource.getCachedWeatherForCity(
            cityName,
          );
          return Right(cachedWeather);
        } catch (cacheError) {
          return getCachedCurrentWeather();
        }
      }

      return Left(e);
    } on NetworkError catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Network exception getting current weather',
        e,
        stackTrace,
      );

      // Try to get cached data for this city as fallback
      if (await hasCachedWeatherDataForCity(cityName)) {
        appLogger.i(
          'WeatherRepository: Falling back to cached data for $cityName',
        );
        try {
          final cachedWeather = await localDataSource.getCachedWeatherForCity(
            cityName,
          );
          return Right(cachedWeather);
        } catch (cacheError) {
          return getCachedCurrentWeather();
        }
      }

      return Left(e);
    } on CityNotFoundError catch (e, stackTrace) {
      appLogger.e('WeatherRepository: City not found exception', e, stackTrace);
      return Left(e);
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Unexpected error getting current weather',
        e,
        stackTrace,
      );
      return Left(ServerError(message: e.toString()));
    }
  }

  @override
  Future<Either<AppError, Forecast>> getForecast(String cityName) async {
    appLogger.i('WeatherRepository: Getting forecast for $cityName');

    try {
      // Check for internet connection
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Fetch from API
          final remoteForecast = await remoteDataSource.getForecast(cityName);

          // Cache the forecast
          final cacheForecastSuccess = await localDataSource.cacheForecast(
            remoteForecast,
          );

          // Also cache the weekly forecast
          final weeklyForecast = WeeklyForecastModel.fromForecast(
            remoteForecast,
          );
          final cacheWeeklySuccess = await localDataSource.cacheWeeklyForecast(
            weeklyForecast,
          );

          if (!cacheForecastSuccess || !cacheWeeklySuccess) {
            appLogger.w(
              'WeatherRepository: Failed to cache forecast data for $cityName',
            );
          } else {
            appLogger.i(
              'WeatherRepository: Successfully cached forecast data for $cityName',
            );

            // Also save to recent searches since we have the data
            await saveToRecentSearches(cityName);
          }

          return Right(remoteForecast);
        } on CityNotFoundError catch (e) {
          appLogger.w('WeatherRepository: City not found: $cityName');
          return Left(e);
        } on ServerError catch (e) {
          appLogger.e('WeatherRepository: Server error', e, e.stackTrace);

          // Try to get cached data for this city as fallback
          if (await hasCachedForecastDataForCity(cityName)) {
            appLogger.i(
              'WeatherRepository: Falling back to cached data for $cityName',
            );
            try {
              // Get city-specific forecast
              final cachedForecast = await localDataSource
                  .getCachedForecastForCity(cityName);
              return Right(cachedForecast);
            } catch (cacheError) {
              // Fallback to general cache
              final cachedForecast = await localDataSource.getCachedForecast();
              return Right(cachedForecast);
            }
          }

          return Left(e);
        } on NetworkError catch (e) {
          appLogger.e('WeatherRepository: Network error', e, e.stackTrace);

          // Try to get cached data for this city as fallback
          if (await hasCachedForecastDataForCity(cityName)) {
            appLogger.i(
              'WeatherRepository: Falling back to cached data for $cityName',
            );
            try {
              // Get city-specific forecast
              final cachedForecast = await localDataSource
                  .getCachedForecastForCity(cityName);
              return Right(cachedForecast);
            } catch (cacheError) {
              // Fallback to general cache
              final cachedForecast = await localDataSource.getCachedForecast();
              return Right(cachedForecast);
            }
          }

          return Left(e);
        }
      } else {
        appLogger.w(
          'WeatherRepository: No internet connection, checking for cached data for this city',
        );

        // Try to get cached data for this specific city
        if (await hasCachedForecastDataForCity(cityName)) {
          appLogger.i(
            'WeatherRepository: Found cached forecast data for $cityName',
          );
          try {
            // Get city-specific forecast
            final cachedForecast = await localDataSource
                .getCachedForecastForCity(cityName);
            return Right(cachedForecast);
          } catch (cacheError) {
            // Fallback to general cache
            final cachedForecast = await localDataSource.getCachedForecast();
            if (cachedForecast.cityName.toLowerCase() ==
                cityName.toLowerCase()) {
              return Right(cachedForecast);
            }
          }
        }

        return Left(
          const NetworkError(
            message:
                'No internet connection and no cached data available for this city',
          ),
        );
      }
    } catch (e, stackTrace) {
      appLogger.e('WeatherRepository: Unexpected error', e, stackTrace);
      return Left(
        ServerError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<String>>> getRecentSearches() async {
    appLogger.i('WeatherRepository: Getting recent searches');

    try {
      final searches = await localDataSource.getRecentSearches();
      return Right(searches);
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error retrieving recent searches',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message: 'Failed to retrieve recent searches: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<bool> saveToRecentSearches(String cityName) async {
    appLogger.i('WeatherRepository: Saving $cityName to recent searches');

    try {
      return await localDataSource.saveToRecentSearches(cityName);
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error saving to recent searches',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> clearRecentSearches() async {
    appLogger.i('WeatherRepository: Clearing recent searches');

    try {
      return await localDataSource.clearRecentSearches();
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error clearing recent searches',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> hasCachedWeatherData() async {
    appLogger.i('WeatherRepository: Checking for cached weather data');

    try {
      return await localDataSource.hasCachedWeatherData();
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error checking for cached data',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> hasCachedWeatherDataForCity(String cityName) async {
    appLogger.i(
      'WeatherRepository: Checking for cached weather data for $cityName',
    );

    try {
      return await localDataSource.hasCachedWeatherDataForCity(cityName);
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error checking for cached data for city',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> hasCachedForecastDataForCity(String cityName) async {
    appLogger.i(
      'WeatherRepository: Checking for cached forecast data for $cityName',
    );

    try {
      return await localDataSource.hasCachedForecastDataForCity(cityName);
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error checking for cached forecast data for city',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<Either<AppError, Weather>> getCachedCurrentWeather() async {
    appLogger.i('WeatherRepository: Getting cached current weather');

    try {
      if (await localDataSource.hasCachedWeatherData()) {
        final cachedWeather = await localDataSource.getCachedCurrentWeather();
        return Right(cachedWeather);
      } else {
        return Left(
          const CacheError(message: 'No valid cached weather data available'),
        );
      }
    } catch (e, stackTrace) {
      if (e is CacheError) {
        return Left(e);
      }

      appLogger.e(
        'WeatherRepository: Error retrieving cached weather',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message: 'Failed to retrieve cached weather: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppError, Forecast>> getCachedForecast() async {
    appLogger.i('WeatherRepository: Getting cached forecast');

    try {
      if (await localDataSource.hasCachedWeatherData()) {
        final cachedForecast = await localDataSource.getCachedForecast();
        return Right(cachedForecast);
      } else {
        return Left(
          const CacheError(message: 'No valid cached forecast data available'),
        );
      }
    } catch (e, stackTrace) {
      if (e is CacheError) {
        return Left(e);
      }

      appLogger.e(
        'WeatherRepository: Error retrieving cached forecast',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message: 'Failed to retrieve cached forecast: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<bool> isConnected() async {
    appLogger.i('WeatherRepository: Checking internet connection');
    return await networkInfo.isConnected;
  }

  @override
  Future<bool> hasCachedWeeklyForecastData() async {
    appLogger.i('WeatherRepository: Checking for cached weekly forecast data');

    try {
      return await localDataSource.hasCachedWeeklyForecastData();
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Error checking for cached weekly forecast data',
        e,
        stackTrace,
      );
      return false;
    }
  }

  @override
  Future<Either<AppError, WeeklyForecastModel>>
  getCachedWeeklyForecast() async {
    appLogger.i('WeatherRepository: Getting cached weekly forecast');

    try {
      if (await localDataSource.hasCachedWeeklyForecastData()) {
        final cachedWeeklyForecast =
            await localDataSource.getCachedWeeklyForecast();
        return Right(cachedWeeklyForecast);
      } else {
        // If we have a regular forecast cached, we can generate the weekly forecast from it
        if (await localDataSource.hasCachedWeatherData()) {
          try {
            final cachedForecastResult = await getCachedForecast();

            return cachedForecastResult.fold(
              (error) => Left(
                const CacheError(
                  message: 'No valid cached weekly forecast data available',
                ),
              ),
              (forecast) {
                // Create a weekly forecast from the regular forecast
                final weeklyForecast = WeeklyForecastModel.fromForecast(
                  forecast,
                );

                // Cache it for future use
                localDataSource.cacheWeeklyForecast(weeklyForecast);

                return Right(weeklyForecast);
              },
            );
          } catch (e) {
            return Left(
              const CacheError(
                message: 'Failed to generate weekly forecast from cached data',
              ),
            );
          }
        }

        return Left(
          const CacheError(
            message: 'No valid cached weekly forecast data available',
          ),
        );
      }
    } catch (e, stackTrace) {
      if (e is CacheError) {
        return Left(e);
      }

      appLogger.e(
        'WeatherRepository: Error retrieving cached weekly forecast',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message: 'Failed to retrieve cached weekly forecast: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppError, Weather>> getCachedWeatherForCity(
    String cityName,
  ) async {
    appLogger.i('WeatherRepository: Getting cached weather for $cityName');

    try {
      if (await localDataSource.hasCachedWeatherDataForCity(cityName)) {
        try {
          // Try the city-specific cache first
          final cachedWeather = await localDataSource.getCachedWeatherForCity(
            cityName,
          );
          return Right(cachedWeather);
        } catch (e) {
          // If city-specific cache access fails, try the general cache
          final cachedWeatherResult = await getCachedCurrentWeather();

          return cachedWeatherResult.fold(
            (error) => Left(error),
            (weather) =>
                weather.cityName.toLowerCase() == cityName.toLowerCase()
                    ? Right(weather)
                    : Left(
                      const CacheError(
                        message: 'No cached weather data found for this city',
                      ),
                    ),
          );
        }
      } else {
        return Left(
          CacheError(message: 'No valid cached weather data for $cityName'),
        );
      }
    } catch (e, stackTrace) {
      if (e is CacheError) {
        return Left(e);
      }

      appLogger.e(
        'WeatherRepository: Error retrieving cached weather for $cityName',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message:
              'Failed to retrieve cached weather for $cityName: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AppError, Forecast>> getCachedForecastForCity(
    String cityName,
  ) async {
    appLogger.i('WeatherRepository: Getting cached forecast for $cityName');

    try {
      if (await localDataSource.hasCachedForecastDataForCity(cityName)) {
        try {
          // Try the city-specific cache first
          final cachedForecast = await localDataSource.getCachedForecastForCity(
            cityName,
          );
          return Right(cachedForecast);
        } catch (e) {
          // If city-specific cache access fails, try the general cache
          final cachedForecastResult = await getCachedForecast();

          return cachedForecastResult.fold(
            (error) => Left(error),
            (forecast) =>
                forecast.cityName.toLowerCase() == cityName.toLowerCase()
                    ? Right(forecast)
                    : Left(
                      const CacheError(
                        message: 'No cached forecast data found for this city',
                      ),
                    ),
          );
        }
      } else {
        return Left(
          CacheError(message: 'No valid cached forecast data for $cityName'),
        );
      }
    } catch (e, stackTrace) {
      if (e is CacheError) {
        return Left(e);
      }

      appLogger.e(
        'WeatherRepository: Error retrieving cached forecast for $cityName',
        e,
        stackTrace,
      );
      return Left(
        CacheError(
          message:
              'Failed to retrieve cached forecast for $cityName: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Error, AirQualityModel>> getAirQuality(
    double lat,
    double lon,
  ) async {
    appLogger.i(
      'WeatherRepository: Getting air quality for lat:$lat, lon:$lon',
    );

    try {
      if (!await networkInfo.isConnected) {
        return Left(Error());
      }

      final airQuality = await remoteDataSource.getAirQuality(lat, lon);
      appLogger.i('WeatherRepository: Successfully fetched air quality data');

      return Right(airQuality);
    } on ServerError catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Server error getting air quality',
        e,
        stackTrace,
      );
      return Left(Error());
    } on NetworkError catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Network error getting air quality',
        e,
        stackTrace,
      );
      return Left(Error());
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRepository: Unexpected error getting air quality',
        e,
        stackTrace,
      );
      return Left(Error());
    }
  }
}
