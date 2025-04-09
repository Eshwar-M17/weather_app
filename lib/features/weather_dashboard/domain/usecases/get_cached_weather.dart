import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching cached weather data
class GetCachedWeather extends UseCase<Weather, NoParams> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetCachedWeather(this.repository);

  @override
  Future<Either<AppError, Weather>> call(NoParams params) async {
    appLogger.i('GetCachedWeather: Fetching cached weather');

    try {
      final result = await repository.getCachedCurrentWeather();

      result.fold(
        (error) => appLogger.e(
          'GetCachedWeather: Error fetching cached weather - ${error.message}',
          null,
          error.stackTrace,
        ),
        (weather) => appLogger.i(
          'GetCachedWeather: Successfully fetched cached weather for ${weather.cityName}',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetCachedWeather: Unexpected error', e, stackTrace);
      return Left(
        CacheError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Convenience method to call without parameters
  Future<Either<AppError, Weather>> execute() => call(const NoParams());
}
