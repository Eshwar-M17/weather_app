import 'package:flutter/material.dart';

/// A widget that displays a sun position on a curved path
/// representing the sun's journey from sunrise to sunset
class SunPositionGauge extends StatelessWidget {
  /// Value between 0.0 and 1.0 representing the sun's position
  /// in its daily journey (0.0 = sunrise, 1.0 = sunset)
  final double progressPercent;

  /// Creates a sun position gauge
  const SunPositionGauge({Key? key, required this.progressPercent})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SunPositionPainter(
        progressPercent: progressPercent,
        textDirection: Directionality.of(context),
      ),
    );
  }
}

/// Painter for sun position curve and dot
class _SunPositionPainter extends CustomPainter {
  final double progressPercent;
  final TextDirection textDirection;

  _SunPositionPainter({
    required this.progressPercent,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizon line
    final horizonPaint =
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Horizon line positioned exactly at center
    final double horizonY = size.height / 2;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );

    // Define the curve path
    final path = Path();
    final curveHeight = size.height * 0.45; // Less height for a wider arc

    // Starting from left horizon
    path.moveTo(0, horizonY);

    // Draw curve through center top to right horizon
    path.quadraticBezierTo(
      size.width / 2,
      horizonY - curveHeight,
      size.width,
      horizonY,
    );

    // Draw curve
    final curvePaint =
        Paint()
          ..color = Colors.lightBlue.shade200.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawPath(path, curvePaint);

    // Calculate dot position along the curve
    final double x = size.width * progressPercent;

    // Calculate y position on the quadratic curve
    final double t = progressPercent;
    final double y0 = horizonY;
    final double y1 = horizonY - curveHeight;
    final double y2 = horizonY;
    final double y = (1 - t) * (1 - t) * y0 + 2 * t * (1 - t) * y1 + t * t * y2;

    // Draw the dot with glow effect
    final glowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    final dotPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Larger glow for more visibility
    canvas.drawCircle(Offset(x, y), 10, glowPaint);
    canvas.drawCircle(Offset(x, y), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SunPositionPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent;
  }
}
