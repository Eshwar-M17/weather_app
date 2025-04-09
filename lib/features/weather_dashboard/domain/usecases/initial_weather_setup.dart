import 'package:dartz/dartz.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/get_cached_forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/get_cached_weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/get_current_weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/get_forecast.dart';

/// Use case for initial weather setup when app launches
class InitialWeatherSetup extends UseCase<Tuple2<Weather, Forecast>, NoParams> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Use case for getting current weather
  final GetCurrentWeather getCurrentWeather;

  /// Use case for getting forecast
  final GetForecast getForecast;

  /// Use case for getting cached weather
  final GetCachedWeather getCachedWeather;

  /// Use case for getting cached forecast
  final GetCachedForecast getCachedForecast;

  /// Constructor that accepts repository and other use cases
  InitialWeatherSetup({
    required this.repository,
    required this.getCurrentWeather,
    required this.getForecast,
    required this.getCachedWeather,
    required this.getCachedForecast,
  });

  @override
  Future<Either<AppError, Tuple2<Weather, Forecast>>> call(
    NoParams params,
  ) async {
    appLogger.i('InitialWeatherSetup: Setting up initial weather data');

    try {
      // First, check if we have valid cached data
      final hasCachedData = await repository.hasCachedWeatherData();

      if (hasCachedData) {
        appLogger.i('InitialWeatherSetup: Using cached weather data');

        // Get cached weather
        final weatherResult = await getCachedWeather.execute();
        final forecastResult = await getCachedForecast.execute();

        // Check if both cached data are valid
        final bool isWeatherValid = weatherResult.isRight();
        final bool isForecastValid = forecastResult.isRight();

        if (isWeatherValid && isForecastValid) {
          // Extract data from Either
          final weather = (weatherResult as Right<AppError, Weather>).value;
          final forecast = (forecastResult as Right<AppError, Forecast>).value;

          appLogger.i(
            'InitialWeatherSetup: Successfully loaded cached data for ${weather.cityName}',
          );
          return Right(Tuple2(weather, forecast));
        }
      }

      // No valid cached data, load default city's weather
      appLogger.i(
        'InitialWeatherSetup: No valid cached data, loading default city (${AppConstants.defaultCity})',
      );

      final weatherResult = await getCurrentWeather(AppConstants.defaultCity);
      final forecastResult = await getForecast(AppConstants.defaultCity);

      // Check if both API calls were successful
      final bool isWeatherValid = weatherResult.isRight();
      final bool isForecastValid = forecastResult.isRight();

      if (isWeatherValid && isForecastValid) {
        // Extract data from Either
        final weather = (weatherResult as Right<AppError, Weather>).value;
        final forecast = (forecastResult as Right<AppError, Forecast>).value;

        appLogger.i(
          'InitialWeatherSetup: Successfully loaded weather data for ${AppConstants.defaultCity}',
        );
        return Right(Tuple2(weather, forecast));
      } else {
        // Determine which error to return
        final error =
            isWeatherValid
                ? (forecastResult as Left<AppError, Forecast>).value
                : (weatherResult as Left<AppError, Weather>).value;

        appLogger.e(
          'InitialWeatherSetup: Failed to load default weather - ${error.message}',
          null,
          error.stackTrace,
        );
        return Left(error);
      }
    } catch (e, stackTrace) {
      appLogger.e('InitialWeatherSetup: Unexpected error', e, stackTrace);
      return Left(
        ServerError(
          message: 'Failed to set up initial weather data: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Convenience method to call without parameters
  Future<Either<AppError, Tuple2<Weather, Forecast>>> execute() =>
      call(const NoParams());
}
