import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching current weather data
class GetCurrentWeather extends UseCase<Weather, String> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetCurrentWeather(this.repository);

  @override
  Future<Either<AppError, Weather>> call(String cityName) async {
    appLogger.i('GetCurrentWeather: Fetching current weather for $cityName');

    try {
      final result = await repository.getCurrentWeather(cityName);

      result.fold(
        (error) => appLogger.e(
          'GetCurrentWeather: Error fetching weather - ${error.message}',
          null,
          error.stackTrace,
        ),
        (weather) => appLogger.i(
          'GetCurrentWeather: Successfully fetched weather for ${weather.cityName}',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetCurrentWeather: Unexpected error', e, stackTrace);
      return Left(
        ServerError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
