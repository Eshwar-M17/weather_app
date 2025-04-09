import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/network/api_client.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/data/models/air_quality_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/data/models/weather_model.dart';

/// Interface for weather remote data source
abstract class WeatherRemoteDataSource {
  /// Gets current weather for a city
  ///
  /// Throws [ServerError] for server-related issues
  /// Throws [NetworkError] for network-related issues
  /// Throws [CityNotFoundError] if the city is not found
  Future<WeatherModel> getCurrentWeather(String cityName);

  /// Gets 5-day weather forecast for a city
  ///
  /// Throws [ServerError] for server-related issues
  /// Throws [NetworkError] for network-related issues
  /// Throws [CityNotFoundError] if the city is not found
  Future<ForecastModel> getForecast(String cityName);

  /// Gets air quality data for a location
  ///
  /// Throws [ServerError] for server-related issues
  /// Throws [NetworkError] for network-related issues
  Future<AirQualityModel> getAirQuality(double lat, double lon);
}

/// Implementation of WeatherRemoteDataSource using ApiClient
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates a WeatherRemoteDataSourceImpl with an API client
  WeatherRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    appLogger.i('WeatherRemoteDataSource: Getting weather for $cityName');

    try {
      final queryParams = {
        'q': cityName,
        'appid': AppConstants.apiKey,
        'units': AppConstants.metric,
      };

      final data = await _apiClient.request<Map<String, dynamic>>(
        endpoint: AppConstants.currentWeatherEndpoint,
        method: RequestMethod.get,
        queryParams: queryParams,
        responseHandler: (data) => data as Map<String, dynamic>,
        includeApiKey: false, // Already included in queryParams
      );

      if (data == null) {
        throw const ServerError(message: 'Failed to get weather data');
      }

      return WeatherModel.fromJson(data);
    } on CityNotFoundError {
      appLogger.w('WeatherRemoteDataSource: City not found: $cityName');
      rethrow;
    } on NetworkError {
      appLogger.e('WeatherRemoteDataSource: Network error');
      rethrow;
    } on ServerError {
      appLogger.e('WeatherRemoteDataSource: Server error');
      rethrow;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRemoteDataSource: Unexpected error getting current weather',
        e,
        stackTrace,
      );
      throw ServerError(message: e.toString(), stackTrace: stackTrace);
    }
  }

  @override
  Future<ForecastModel> getForecast(String cityName) async {
    appLogger.i('WeatherRemoteDataSource: Getting forecast for $cityName');

    try {
      final queryParams = {
        'q': cityName,
        'appid': AppConstants.apiKey,
        'units': AppConstants.metric,
      };

      final data = await _apiClient.request<Map<String, dynamic>>(
        endpoint: AppConstants.forecastEndpoint,
        method: RequestMethod.get,
        queryParams: queryParams,
        responseHandler: (data) => data as Map<String, dynamic>,
        includeApiKey: false, // Already included in queryParams
      );

      if (data == null) {
        throw const ServerError(message: 'Failed to get forecast data');
      }

      return ForecastModel.fromJson(data);
    } on CityNotFoundError {
      appLogger.w('WeatherRemoteDataSource: City not found: $cityName');
      rethrow;
    } on NetworkError {
      appLogger.e('WeatherRemoteDataSource: Network error');
      rethrow;
    } on ServerError {
      appLogger.e('WeatherRemoteDataSource: Server error');
      rethrow;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRemoteDataSource: Unexpected error getting forecast',
        e,
        stackTrace,
      );
      throw ServerError(message: e.toString(), stackTrace: stackTrace);
    }
  }

  @override
  Future<AirQualityModel> getAirQuality(double lat, double lon) async {
    appLogger.i(
      'WeatherRemoteDataSource: Getting air quality for lat:$lat, lon:$lon',
    );

    try {
      final queryParams = {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': AppConstants.apiKey,
      };

      final data = await _apiClient.request<Map<String, dynamic>>(
        endpoint: AppConstants.airPollutionEndpoint,
        method: RequestMethod.get,
        queryParams: queryParams,
        responseHandler: (data) => data as Map<String, dynamic>,
        includeApiKey: false, // Already included in queryParams
      );

      if (data == null) {
        throw const ServerError(message: 'Failed to get air quality data');
      }

      return AirQualityModel.fromJson(data);
    } on NetworkError {
      appLogger.e('WeatherRemoteDataSource: Network error getting air quality');
      rethrow;
    } on ServerError {
      appLogger.e('WeatherRemoteDataSource: Server error getting air quality');
      rethrow;
    } catch (e, stackTrace) {
      appLogger.e(
        'WeatherRemoteDataSource: Unexpected error getting air quality',
        e,
        stackTrace,
      );
      throw ServerError(message: e.toString(), stackTrace: stackTrace);
    }
  }
}
