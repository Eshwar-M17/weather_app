import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching cached forecast data
class GetCachedForecast extends UseCase<Forecast, NoParams> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetCachedForecast(this.repository);

  @override
  Future<Either<AppError, Forecast>> call(NoParams params) async {
    appLogger.i('GetCachedForecast: Fetching cached forecast');

    try {
      final result = await repository.getCachedForecast();

      result.fold(
        (error) => appLogger.e(
          'GetCachedForecast: Error fetching cached forecast - ${error.message}',
          null,
          error.stackTrace,
        ),
        (forecast) => appLogger.i(
          'GetCachedForecast: Successfully fetched cached forecast for ${forecast.cityName}',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetCachedForecast: Unexpected error', e, stackTrace);
      return Left(
        CacheError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Convenience method to call without parameters
  Future<Either<AppError, Forecast>> execute() => call(const NoParams());
}
