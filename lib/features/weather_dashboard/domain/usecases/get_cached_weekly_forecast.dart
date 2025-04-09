import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/data/models/daily_forecast_model.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching cached weekly forecast data
class GetCachedWeeklyForecast extends UseCase<WeeklyForecastModel, NoParams> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetCachedWeeklyForecast(this.repository);

  @override
  Future<Either<AppError, WeeklyForecastModel>> call(NoParams params) async {
    appLogger.i('GetCachedWeeklyForecast: Fetching cached weekly forecast');

    try {
      final result = await repository.getCachedWeeklyForecast();

      result.fold(
        (error) => appLogger.e(
          'GetCachedWeeklyForecast: Error fetching cached weekly forecast - ${error.message}',
          null,
          error.stackTrace,
        ),
        (forecast) => appLogger.i(
          'GetCachedWeeklyForecast: Successfully fetched cached weekly forecast',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetCachedWeeklyForecast: Unexpected error', e, stackTrace);
      return Left(
        CacheError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Convenience method to call without parameters
  Future<Either<AppError, WeeklyForecastModel>> execute() =>
      call(const NoParams());
}
