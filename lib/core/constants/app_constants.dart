/// Application-wide constants
///
/// This file contains centralized constants used throughout the app,
/// organized by category for easy access and maintenance.

import 'api_keys.dart';

/// General application constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// API related constants
  static String get apiKey =>
      ApiKeys.openWeatherMapKey; // Using the key from api_keys.dart
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  /// API endpoints
  static const String currentWeatherEndpoint = 'weather';
  static const String forecastEndpoint = 'forecast';
  static const String airPollutionEndpoint = 'air_pollution';
  static const String uvIndexEndpoint = 'uvi';

  /// Geocoding endpoints
  static const String directGeocodingEndpoint = 'geo/1.0/direct';
  static const String reverseGeocodingEndpoint = 'geo/1.0/reverse';

  /// Unit systems
  static const String metric = 'metric'; // For Celsius
  static const String imperial = 'imperial'; // For Fahrenheit

  /// Default values
  static const String defaultCity = 'London';
  static const String defaultCountryCode = 'GB';
  static const int defaultForecastDays = 5;

  /// Unit measurements
  static const String tempUnit = '°C';
  static const String speedUnit = 'km/h';
  static const String pressureUnit = 'hPa';
  static const String distanceUnit = 'km';
  static const String percentageUnit = '%';

  /// Cache related
  static const String weatherCacheKey = 'CACHED_WEATHER';
  static const String forecastCacheKey = 'CACHED_FORECAST';
  static const String recentSearchesKey = 'RECENT_SEARCHES';
  static const int maxRecentSearches = 10;
  static const Duration cacheDuration = Duration(hours: 1);
}

/// Route paths throughout the application
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  /// Main routes
  static const String home = '/';
  static const String weatherDetails = '/weather-details';
  static const String recentSearches = '/recent-searches';

  /// Route names for GoRouter named routes
  static const String homeName = 'home';
  static const String weatherDetailsName = 'weatherDetails';
  static const String recentSearchesName = 'recentSearches';
}

/// Standardized error messages for the application
class ErrorMessages {
  // Private constructor to prevent instantiation
  ErrorMessages._();

  /// Network errors
  static const String noInternet =
      'No internet connection. Please check your network settings.';
  static const String noInternetWithCache =
      'No internet connection. Showing cached data.';
  static const String timeoutError = 'Request timed out. Please try again.';

  /// Server errors
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String apiError = 'Weather API error. Please try again.';

  /// Data errors
  static const String cityNotFound =
      'City not found. Please check the spelling and try again.';
  static const String invalidData = 'Invalid data received from server.';

  /// Cache errors
  static const String cacheError = 'Error accessing cached data.';
  static const String noCachedData = 'No cached data available.';

  /// Location errors
  static const String locationError = 'Error getting current location.';
  static const String locationPermission =
      'Location permission denied. Please enable location services.';
}

/// Asset paths for images, icons, etc.
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  /// Weather condition icons
  static const String clearSky = 'assets/images/clear_sky.png';
  static const String fewClouds = 'assets/images/few_clouds.png';
  static const String scatteredClouds = 'assets/images/scattered_clouds.png';
  static const String brokenClouds = 'assets/images/broken_clouds.png';
  static const String showerRain = 'assets/images/shower_rain.png';
  static const String rain = 'assets/images/rain.png';
  static const String thunderstorm = 'assets/images/thunderstorm.png';
  static const String snow = 'assets/images/snow.png';
  static const String mist = 'assets/images/mist.png';
  static const String unknown = 'assets/images/unknown.png';

  /// UI elements
  static const String weatherBackground =
      'assets/images/weather_background.jpg';
  static const String appIcon = 'assets/icons/app_icon.png';
  static const String placeholder = 'assets/images/placeholder.png';
}

/// Duration constants used throughout the app
class AppDurations {
  // Private constructor to prevent instantiation
  AppDurations._();

  /// Animations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration debounceTime = Duration(milliseconds: 500);

  /// Refresh intervals
  static const Duration autoRefreshInterval = Duration(minutes: 30);
  static const Duration locationUpdateInterval = Duration(minutes: 15);
}

/// API endpoint constants
/// @deprecated Use AppConstants for API endpoints instead
/// This class is kept for backward compatibility
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Weather endpoints
  // Note: These first two endpoints are duplicated in AppConstants
  // Consider using AppConstants.currentWeatherEndpoint instead
  static const String currentWeather = 'weather';
  // Consider using AppConstants.forecastEndpoint instead
  static const String forecast = 'forecast';
  static const String airPollution = 'air_pollution';
  static const String uvIndex = 'uvi';

  /// Geocoding endpoints
  static const String directGeocoding = 'geo/1.0/direct';
  static const String reverseGeocoding = 'geo/1.0/reverse';
}

/// Sizes for consistent UI elements
class AppSizes {
  // Private constructor to prevent instantiation
  AppSizes._();

  /// Padding/Margin
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  /// Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;

  /// Icon sizes
  static const double smallIcon = 18.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  /// Text sizes
  static const double smallText = 12.0;
  static const double mediumText = 16.0;
  static const double largeText = 20.0;
  static const double extraLargeText = 28.0;
  static const double temperatureText = 64.0;
}

/// Cache constants for local storage
class CacheConstants {
  // Private constructor to prevent instantiation
  CacheConstants._();

  /// Key for storing cached current weather
  static const String cachedCurrentWeather = 'CACHED_CURRENT_WEATHER';

  /// Format string for city-specific current weather cache
  static String cityWeatherCacheKey(String cityName) =>
      'WEATHER_${cityName.toLowerCase().trim()}';

  /// Key for storing cached forecast
  static const String cachedForecast = 'CACHED_FORECAST';

  /// Format string for city-specific forecast cache
  static String cityForecastCacheKey(String cityName) =>
      'FORECAST_${cityName.toLowerCase().trim()}';

  /// Key for storing cached weekly forecast
  static const String cachedWeeklyForecast = 'CACHED_WEEKLY_FORECAST';

  /// Format string for city-specific weekly forecast cache
  static String cityWeeklyForecastCacheKey(String cityName) =>
      'WEEKLY_FORECAST_${cityName.toLowerCase().trim()}';

  /// Key for storing recent searches
  static const String cachedSearchHistory = 'CACHED_SEARCH_HISTORY';

  /// Key for storing last updated time
  static const String lastUpdatedTime = 'LAST_UPDATED_TIME';

  /// Cache validity duration in hours
  static const int cacheValidityDuration = 24;
}

/// Weather icon URL helper
class WeatherIconsConstants {
  // Private constructor to prevent instantiation
  WeatherIconsConstants._();

  /// Base URL for weather icons
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn/';

  /// Suffix for high-quality icons
  static const String iconSuffix = '@2x.png';

  /// Get full URL for a specific icon code
  static String getIconUrl(String iconCode) {
    return '$iconBaseUrl$iconCode$iconSuffix';
  }
}
