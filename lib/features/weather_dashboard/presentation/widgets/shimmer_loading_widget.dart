import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// A shimmer loading widget for the weather dashboard
class ShimmerLoadingWidget extends StatelessWidget {
  /// Creates a shimmer loading effect
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF362A84), // Dark purple from app theme
      highlightColor: const Color(0xFF5936B4), // Light purple from app theme
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City and temperature shimmer
          _buildWeatherHeaderShimmer(),

          const SizedBox(height: 16),

          // Forecast card shimmer
          _buildForecastCardShimmer(),

          const SizedBox(height: 24),

          // Details grid shimmer
          _buildWeatherDetailsGridShimmer(),
        ],
      ),
    );
  }

  Widget _buildWeatherHeaderShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // City name
        Container(
          height: 28,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 16),

        // Temperature
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(width: 8),

            // Weather condition
            Container(
              height: 28,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecastCardShimmer() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Tab headers
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hourly items
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => Container(
                    width: 60,
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGridShimmer() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(
        8,
        (index) => Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
