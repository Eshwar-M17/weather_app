import 'package:flutter/material.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// A custom gradient progress indicator used for air quality, UV index, etc.
class GradientProgressIndicator extends StatelessWidget {
  /// The current value of the indicator (between 0.0 and 1.0)
  final double value;

  /// Optional custom colors for the gradient
  final List<Color>? gradientColors;

  /// Height of the indicator
  final double height;

  /// Whether to show a dot at the current value position
  final bool showDot;

  /// Radius of the dot (if shown)
  final double dotRadius;

  /// Creates a gradient progress indicator
  ///
  /// [value] must be between 0.0 and 1.0
  const GradientProgressIndicator({
    super.key,
    required this.value,
    this.gradientColors,
    this.height = 4.0,
    this.showDot = true,
    this.dotRadius = 4.0,
  }) : assert(
         value >= 0.0 && value <= 1.0,
         'Value must be between 0.0 and 1.0',
       );

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppTheme.airQualityGradient;

    return SizedBox(
      height: height + (showDot ? dotRadius * 2 : 0),
      child: Stack(
        children: [
          // Base track
          Container(
            height: height,
            margin: EdgeInsets.only(top: showDot ? dotRadius : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),

          // Dot indicator
          if (showDot)
            Positioned(
              left: value * MediaQuery.of(context).size.width * 0.8 - dotRadius,
              child: Container(
                width: dotRadius * 2,
                height: dotRadius * 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
