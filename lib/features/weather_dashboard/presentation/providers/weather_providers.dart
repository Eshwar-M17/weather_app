import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/cache/cache_service.dart';
import 'package:weather_app/core/network/api_client.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/data/models/daily_forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_local_data_source.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/core/utils/network_info.dart';
import 'package:http/http.dart' as http;
import '../../data/models/air_quality_model.dart';
import 'dart:core';

/// Custom error class for loading states
class LoadingError extends AppError {
  const LoadingError({required String message}) : super(message: message);
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});

/// Provider for cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacheService(prefs: prefs);
});

/// Provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(client: http.Client());
});

/// Provider for connectivity
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for network info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});

/// Provider for local data source
final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return WeatherLocalDataSourceImpl(cacheService: cacheService);
});

/// Provider for remote data source
final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return WeatherRemoteDataSourceImpl(apiClient: apiClient);
});

/// Weather repository provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final remoteDataSource = ref.watch(weatherRemoteDataSourceProvider);
  final localDataSource = ref.watch(weatherLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return WeatherRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

/// Provider for getting current weather
final getCurrentWeatherProvider =
    FutureProvider.family<Either<AppError, Weather>, String>((
      ref,
      cityName,
    ) async {
      final repository = ref.watch(weatherRepositoryProvider);
      return await repository.getCurrentWeather(cityName);
    });

/// States for UI with data, loading, and error states
enum StateStatus { initial, loading, data, error }

/// Base class for UI states
class UIState<T> {
  final StateStatus status;
  final T? data;
  final String? errorMessage;

  const UIState._({required this.status, this.data, this.errorMessage});

  /// Initial state
  const UIState.initial()
    : this._(status: StateStatus.initial, data: null, errorMessage: null);

  /// Loading state
  const UIState.loading()
    : this._(status: StateStatus.loading, data: null, errorMessage: null);

  /// Data state
  const UIState.data(T data)
    : this._(status: StateStatus.data, data: data, errorMessage: null);

  /// Error state
  const UIState.error(String message)
    : this._(status: StateStatus.error, data: null, errorMessage: message);

  /// Helper methods to work with state
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(String message) error,
  }) {
    switch (status) {
      case StateStatus.initial:
        return initial();
      case StateStatus.loading:
        return loading();
      case StateStatus.data:
        return data(this.data as T);
      case StateStatus.error:
        return error(errorMessage!);
    }
  }

  /// Helper method for conditional state handling
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    switch (status) {
      case StateStatus.initial:
        return initial != null ? initial() : orElse();
      case StateStatus.loading:
        return loading != null ? loading() : orElse();
      case StateStatus.data:
        return data != null ? data(this.data as T) : orElse();
      case StateStatus.error:
        return error != null ? error(errorMessage!) : orElse();
    }
  }
}

/// Weather state for UI
typedef WeatherState = UIState<Weather>;

