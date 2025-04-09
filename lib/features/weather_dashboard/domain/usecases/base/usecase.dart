import 'package:dartz/dartz.dart';
import 'package:weather_app/core/utils/app_error.dart';

/// Base abstract class for all use cases
///
/// Type parameters:
/// - [Type] - Return type of the use case
/// - [Params] - Parameters required by the use case
abstract class UseCase<Type, Params> {
  /// Call method to make the class callable
  ///
  /// Every use case should implement this method with specific logic
  Future<Either<AppError, Type>> call(Params params);
}

/// Special case for use cases that don't require parameters
class NoParams {
  const NoParams();
}
