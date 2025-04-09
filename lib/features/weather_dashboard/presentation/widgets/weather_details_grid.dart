import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/gauges/pressure_gauge.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/gauges/sun_position_gauge.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/wind_compass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/features/weather_dashboard/data/models/air_quality_model.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';

// The following imports are commented out because the files don't exist yet
// import 'package:weather_app/features/weather_dashboard/presentation/widgets/detail_card.dart';
// import 'package:weather_app/features/weather_dashboard/presentation/widgets/gauges/pressure_gauge_painter.dart';
// import 'package:weather_app/core/widgets/gradient_progress_bar.dart';

/// Widget for displaying detailed weather information in a grid layout
class WeatherDetailsGrid extends StatelessWidget {
  /// Weather data to display
  final Weather weather;

  /// Creates a weather details grid
  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Air Quality card (spans 2 columns)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
          child: _buildAirQualityCard(),
        ),

        // Regular grid items
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          children: [
            _buildSunriseCard(context),
            _buildUVIndexCard(),
            _buildWindCard(),
            _buildRainfallCard(),
            _buildFeelsLikeCard(),
            _buildHumidityCard(),
            _buildVisibilityCard(),
            _buildPressureCard(context),
          ],
        ),
      ],
    );
  }

  /// Builds the air quality card that spans two columns
  Widget _buildAirQualityCard() {
    return DetailCard(
      title: 'AIR QUALITY',
      iconData: Icons.air_outlined,
      fullWidth: true,
      child: Consumer(
        builder: (context, ref, _) {
          // Use generic coordinates for demo purposes, actual implementation would use weather's coordinates
          final coordinates = (
            lat: 51.5074,
            lon: -0.1278,
          ); // London coordinates

          final airQualityAsync = ref.watch(airQualityProvider(coordinates));

          return airQualityAsync.when(
            data: (airQuality) {
              // Get AQI level and calculate indicator value
              final aqi = airQuality.aqi;
              final indicatorValue = (aqi - 1) / 4.0; // AQI is 1-5

              // Get level text based on AQI
              String levelText;
              if (aqi == 1)
                levelText = '1-Good';
              else if (aqi == 2)
                levelText = '2-Fair';
              else if (aqi == 3)
                levelText = '3-Moderate';
              else if (aqi == 4)
                levelText = '4-Poor';
              else if (aqi == 5)
                levelText = '5-Very Poor';
              else
                levelText = 'Unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content
                  Row(
                    children: [
                      // Title and value
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              levelText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              airQuality.description,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),

                      // Arrow icon
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Air quality gradient bar
                  AirQualityIndicator(
                    value: indicatorValue,
                    gradientColors: const [
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                      Colors.purple,
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Air quality index scale
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Good',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        'Moderate',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        'Unhealthy',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        'Hazardous',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Text(
                    'Error loading air quality data',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
          );
        },
      ),
    );
  }

  /// Builds the sunrise/sunset card with sun position visualization
  Widget _buildSunriseCard(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime sunrise = weather.sunrise;
    final DateTime sunset = weather.sunset;

    final String sunriseFormatted =
        DateFormat('h:mm a').format(sunrise).toUpperCase();
    final String sunsetFormatted =
        DateFormat('h:mm a').format(sunset).toUpperCase();

    // Calculate current position for the sun
    final double dayLength = sunset.difference(sunrise).inMinutes.toDouble();
    final double minutesSinceSunrise =
        now.difference(sunrise).inMinutes.toDouble();
    final double progressPercent = (minutesSinceSunrise / dayLength).clamp(
      0.0,
      1.0,
    );

    return DetailCard(
      title: 'SUNRISE',
      iconData: Icons.wb_twilight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sunrise time (main display)
          Text(
            sunriseFormatted,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Sun position arc
          SizedBox(
            height: 60, // Fixed height instead of Expanded
            child: SunPositionGauge(progressPercent: progressPercent),
          ),

          // Sunset time
          Text(
            'Sunset: $sunsetFormatted',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UV index card
  Widget _buildUVIndexCard() {
    return Builder(
      builder: (context) {
        const double uvIndex = 4.0;
        const double maxIndex = 11.0;
        final double progressPercent = (uvIndex / maxIndex).clamp(0.0, 1.0);

        return DetailCard(
          title: 'UV INDEX',
          iconData: Icons.wb_sunny_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Moderate',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // UV index gradient bar
              Container(
                height: 6.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Colors.blue, Colors.purple, Colors.pink],
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left:
                          progressPercent *
                          MediaQuery.of(context).size.width *
                          0.4,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the wind speed and direction card
  Widget _buildWindCard() {
    return DetailCard(
      title: 'WIND',
      iconData: Icons.air,
      child: SizedBox(
        height: 120, // Constrain height to prevent overflow
        child: WindCompassCard(
          windSpeed: weather.windSpeed,
          windDeg: weather.windDeg ?? 0,
        ),
      ),
    );
  }

  /// Builds the rainfall information card
  Widget _buildRainfallCard() {
    return DetailCard(
      title: 'RAINFALL',
      iconData: Icons.water_drop_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '1.8 mm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'in last hour',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '1.2 mm expected in next 24h.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  /// Builds the "feels like" temperature card
  Widget _buildFeelsLikeCard() {
    return DetailCard(
      title: 'FEELS LIKE',
      iconData: Icons.thermostat_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${weather.feelsLike.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Similar to the actual temperature.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  /// Builds the humidity information card
  Widget _buildHumidityCard() {
    return DetailCard(
      title: 'HUMIDITY',
      iconData: Icons.water_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${weather.humidity}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'The dew point is 17 right now.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  /// Builds the visibility information card
  Widget _buildVisibilityCard() {
    return DetailCard(
      title: 'VISIBILITY',
      iconData: Icons.visibility_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${weather.visibility} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Clear conditions provide good visibility.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  /// Builds the pressure gauge card
  Widget _buildPressureCard(BuildContext context) {
    // Determine pressure category based on simple thresholds
    final int pressure = weather.pressure;
    String pressureCategory;

    if (pressure < 1000) {
      pressureCategory = 'Low';
    } else if (pressure > 1020) {
      pressureCategory = 'High';
    } else {
      pressureCategory = 'Normal';
    }

    return DetailCard(
      title: 'PRESSURE',
      iconData: Icons.compress,
      child: PressureGauge(
        pressure: pressure,
        minPressure: 970,
        maxPressure: 1050,
        lowThreshold: 1000,
        highThreshold: 1020,
      ),
    );
  }
}

/// Reusable card template for weather details
class DetailCard extends StatelessWidget {
  /// The title to display in the card header
  final String title;

  /// The icon to display next to the title
  final IconData iconData;

  /// The content of the card
  final Widget child;

  /// Whether the card should take the full width
  final bool fullWidth;

  /// Creates a detail card
  const DetailCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.child,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with icon
          Row(
            children: [
              Icon(iconData, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Card content
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// A gradient progress bar for visualizing progress or level
class GradientProgressBar extends StatelessWidget {
  /// Value between 0.0 and 1.0
  final double value;

  /// Height of the progress bar
  final double height;

  /// Colors for the gradient
  final List<Color> gradientColors;

  /// Optional border radius
  final double borderRadius;

  /// Creates a gradient progress bar
  const GradientProgressBar({
    Key? key,
    required this.value,
    required this.height,
    required this.gradientColors,
    this.borderRadius = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            left: value * MediaQuery.of(context).size.width * 0.4,
            top: 0,
            child: Container(
              width: 10,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Air quality indicator widget with gradient and position marker
class AirQualityIndicator extends StatelessWidget {
  /// Value between 0.0 and 1.0 indicating position along the gradient
  final double value;

  /// Colors for the gradient
  final List<Color> gradientColors;

  /// Height of the indicator bar
  final double height;

  /// Width of the position marker
  final double markerWidth;

  /// Creates an air quality indicator
  const AirQualityIndicator({
    Key? key,
    required this.value,
    required this.gradientColors,
    this.height = 6.0,
    this.markerWidth = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: value * MediaQuery.of(context).size.width * 0.65,
            top: 0,
            child: Container(
              width: markerWidth,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
