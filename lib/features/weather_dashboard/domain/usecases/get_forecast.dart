import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching forecast data
class GetForecast extends UseCase<Forecast, String> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetForecast(this.repository);

  @override
  Future<Either<AppError, Forecast>> call(String cityName) async {
    appLogger.i('GetForecast: Fetching forecast for $cityName');

    try {
      final result = await repository.getForecast(cityName);

      result.fold(
        (error) => appLogger.e(
          'GetForecast: Error fetching forecast - ${error.message}',
          null,
          error.stackTrace,
        ),
        (forecast) => appLogger.i(
          'GetForecast: Successfully fetched forecast for ${forecast.cityName}',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetForecast: Unexpected error', e, stackTrace);
      return Left(
        ServerError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