/// Controller for current weather data
class CurrentWeatherController extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  /// Creates a CurrentWeatherController with a repository
  CurrentWeatherController(this._repository)
    : super(const WeatherState.initial()) {
    // Try to load cached data on initialization
    loadCachedWeather();
  }

  /// Load cached weather data
  Future<void> loadCachedWeather() async {
    appLogger.i(
      'CurrentWeatherController: Attempting to load cached weather data',
    );

    // Only load from cache if we're in initial state (to avoid overriding newer data)
    if (state.status != StateStatus.initial) {
      appLogger.i(
        'CurrentWeatherController: Not in initial state, skipping cache load',
      );
      return;
    }

    // Check if we have valid cached data
    final hasCachedData = await _repository.hasCachedWeatherData();
    if (!hasCachedData) {
      appLogger.i(
        'CurrentWeatherController: No valid cached weather data available',
      );
      return;
    }

    // Get the cached data
    final result = await _repository.getCachedCurrentWeather();
    result.fold(
      (error) {
        appLogger.w(
          'CurrentWeatherController: Could not load cached weather: ${error.message}',
        );
        // Don't update state on cache error - will fall back to default city fetch
      },
      (weather) {
        appLogger.i(
          'CurrentWeatherController: Successfully loaded cached weather for ${weather.cityName}',
        );
        state = WeatherState.data(weather);
      },
    );
  }

  /// Get current weather for a city
  Future<void> getCurrentWeather(String cityName) async {
    appLogger.i('CurrentWeatherController: Fetching weather for $cityName');

    // Set to loading state
    state = const WeatherState.loading();

    try {
      // Check for internet connection first
      final isConnected = await _repository.isConnected();

      // First check if this city exists in cache and cache is valid
      final hasCachedData = await _repository.hasCachedWeatherData();
      if (hasCachedData) {
        final cachedResult = await _repository.getCachedCurrentWeather();
        final cachedCity = cachedResult.fold(
          (error) => null,
          (weather) =>
              weather.cityName.toLowerCase() == cityName.toLowerCase()
                  ? weather
                  : null,
        );

        // If we have valid cached data for this city, use it immediately
        if (cachedCity != null) {
          appLogger.i(
            'CurrentWeatherController: Using cached data for $cityName',
          );
          state = WeatherState.data(cachedCity);

          // Only fetch fresh data in the background if we have internet
          if (isConnected) {
            _fetchFreshDataInBackground(cityName);
          }
          return;
        }
        // If we're offline and the requested city isn't in cache
        else if (!isConnected) {
          appLogger.w(
            'CurrentWeatherController: No cached data for $cityName and offline',
          );
          state = WeatherState.error(
            'No data available for "$cityName" while offline. Please connect to the internet and try again.',
          );
          return;
        }
      } else if (!isConnected) {
        // No cached data and offline
        appLogger.w(
          'CurrentWeatherController: No cached data available and offline',
        );
        state = WeatherState.error(
          'You are currently offline. Please connect to the internet to search for new cities.',
        );
        return;
      }

      // No cached data available or we're online, proceed with API request
      final result = await _repository.getCurrentWeather(cityName);

      state = result.fold(
        (error) {
          String errorMsg = error.message;

          // Enhanced error reporting for better debugging
          if (error is NetworkError) {
            errorMsg =
                'Network Error: ${error.message}. Check your internet connection.';
          } else if (error is ServerError) {
            errorMsg =
                'Server Error: ${error.message}. Please try again later.';
          } else if (error is CityNotFoundError) {
            errorMsg = 'City not found: $cityName. Please check the spelling.';
          } else if (error is CacheError) {
            errorMsg = 'Cache Error: ${error.message}. Try clearing app data.';
          }

          appLogger.e('CurrentWeatherController: Error: $errorMsg', error);
          return WeatherState.error(errorMsg);
        },
        (weather) {
          appLogger.i(
            'CurrentWeatherController: Successfully fetched weather for $cityName',
          );
          appLogger.d('Weather data: ${weather.toString()}');
          return WeatherState.data(weather);
        },
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'CurrentWeatherController: Unexpected error during weather fetch',
        e,
        stackTrace,
      );
      state = WeatherState.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetch fresh data in the background without affecting state immediately
  Future<void> _fetchFreshDataInBackground(String cityName) async {
    try {
      appLogger.i(
        'CurrentWeatherController: Fetching fresh data for $cityName in background',
      );

      final result = await _repository.getCurrentWeather(cityName);

      result.fold(
        (error) {
          // Log error but don't update state since we're already showing cached data
          appLogger.w(
            'CurrentWeatherController: Background fetch error: ${error.message}',
          );
        },
        (weather) {
          appLogger.i(
            'CurrentWeatherController: Background fetch complete, updating with fresh data',
          );
          // Only update state if we're still looking at the same city
          if (state.status == StateStatus.data &&
              state.data != null &&
              state.data!.cityName.toLowerCase() == cityName.toLowerCase()) {
            state = WeatherState.data(weather);
          }
        },
      );
    } catch (e) {
      appLogger.e('CurrentWeatherController: Error in background fetch', e);
      // Don't update state on background error
    }
  }
}

/// Forecast state for UI
typedef ForecastState = UIState<Forecast>;

/// Controller for forecast data
class ForecastController extends StateNotifier<ForecastState> {
  final WeatherRepository _repository;

  /// Creates a ForecastController with a repository
  ForecastController(this._repository) : super(const ForecastState.initial()) {
    // Try to load cached forecast on initialization
    loadCachedForecast();
  }

  /// Load cached forecast data
  Future<void> loadCachedForecast() async {
    appLogger.i('ForecastController: Attempting to load cached forecast data');

    // Only load from cache if we're in initial state (to avoid overriding newer data)
    if (state.status != StateStatus.initial) {
      appLogger.i(
        'ForecastController: Not in initial state, skipping cache load',
      );
      return;
    }

    // First try to get weekly forecast from cache
    final hasWeeklyForecast = await _repository.hasCachedWeeklyForecastData();
    if (hasWeeklyForecast) {
      appLogger.i('ForecastController: Found cached weekly forecast data');
      final weeklyResult = await _repository.getCachedWeeklyForecast();

      await weeklyResult.fold(
        (error) async {
          appLogger.w(
            'ForecastController: Error loading weekly forecast, falling back to hourly: ${error.message}',
          );
          // Fall back to hourly forecast
          await _loadCachedHourlyForecast();
        },
        (weeklyForecast) {
          appLogger.i(
            'ForecastController: Successfully loaded cached weekly forecast for ${weeklyForecast.cityName}',
          );

          // Get regular hourly forecast if weekly forecast was successful
          // This is done to keep the app working with existing code
          _loadCachedHourlyForecast();
        },
      );
    } else {
      // Fall back to hourly forecast
      await _loadCachedHourlyForecast();
    }
  }

  /// Helper to load hourly forecast from cache
  Future<void> _loadCachedHourlyForecast() async {
    // Check if we have valid cached data
    final hasCachedData = await _repository.hasCachedWeatherData();
    if (!hasCachedData) {
      appLogger.i(
        'ForecastController: No valid cached forecast data available',
      );
      return;
    }

    // Get the cached data
    final result = await _repository.getCachedForecast();
    result.fold(
      (error) {
        appLogger.w(
          'ForecastController: Could not load cached forecast: ${error.message}',
        );
        // Don't update state on cache error - will fall back to default city fetch
      },
      (forecast) {
        appLogger.i(
          'ForecastController: Successfully loaded cached forecast for ${forecast.cityName}',
        );
        state = ForecastState.data(forecast);
      },
    );
  }

  /// Get forecast for a city
  Future<void> getForecast(String cityName) async {
    appLogger.i('ForecastController: Fetching forecast for $cityName');

    state = const ForecastState.loading();

    try {
      // Check for internet connection first
      final isConnected = await _repository.isConnected();

      // First check if this city exists in cache and cache is valid
      final hasCachedData = await _repository.hasCachedWeatherData();
      if (hasCachedData) {
        final cachedResult = await _repository.getCachedForecast();
        final cachedForecast = cachedResult.fold(
          (error) => null,
          (forecast) =>
              forecast.cityName.toLowerCase() == cityName.toLowerCase()
                  ? forecast
                  : null,
        );

        // If we have valid cached data for this city, use it immediately
        if (cachedForecast != null) {
          appLogger.i('ForecastController: Using cached data for $cityName');
          state = ForecastState.data(cachedForecast);

          // Only fetch fresh data in the background if we have internet
          if (isConnected) {
            _fetchFreshForecastInBackground(cityName);
          }
          return;
        }
        // If we're offline and the requested city isn't in cache
        else if (!isConnected) {
          appLogger.w(
            'ForecastController: No cached data for $cityName and offline',
          );
          state = ForecastState.error(
            'No forecast data available for "$cityName" while offline.',
          );
          return;
        }
      } else if (!isConnected) {
        // No cached data and offline
        appLogger.w('ForecastController: No cached data available and offline');
        state = ForecastState.error(
          'Cannot fetch forecast while offline. Please connect to the internet.',
        );
        return;
      }

      // No cached data available or we're online, proceed with API request
      final result = await _repository.getForecast(cityName);

      state = result.fold(
        (error) {
          appLogger.e('ForecastController: Error: ${error.message}');
          return ForecastState.error(error.message);
        },
        (forecast) {
          appLogger.i(
            'ForecastController: Successfully fetched forecast for $cityName',
          );
          return ForecastState.data(forecast);
        },
      );
    } catch (e, stackTrace) {
      appLogger.e('ForecastController: Unexpected error', e, stackTrace);
      state = ForecastState.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetch fresh forecast data in the background without affecting state immediately
  Future<void> _fetchFreshForecastInBackground(String cityName) async {
    try {
      appLogger.i(
        'ForecastController: Fetching fresh forecast for $cityName in background',
      );

      final result = await _repository.getForecast(cityName);

      result.fold(
        (error) {
          // Log error but don't update state since we're already showing cached data
          appLogger.w(
            'ForecastController: Background fetch error: ${error.message}',
          );
        },
        (forecast) {
          appLogger.i(
            'ForecastController: Background fetch complete, updating with fresh data',
          );
          // Only update state if we're still looking at the same city
          if (state.status == StateStatus.data &&
              state.data != null &&
              state.data!.cityName.toLowerCase() == cityName.toLowerCase()) {
            state = ForecastState.data(forecast);
          }
        },
      );
    } catch (e) {
      appLogger.e('ForecastController: Error in background fetch', e);
      // Don't update state on background error
    }
  }
}

/// Recent searches state for UI
typedef RecentSearchesState = UIState<List<String>>;

/// Controller for recent searches
class RecentSearchesController extends StateNotifier<RecentSearchesState> {
  final WeatherRepository _repository;

  /// Creates a RecentSearchesController with a repository
  RecentSearchesController(this._repository)
    : super(const RecentSearchesState.initial()) {
    loadRecentSearches();
  }

  /// Load recent searches from repository
  Future<void> loadRecentSearches() async {
    appLogger.i('RecentSearchesController: Loading recent searches');

    state = const RecentSearchesState.loading();

    final result = await _repository.getRecentSearches();

    state = result.fold(
      (error) {
        appLogger.e('RecentSearchesController: Error: ${error.message}');
        return RecentSearchesState.error(error.message);
      },
      (searches) {
        appLogger.i(
          'RecentSearchesController: Successfully loaded ${searches.length} recent searches',
        );
        return RecentSearchesState.data(searches);
      },
    );
  }

  /// Save a city to recent searches
  Future<void> saveSearch(String cityName) async {
    appLogger.i('RecentSearchesController: Saving search: $cityName');

    // Only save when a non-empty city name is provided
    if (cityName.trim().isEmpty) {
      appLogger.w(
        'RecentSearchesController: Attempted to save empty city name, ignoring',
      );
      return;
    }

    await _repository.saveToRecentSearches(cityName);

    // Reload searches to get updated list
    loadRecentSearches();
  }

  /// Clear all recent searches
  Future<void> clearSearches() async {
    appLogger.i('RecentSearchesController: Clearing all searches');

    await _repository.clearRecentSearches();

    // Update state with empty list
    state = const RecentSearchesState.data([]);
  }
}

final hasCachedDataForCityProvider = FutureProvider.family<bool, String>((
  ref,
  cityName,
) async {
  final weatherRepository = ref.watch(weatherRepositoryProvider);
  return await weatherRepository.hasCachedWeatherDataForCity(cityName);
});

final hasCachedForecastForCityProvider = FutureProvider.family<bool, String>((
  ref,
  cityName,
) async {
  final weatherRepository = ref.watch(weatherRepositoryProvider);
  return await weatherRepository.hasCachedForecastDataForCity(cityName);
});

/// Provider for the current weather controller
final currentWeatherControllerProvider =
    StateNotifierProvider<CurrentWeatherController, WeatherState>((ref) {
      final repository = ref.watch(weatherRepositoryProvider);
      return CurrentWeatherController(repository);
    });

/// Provider for the forecast controller
final forecastControllerProvider =
    StateNotifierProvider<ForecastController, ForecastState>((ref) {
      final repository = ref.watch(weatherRepositoryProvider);
      return ForecastController(repository);
    });

/// Provider for the recent searches controller
final recentSearchesControllerProvider =
    StateNotifierProvider<RecentSearchesController, RecentSearchesState>((ref) {
      final repository = ref.watch(weatherRepositoryProvider);
      return RecentSearchesController(repository);
    });

final currentWeatherProvider = FutureProvider.family<Weather, String>((
  ref,
  cityName,
) async {
  final asyncCurrentWeather = ref.watch(getCurrentWeatherProvider(cityName));
  return asyncCurrentWeather.when(
    data:
        (weather) => weather.fold((error) {
          appLogger.e(
            'Current Weather Provider: Error fetching weather',
            error,
          );
          throw error;
        }, (weather) => weather),
    error: (error, stackTrace) {
      appLogger.e('Current Weather Provider: Error', error, stackTrace);
      throw error;
    },
    loading: () {
      appLogger.i('Current Weather Provider: Loading...');
      throw const LoadingError(message: 'Loading current weather...');
    },
  );
});

/// Provider to fetch air quality data for a given location
final airQualityProvider = FutureProvider.family<
  AirQualityModel,
  ({double lat, double lon})
>((ref, coordinates) async {
  final repository = ref.watch(weatherRepositoryProvider);
  appLogger.i(
    '★★★ AIR QUALITY API CALL START ★★★ Fetching for coordinates: ${coordinates.lat}, ${coordinates.lon}',
  );

  final result = await repository.getAirQuality(
    coordinates.lat,
    coordinates.lon,
  );

  return result.fold(
    (error) {
      appLogger.e('★★★ AIR QUALITY API ERROR ★★★ Failed to fetch data', error);
      throw Error();
    },
    (airQuality) {
      appLogger.i(
        '★★★ AIR QUALITY API SUCCESS ★★★ Data received: AQI=${airQuality.aqi}',
      );
      return airQuality;
    },
  );
});
