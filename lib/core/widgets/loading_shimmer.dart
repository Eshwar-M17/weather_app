import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// A loading shimmer effect for content placeholders
class LoadingShimmer extends StatelessWidget {
  /// Width of the shimmer container
  final double? width;

  /// Height of the shimmer container
  final double? height;

  /// Border radius of the shimmer container
  final double borderRadius;

  /// Creates a loading shimmer effect
  const LoadingShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Weather card shimmer for the dashboard
class WeatherCardShimmer extends StatelessWidget {
  const WeatherCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LoadingShimmer(width: 120, height: 24),
              const LoadingShimmer(width: 80, height: 24),
            ],
          ),
          const SizedBox(height: 16),

          // Temperature
          const LoadingShimmer(width: 100, height: 50),
          const SizedBox(height: 16),

          // Details
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LoadingShimmer(width: 80, height: 20),
              LoadingShimmer(width: 60, height: 20),
              LoadingShimmer(width: 70, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Forecast shimmer for the horizontal list
class ForecastShimmer extends StatelessWidget {
  const ForecastShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.all(16.0),
            width: 100,
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingShimmer(width: 60, height: 16),
                SizedBox(height: 12),
                LoadingShimmer(width: 40, height: 40),
                SizedBox(height: 12),
                LoadingShimmer(width: 40, height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Weather details shimmer for the detail cards
class WeatherDetailsShimmer extends StatelessWidget {
  const WeatherDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingShimmer(width: 80, height: 16),
              SizedBox(height: 16),
              LoadingShimmer(width: 70, height: 30),
              SizedBox(height: 16),
              LoadingShimmer(width: 100, height: 16),
            ],
          ),
        );
      },
    );
  }
}
