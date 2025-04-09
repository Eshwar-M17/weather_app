import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/loading_widget.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_icon.dart';

/// Page showing detailed weather information for a location
class WeatherDetailsPage extends ConsumerStatefulWidget {
  /// Optional weather data to display
  /// If not provided, will fetch using cityName
  final Weather? weather;

  /// City name to fetch weather for (if weather not provided)
  final String? cityName;

  /// Creates a WeatherDetailsPage
  const WeatherDetailsPage({super.key, this.weather, this.cityName})
    : assert(
        weather != null || cityName != null,
        'Either weather or cityName must be provided',
      );

  @override
  ConsumerState<WeatherDetailsPage> createState() => _WeatherDetailsPageState();
}

class _WeatherDetailsPageState extends ConsumerState<WeatherDetailsPage> {
  String? _cityName;

  @override
  void initState() {
    super.initState();

    _cityName = widget.cityName ?? widget.weather?.cityName;

    // If we only have a city name, we need to fetch the weather
    if (widget.weather == null && _cityName != null) {
      appLogger.i('Fetching weather for city: $_cityName');
      _fetchWeatherData(_cityName!);
    }
  }

  Future<void> _fetchWeatherData(String city) async {
    appLogger.i('Fetching detailed weather data for $city');
    ref.read(currentWeatherControllerProvider.notifier).getCurrentWeather(city);
  }

  void _onRefresh() {
    if (_cityName != null) {
      appLogger.i('Manual refresh initiated for $_cityName');
      _fetchWeatherData(_cityName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If weather is provided directly, use it, otherwise get from state
    final weatherData = widget.weather;
    final weatherState = ref.watch(currentWeatherControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(weatherData?.cityName ?? _cityName ?? 'Weather Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          weatherData != null
              ? _buildWeatherDetails(weatherData)
              : weatherState.when(
                initial: () => const LoadingWeatherWidget(),
                loading: () => const LoadingWeatherWidget(),
                data: (weather) => _buildWeatherDetails(weather),
                error:
                    (message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $message',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    _cityName != null
                                        ? _fetchWeatherData(_cityName!)
                                        : null,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
              ),
    );
  }

  Widget _buildWeatherDetails(Weather weather) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header with city and date
          Text(
            '${weather.cityName}, ${weather.country}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            dateFormat.format(weather.timestamp),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Current weather card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Current temperature and condition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          WeatherIcon(iconCode: weather.iconCode, size: 70),
                          Text(
                            weather.condition,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            weather.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weather details card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.water_drop_outlined,
                    'Humidity',
                    '${weather.humidity}%',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.air,
                    'Wind',
                    '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.compress,
                    'Pressure',
                    '${weather.pressure} hPa',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.visibility,
                    'Visibility',
                    '${weather.visibility} km',
                  ),
                  if (weather.rainLastHour != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      Icons.water,
                      'Rain (last hour)',
                      '${weather.rainLastHour!.toStringAsFixed(1)} mm',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sunrise/Sunset card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sun', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            size: 40,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 8),
                          const Text('Sunrise'),
                          Text(
                            timeFormat.format(weather.sunrise),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.nightlight,
                            size: 40,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 8),
                          const Text('Sunset'),
                          Text(
                            timeFormat.format(weather.sunset),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Additional data if available
          if (weather.airQualityIndex != null || weather.uvIndex != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (weather.airQualityIndex != null)
                      _buildDetailRow(
                        context,
                        Icons.air_sharp,
                        'Air Quality Index',
                        '${weather.airQualityIndex}',
                      ),
                    if (weather.uvIndex != null) ...[
                      if (weather.airQualityIndex != null)
                        const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        Icons.wb_sunny_outlined,
                        'UV Index',
                        '${weather.uvIndex}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Attribution
          const Center(
            child: Text(
              'Data provided by OpenWeatherMap',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
