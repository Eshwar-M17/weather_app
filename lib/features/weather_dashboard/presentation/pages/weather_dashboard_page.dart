import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/error_widget.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/forecast_card.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/shimmer_loading_widget.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_details_grid.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_header.dart';
import 'package:weather_app/test_api.dart';

/// Main dashboard page showing current weather and forecast
class WeatherDashboardPage extends ConsumerStatefulWidget {
  /// Creates a WeatherDashboardPage
  const WeatherDashboardPage({super.key});

  @override
  ConsumerState<WeatherDashboardPage> createState() =>
      _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends ConsumerState<WeatherDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentCity = AppConstants.defaultCity;

  @override
  void initState() {
    super.initState();
    _initializeWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeWeather() async {
    // Set initial city
    setState(() {
      _currentCity = AppConstants.defaultCity;
    });

    // Use post-frame callback to ensure we're not in the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we already have data from cache
      final weatherState = ref.read(currentWeatherControllerProvider);

      // Only fetch new data if we don't already have data from cache
      if (weatherState.status != StateStatus.data) {
        appLogger.i('No cached data found, fetching weather for default city');
        // Fetch weather data for default city
        _fetchWeatherData(_currentCity);
      } else if (weatherState.data != null) {
        // Update current city from cached data
        setState(() {
          _currentCity = weatherState.data!.cityName;
        });
        appLogger.i('Using cached data for ${weatherState.data!.cityName}');
      }
    });
  }

  Future<void> _fetchWeatherData(String city) async {
    appLogger.i('Fetching weather data for $city');

    // Make sure we update the city state
    setState(() {
      _currentCity = city;
    });

    try {
      // Check connection status
      final weatherRepo = ref.read(weatherRepositoryProvider);
      final isConnected = await weatherRepo.isConnected();

      if (isConnected) {
        // When online, get both data types and wait for completion
        await ref
            .read(currentWeatherControllerProvider.notifier)
            .getCurrentWeather(city);

        await ref.read(forecastControllerProvider.notifier).getForecast(city);

        // Only save to recent searches if we successfully fetched data
        ref.read(recentSearchesControllerProvider.notifier).saveSearch(city);
      } else {
        // When offline, try to get from cache
        ref
            .read(currentWeatherControllerProvider.notifier)
            .getCurrentWeather(city);

        ref.read(forecastControllerProvider.notifier).getForecast(city);

        // Only add to recent searches if we have the data cached
        if (await weatherRepo.hasCachedWeatherDataForCity(city)) {
          ref.read(recentSearchesControllerProvider.notifier).saveSearch(city);
        }
      }
    } catch (e) {
      appLogger.e('Error fetching weather data', e);
    }
  }

  void _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    appLogger.i('Search submitted: $query');

    // Update UI to show city change
    setState(() {
      _currentCity = query;
    });

    try {
      // Wait for both API calls to complete before adding to recent searches
      // This ensures we have data cached before adding to history
      final weatherRepo = ref.read(weatherRepositoryProvider);
      final isConnected = await weatherRepo.isConnected();

      if (isConnected) {
        // Get weather data first and wait for it to complete
        await ref
            .read(currentWeatherControllerProvider.notifier)
            .getCurrentWeather(query);

        // Get forecast data and wait for it to complete
        await ref.read(forecastControllerProvider.notifier).getForecast(query);

        // Only save to recent searches if we successfully fetched data
        ref.read(recentSearchesControllerProvider.notifier).saveSearch(query);

        appLogger.i(
          'Successfully cached data for $query and saved to recent searches',
        );
      } else {
        // If offline, still try to get data from cache
        ref
            .read(currentWeatherControllerProvider.notifier)
            .getCurrentWeather(query);
        ref.read(forecastControllerProvider.notifier).getForecast(query);

        // Only save offline search if we have cached data for this city
        if (await weatherRepo.hasCachedWeatherDataForCity(query)) {
          ref.read(recentSearchesControllerProvider.notifier).saveSearch(query);
          appLogger.i(
            'Using cached data for $query and saved to recent searches',
          );
        } else {
          appLogger.w('No cached data available for $query while offline');
        }
      }
    } catch (e) {
      appLogger.e('Error in search submission', e);
    }

    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _navigateToRecentSearches() {
    context.push(AppRoutes.recentSearches);
  }

  void _onRefresh() async {
    appLogger.i('Manual refresh initiated for $_currentCity');
    _fetchWeatherData(_currentCity);
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(currentWeatherControllerProvider);
    final forecastState = ref.watch(forecastControllerProvider);

    // Main UI
    return Scaffold(
      backgroundColor: AppTheme.darkBlueBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar with Search
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.darkBlueBackground,
                title: const Text('Weather App'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: _navigateToRecentSearches,
                    tooltip: 'Recent searches',
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: WeatherSearchBar(
                    controller: _searchController,
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: weatherState.when(
                    initial: () => const ShimmerLoadingWidget(),
                    loading: () => const ShimmerLoadingWidget(),
                    data:
                        (weather) =>
                            _buildWeatherContent(weather, forecastState),
                    error:
                        (error) => WeatherErrorWidget(
                          message: error,
                          onRetry: () => _fetchWeatherData(_currentCity),
                          isNetworkError: _isNetworkError(error),
                        ),
                  ),
                ),
              ),

              // Add bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
    Weather weather,
    UIState<Forecast> forecastState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with city name and current temperature
        WeatherHeader(weather: weather),

        const SizedBox(height: 16),

        // Unified forecast card with tabs for hourly and weekly
        forecastState.maybeWhen(
          data: (forecast) => ForecastCard(forecast: forecast),
          loading: () => const ShimmerLoadingWidget(),
          error:
              (errorMsg) => WeatherErrorWidget(
                message: errorMsg,
                onRetry: () => _fetchWeatherData(_currentCity),
                isNetworkError: _isNetworkError(errorMsg),
              ),
          orElse: () => const SizedBox.shrink(),
        ),

        const SizedBox(height: 24),

        // Weather detail cards grid
        WeatherDetailsGrid(weather: weather),

        // Add more bottom padding to ensure scrolling reaches the end
        const SizedBox(height: 40),
      ],
    );
  }

  /// Determines if the error is a network-related error
  bool _isNetworkError(String errorMessage) {
    return errorMessage.contains('Network Error') ||
        errorMessage.contains('internet connection') ||
        errorMessage.contains('No internet') ||
        errorMessage.contains('network error');
  }
}
