import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for saving a city to recent searches
class SaveToRecentSearches extends UseCase<bool, String> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  SaveToRecentSearches(this.repository);

  @override
  Future<Either<AppError, bool>> call(String cityName) async {
    appLogger.i('SaveToRecentSearches: Saving $cityName to recent searches');

    try {
      final success = await repository.saveToRecentSearches(cityName);

      if (success) {
        appLogger.i('SaveToRecentSearches: Successfully saved $cityName');
        return const Right(true);
      } else {
        appLogger.w('SaveToRecentSearches: Failed to save $cityName');
        return Left(
          CacheError(message: 'Failed to save $cityName to recent searches'),
        );
      }
    } catch (e, stackTrace) {
      appLogger.e('SaveToRecentSearches: Unexpected error', e, stackTrace);
      return Left(
        CacheError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
