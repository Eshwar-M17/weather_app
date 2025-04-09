import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/cache/cache_service.dart';
import 'package:weather_app/core/network/api_client.dart';
import 'package:weather_app/core/utils/network_info.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_local_data_source.dart';
import 'package:weather_app/features/weather_dashboard/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/features/weather_dashboard/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service locator for dependency injection
class DependencyInjection {
  DependencyInjection._(); // Private constructor to prevent instantiation

  /// Register all dependencies
  static Future<Map<String, dynamic>> initDependencies() async {
    final Map<String, dynamic> dependencies = {};

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    dependencies['sharedPreferences'] = sharedPreferences;

    // Core services
    final cacheService = CacheService(prefs: sharedPreferences);
    dependencies['cacheService'] = cacheService;

    final httpClient = http.Client();
    dependencies['httpClient'] = httpClient;

    final apiClient = ApiClient(client: httpClient);
    dependencies['apiClient'] = apiClient;

    final connectivity = Connectivity();
    dependencies['connectivity'] = connectivity;

    final networkInfo = NetworkInfoImpl(connectivity);
    dependencies['networkInfo'] = networkInfo;

    // Data sources
    final weatherLocalDataSource = WeatherLocalDataSourceImpl(
      cacheService: cacheService,
    );
    dependencies['weatherLocalDataSource'] = weatherLocalDataSource;

    final weatherRemoteDataSource = WeatherRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    dependencies['weatherRemoteDataSource'] = weatherRemoteDataSource;

    // Repositories
    final weatherRepository = WeatherRepositoryImpl(
      remoteDataSource: weatherRemoteDataSource,
      localDataSource: weatherLocalDataSource,
      networkInfo: networkInfo,
    );
    dependencies['weatherRepository'] = weatherRepository;

    return dependencies;
  }
}
