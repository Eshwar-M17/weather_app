import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A semi-circular gauge that displays atmospheric pressure with color-coded
/// segments for low, normal, and high pressure ranges
class PressureGauge extends StatelessWidget {
  /// Current pressure value in hPa (hectopascals)
  final int pressure;

  /// Minimum pressure value for the gauge scale (default: 970 hPa)
  final int minPressure;

  /// Maximum pressure value for the gauge scale (default: 1050 hPa)
  final int maxPressure;

  /// Threshold below which pressure is considered "low" (default: 1000 hPa)
  final int lowThreshold;

  /// Threshold above which pressure is considered "high" (default: 1020 hPa)
  final int highThreshold;

  /// Creates a pressure gauge widget
  const PressureGauge({
    Key? key,
    required this.pressure,
    this.minPressure = 970,
    this.maxPressure = 1050,
    this.lowThreshold = 1000,
    this.highThreshold = 1020,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine pressure category
    String pressureCategory;
    if (pressure < lowThreshold) {
      pressureCategory = 'Low';
    } else if (pressure > highThreshold) {
      pressureCategory = 'High';
    } else {
      pressureCategory = 'Normal';
    }

    return SizedBox(
      height: 90, // Further reduced height
      child: Column(
        children: [
          SizedBox(height: 10),
          // Pressure value and category

          // Gauge - taking rest of the space
          Expanded(
            child: CustomPaint(
              size: Size.fromHeight(60),
              painter: _PressureGaugePainter(
                pressure: pressure,
                minPressure: minPressure,
                maxPressure: maxPressure,
                lowThreshold: lowThreshold,
                highThreshold: highThreshold,
                categoryLabel: pressureCategory,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing the pressure gauge
class _PressureGaugePainter extends CustomPainter {
  final int pressure;
  final int minPressure;
  final int maxPressure;
  final int lowThreshold;
  final int highThreshold;
  final String categoryLabel;
  final TextDirection textDirection;

  _PressureGaugePainter({
    required this.pressure,
    required this.minPressure,
    required this.maxPressure,
    required this.lowThreshold,
    required this.highThreshold,
    required this.categoryLabel,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Move center up to allow more space for gauge
    final center = Offset(size.width / 2, size.height * 0.53);

    // Increase radius for a larger gauge
    final radius = math.min(size.width, size.height) * 0.5;

    // Adjust text sizes based on available space
    final valueFontSize = math.min(size.width, size.height) * 0.18;
    final unitFontSize = valueFontSize * 0.35;
    final markerFontSize = unitFontSize * 1.1;

    // Calculate normalized values for arc positions (0.0 to 1.0)
    final lowNormalNorm =
        (lowThreshold - minPressure) / (maxPressure - minPressure);
    final highNormalNorm =
        (highThreshold - minPressure) / (maxPressure - minPressure);
    final pressureNorm = (pressure - minPressure) / (maxPressure - minPressure);
    final clampedPressureNorm = pressureNorm.clamp(0.0, 1.0);

    // Increase thickness - thicker gauge
    final segmentWidth = radius * 0.12;
    final segmentRadius = radius;

    // Draw background (light gray semi-circle)
    final bgPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = segmentWidth
          ..strokeCap = StrokeCap.round;

    // Draw semi-circle from -180 to 0 degrees (π to 0 radians)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start at left (-180 degrees)
      math.pi, // Sweep 180 degrees clockwise
      false,
      bgPaint,
    );

    // Low segment (blue)
    final lowPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = segmentWidth
          ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: segmentRadius),
      math.pi, // Start angle (-180 degrees)
      math.pi * lowNormalNorm, // End at lowNormal
      false,
      lowPaint,
    );

    // Normal segment (green)
    final normalPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = segmentWidth
          ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: segmentRadius),
      math.pi + (math.pi * lowNormalNorm), // Start at lowNormal
      math.pi * (highNormalNorm - lowNormalNorm), // Span the normal range
      false,
      normalPaint,
    );

    // High segment (red)
    final highPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = segmentWidth
          ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: segmentRadius),
      math.pi + (math.pi * highNormalNorm), // Start at highNormal
      math.pi * (1.0 - highNormalNorm), // End at 0 degrees
      false,
      highPaint,
    );

    // Draw tick marks and labels
    final tickPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final markerStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: markerFontSize,
      fontWeight: FontWeight.w500,
    );

    // Draw min and max ticks with labels
    void drawTickWithLabel(double anglePercent, String label) {
      final angle = math.pi + (math.pi * anglePercent);
      final outerPoint = Offset(
        center.dx + (radius + segmentWidth / 2 + 2) * math.cos(angle),
        center.dy + (radius + segmentWidth / 2 + 2) * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - segmentWidth / 2 - 2) * math.cos(angle),
        center.dy + (radius - segmentWidth / 2 - 2) * math.sin(angle),
      );

      // Draw tick
      canvas.drawLine(innerPoint, outerPoint, tickPaint);

      // Draw label
      final labelSpan = TextSpan(text: label, style: markerStyle);
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: textDirection,
        textAlign: TextAlign.center,
      );

      labelPainter.layout();

      // Position labels farther away from the gauge
      final labelOffset = Offset(
        center.dx +
            (radius + segmentWidth / 2 + 12) * math.cos(angle) -
            labelPainter.width / 2,
        center.dy +
            (radius + segmentWidth / 2 + 12) * math.sin(angle) -
            labelPainter.height / 2,
      );

      labelPainter.paint(canvas, labelOffset);
    }

    // Draw tick marks with "Low" and "High" labels instead of numbers
    drawTickWithLabel(0.05, 'Low'); // Min (left)
    drawTickWithLabel(0.95, 'High'); // Max (right)

    // Draw needle - SHORTER LENGTH
    final needleLength = radius * 0.7; // Reduced from radius - segmentWidth/2
    final needleAngle = math.pi + (math.pi * clampedPressureNorm);
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Draw needle shadow for depth
    final needleShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              4.0 // Increased thickness
          ..strokeCap = StrokeCap.round;

    // Draw needle with shadow
    canvas.drawLine(
      Offset(center.dx + 1, center.dy + 1),
      Offset(needleEnd.dx + 1, needleEnd.dy + 1),
      needleShadowPaint,
    );

    final needlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              3.0 // Increased thickness
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw needle center circle - larger
    final centerShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1),
      8, // Increased size
      centerShadowPaint,
    );

    final centerDotPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 7, centerDotPaint); // Increased size

    // Position for the pressure value and unit directly on the canvas without background
    final valueStyle = TextStyle(
      color: Colors.white,
      fontSize: valueFontSize,
      fontWeight: FontWeight.w600,
    );

    final valueUnitStyle = TextStyle(
      color: Colors.white70,
      fontSize: unitFontSize,
      fontWeight: FontWeight.w400,
    );

    // Create combined text with pressure value and unit
    final valueSpan = TextSpan(
      children: [
        TextSpan(text: '$pressure', style: valueStyle),
        TextSpan(text: ' hPa', style: valueUnitStyle),
      ],
    );

    final valuePainter = TextPainter(
      text: valueSpan,
      textDirection: textDirection,
      textAlign: TextAlign.center,
    );

    valuePainter.layout();

    // Draw value text directly without background
    valuePainter.paint(
      canvas,
      Offset(
        center.dx - valuePainter.width / 2,
        center.dy + radius * 0.5 - valuePainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
