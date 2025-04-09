import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/forecast.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/weather_icon.dart';
import 'package:weather_app/features/weather_dashboard/presentation/widgets/wind_compass_card.dart';

/// Tabs for forecast view
enum ForecastTab { hourly, weekly }

/// Provider for managing the forecast card tab state
final forecastCardStateProvider = StateProvider<ForecastTab>(
  (ref) => ForecastTab.hourly,
);

/// Forecast card widget that displays both hourly and daily forecasts
class ForecastCard extends ConsumerWidget {
  /// Forecast data to display
  final Forecast forecast;

  /// Number of hours to display in hourly view
  final int hourlyItemCount;

  /// Creates a forecast card with tabs
  const ForecastCard({
    super.key,
    required this.forecast,
    this.hourlyItemCount = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ForecastTab _activeTab = ForecastTab.hourly;

    return Column(
      children: [
        // Tab selector
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          height: 48,
          child: Stack(
            children: [
              // Tab buttons
              Row(
                children: [
                  // Hourly tab
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        ref.read(forecastCardStateProvider.notifier).state =
                            ForecastTab.hourly;
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            ref.watch(forecastCardStateProvider) ==
                                    ForecastTab.hourly
                                ? 1.0
                                : 0.5,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Weekly tab
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        ref.read(forecastCardStateProvider.notifier).state =
                            ForecastTab.weekly;
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Weekly Forecast',
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            ref.watch(forecastCardStateProvider) ==
                                    ForecastTab.weekly
                                ? 1.0
                                : 0.5,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Active indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                bottom: 0,
                left:
                    ref.watch(forecastCardStateProvider) == ForecastTab.hourly
                        ? MediaQuery.of(context).size.width / 4 - 20
                        : 3 * MediaQuery.of(context).size.width / 4 - 20,
                child: Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child:
              ref.watch(forecastCardStateProvider) == ForecastTab.hourly
                  ? _buildHourlyForecast(ref)
                  : _buildWeeklyForecast(ref),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(WidgetRef ref) {
    final hourlyForecasts = _getNextHourlyForecasts(ref);
    final now = DateTime.now();

    // Show either the first 5 items or all items if less than 5
    final itemCount = hourlyForecasts.length < 5 ? hourlyForecasts.length : 5;

    return SizedBox(
      height: 170,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
          mainAxisExtent: 85,
          childAspectRatio: 1.2,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final forecastItem = hourlyForecasts[index];

          // Check if this is the current hour
          final isNow =
              index == 0 ||
              (forecastItem.dateTime.hour == now.hour &&
                  forecastItem.dateTime.day == now.day);

          return ForecastItemCard(
            title:
                isNow
                    ? 'Now'
                    : '${forecastItem.dateTime.hour} ${forecastItem.dateTime.hour >= 12 ? 'PM' : 'AM'}',
            iconCode: forecastItem.iconCode,
            condition: forecastItem.condition,
            temperature: '${forecastItem.temperature.round()}°',
            isHighlighted: isNow,
            index: index,
            pop: forecastItem.pop,
            maxItems: itemCount - 1,
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast(WidgetRef ref) {
    // Ensure we have forecast data
    if (forecast.dailyForecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort the daily forecasts by date to ensure they're in order
    final sortedDailyForecasts = List<DailyForecast>.from(
      forecast.dailyForecasts,
    )..sort((a, b) => a.date.compareTo(b.date));

    // Show either the first 5 items or all items if less than 5
    final itemCount =
        sortedDailyForecasts.length < 5 ? sortedDailyForecasts.length : 5;

    return SizedBox(
      height: 170,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
          mainAxisExtent: 85,
          childAspectRatio: 1.2,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final dailyForecast = sortedDailyForecasts[index];
          final now = DateTime.now();
          final isToday =
              dailyForecast.date.year == now.year &&
              dailyForecast.date.month == now.month &&
              dailyForecast.date.day == now.day;

          // Find highest precipitation probability among hourly forecasts
          double highestPop = 0;
          for (var hourly in dailyForecast.hourlyForecasts) {
            if (hourly.pop > highestPop) {
              highestPop = hourly.pop;
            }
          }

          // Format day name (Mon, Tue, etc.)
          String dayName =
              isToday
                  ? 'Today'
                  : _getDayName(dailyForecast.date).substring(0, 3);

          return ForecastItemCard(
            title: dayName,
            iconCode: dailyForecast.iconCode,
            condition: dailyForecast.condition,
            temperature: '${dailyForecast.avgTemp.round()}°',
            isHighlighted: isToday,
            index: index,
            pop: highestPop,
            maxItems: itemCount - 1,
          );
        },
      ),
    );
  }

  /// Gets the next hourly forecasts from all days, filtered to future items.
  List<ForecastItem> _getNextHourlyForecasts(WidgetRef ref) {
    final now = DateTime.now();
    final hourlyForecasts = <ForecastItem>[];

    // Combine items from all days
    for (final daily in forecast.dailyForecasts) {
      hourlyForecasts.addAll(daily.hourlyForecasts);
    }

    // Sort by date/time
    hourlyForecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Filter to only future items, but retain at least the first item
    // for "now" even if it's slightly in the past
    final futureForecasts =
        hourlyForecasts.where((item) {
          return item.dateTime.isAfter(now.subtract(const Duration(hours: 1)));
        }).toList();

    // Limit to requested count
    return futureForecasts.take(hourlyItemCount).toList();
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}

/// Reusable forecast item card for both hourly and weekly forecasts
class ForecastItemCard extends StatelessWidget {
  /// Title to display (hour or day)
  final String title;

  /// Icon code for weather condition
  final String iconCode;

  /// Weather condition text
  final String condition;

  /// Temperature to display
  final String temperature;

  /// Whether this item is highlighted (current time/today)
  final bool isHighlighted;

  /// Index in the list
  final int index;

  /// Precipitation probability (0-1)
  final double pop;

  /// Maximum number of items in the list (for right margin calculation)
  final int maxItems;

  /// Creates a reusable forecast item card
  const ForecastItemCard({
    super.key,
    required this.title,
    required this.iconCode,
    required this.condition,
    required this.temperature,
    required this.isHighlighted,
    required this.index,
    required this.pop,
    this.maxItems = 23,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 4,
        right: index == maxItems ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? Color(0xFF3949AB) // Deeper indigo blue for highlighted item
                : AppTheme
                    .cardBackgroundColor, // Darker blue/indigo for normal items
        borderRadius: BorderRadius.circular(30), // More rounded pill shape
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title (time or day)
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          // Weather icon
          WeatherIcon(iconCode: iconCode, size: 40, condition: condition),

          const SizedBox(height: 6),

          // Precipitation chance if significant
          if (pop >= 0.1)
            Text(
              '${(pop * 100).round()}%',
              style: TextStyle(
                color: Colors.cyan.shade300,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

          if (pop < 0.1) const SizedBox(height: 4),

          // Temperature
          Text(
            temperature,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
