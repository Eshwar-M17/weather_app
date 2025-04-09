import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/domain/usecases/base/usecase.dart';

/// Use case for fetching recent search history
class GetRecentSearches extends UseCase<List<String>, NoParams> {
  /// Weather repository instance
  final WeatherRepository repository;

  /// Constructor that accepts a repository instance
  GetRecentSearches(this.repository);

  @override
  Future<Either<AppError, List<String>>> call(NoParams params) async {
    appLogger.i('GetRecentSearches: Fetching recent searches');

    try {
      final result = await repository.getRecentSearches();

      result.fold(
        (error) => appLogger.e(
          'GetRecentSearches: Error fetching recent searches - ${error.message}',
          null,
          error.stackTrace,
        ),
        (searches) => appLogger.i(
          'GetRecentSearches: Successfully fetched ${searches.length} recent searches',
        ),
      );

      return result;
    } catch (e, stackTrace) {
      appLogger.e('GetRecentSearches: Unexpected error', e, stackTrace);
      return Left(
        CacheError(
          message: 'Unexpected error occurred: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Convenience method to call without parameters
  Future<Either<AppError, List<String>>> execute() => call(const NoParams());
}
