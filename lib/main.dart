import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/di/dependency_injection.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/app_router.dart';
import 'package:weather_app/features/weather_dashboard/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';
import 'package:weather_app/test_api.dart'; // Import the test page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log startup information
  appLogger.i('Weather App starting...');
  appLogger.d('API Key: ${AppConstants.apiKey.substring(0, 5)}...');
  appLogger.d('Default city: ${AppConstants.defaultCity}');

  // Initialize dependencies
  final dependencies = await DependencyInjection.initDependencies();
  final weatherRepository =
      dependencies['weatherRepository'] as WeatherRepository;

  // Create ProviderContainer with overrides
  final container = ProviderContainer(
    overrides: [
      // Override the weather repository provider
      weatherRepositoryProvider.overrideWithValue(weatherRepository),
    ],
  );

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// Main application widget
class MyApp extends StatelessWidget {
  /// Creates the main application widget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Choose between normal app and test page
    const bool runTestMode = false; // Set to false to run normal app

    // Normal app
    return MaterialApp.router(
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
