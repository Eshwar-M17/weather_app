import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';

/// Page showing list of recent search queries with weather cards
class RecentSearchesPage extends ConsumerStatefulWidget {
  /// Creates a RecentSearchesPage
  const RecentSearchesPage({super.key});

  @override
  ConsumerState<RecentSearchesPage> createState() => _RecentSearchesPageState();
}

class _RecentSearchesPageState extends ConsumerState<RecentSearchesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showCloseButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.isEmpty) return;

    appLogger.i('Search submitted: $query');
    _selectCity(context, ref, query);
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final recentSearchesState = ref.watch(recentSearchesControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBlueBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recent Searches'),
        actions: [
          // Clear all recent searches button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all searches',
            onPressed: () => _clearAllSearches(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSubmitted: _onSearchSubmitted,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for a city',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon:
                        _showCloseButton
                            ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                              },
                            )
                            : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          // Recent searches list
          Expanded(
            child: recentSearchesState.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (searches) {
                if (searches.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recent searches yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: searches.length,
                  itemBuilder: (context, index) {
                    final city = searches[index];
                    return _buildCityCard(context, city);
                  },
                );
              },
              error:
                  (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $message',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadRecentSearches(ref),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, String cityName) {
    // Mock data for UI display - in a real app, you would fetch actual data
    // or store it with the recent searches
    final mockTemp = (cityName.hashCode % 30 + 5).abs();
    final mockHighTemp = mockTemp + 3;
    final mockLowTemp = mockTemp - 2;

    // Determine a weather condition based on the city name's hash
    final weatherConditionIndex = cityName.hashCode % 4;
    String weatherCondition;

    switch (weatherConditionIndex) {
      case 0:
        weatherCondition = 'Partly Cloudy';
        break;
      case 1:
        weatherCondition = 'Mid Rain';
        break;
      case 2:
        weatherCondition = 'Fast Wind';
        break;
      case 3:
        weatherCondition = 'Showers';
        break;
      default:
        weatherCondition = 'Clear';
    }

    return GestureDetector(
      onTap: () => _selectCity(context, ref, cityName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [const Color(0xFF5936B4), const Color(0xFF362A84)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Temperature and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temperature
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$mockTemp°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'H:$mockHighTemp° L:$mockLowTemp°',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Text(
                      cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Weather condition and icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Icon based on condition
                  _getWeatherIcon(weatherConditionIndex),
                  const SizedBox(height: 8),
                  // Condition text
                  Text(
                    weatherCondition,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWeatherIcon(int conditionIndex) {
    // Return different icons based on the condition
    switch (conditionIndex) {
      case 0: // Partly Cloudy
        return Icon(Icons.cloud, color: Colors.white, size: 48);
      case 1: // Mid Rain
        return Icon(Icons.grain, color: Colors.white, size: 48);
      case 2: // Fast Wind
        return Icon(Icons.air, color: Colors.white, size: 48);
      case 3: // Showers
        return Icon(Icons.water_drop, color: Colors.white, size: 48);
      default:
        return Icon(Icons.wb_sunny, color: Colors.white, size: 48);
    }
  }

  void _loadRecentSearches(WidgetRef ref) {
    appLogger.i('Loading recent searches');
    ref.read(recentSearchesControllerProvider.notifier).loadRecentSearches();
  }

  void _selectCity(BuildContext context, WidgetRef ref, String city) {
    appLogger.i('Selected city from recent searches: $city');

    // Navigate to home and load selected city
    context.go(AppRoutes.home);

    // Wait for navigation to complete before fetching weather
    Future.microtask(() {
      ref
          .read(currentWeatherControllerProvider.notifier)
          .getCurrentWeather(city);
      ref.read(forecastControllerProvider.notifier).getForecast(city);
    });
  }

  void _clearAllSearches(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardBackgroundColor,
            title: const Text(
              'Clear All Searches?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This will remove all your recent search history. This action cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(recentSearchesControllerProvider.notifier)
                      .clearSearches();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search history cleared'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('CLEAR'),
              ),
            ],
          ),
    );
  }
}
