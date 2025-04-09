import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:weather_app/core/theme/app_theme.dart';

/// A card that displays wind information with a simple compass
class WindCompassCard extends StatelessWidget {
  /// Wind speed in km/h
  final double windSpeed;

  /// Wind direction in degrees (0-360)
  final int windDeg;

  /// Creates a wind compass card
  const WindCompassCard({
    super.key,
    required this.windSpeed,
    required this.windDeg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compass with speed
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circle
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                  ),

                  // Cardinal directions
                  // North
                  Positioned(
                    top: 2,
                    child: Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // East
                  Positioned(
                    right: 2,
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // South
                  Positioned(
                    bottom: 2,
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // West
                  Positioned(
                    left: 2,
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Direction arrow line
                  Transform.rotate(
                    angle:
                        (windDeg - 90) *
                        math.pi /
                        180, // Adjust so 0 degrees points up
                    child: CustomPaint(
                      size: Size(95, 95),
                      painter: ArrowLinePainter(),
                    ),
                  ),

                  // Wind speed in center
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackgroundColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${windSpeed.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'km/h',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing a line with an arrow at the end
class ArrowLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final Paint arrowPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final endPoint = Offset(size.width - 10, size.height / 2);

    // Draw the line
    canvas.drawLine(center, endPoint, linePaint);

    // Draw the arrow head
    final path = Path();
    const double arrowSize = 6.0;

    path.moveTo(endPoint.dx, endPoint.dy);
    path.lineTo(endPoint.dx - arrowSize, endPoint.dy - arrowSize / 2);
    path.lineTo(endPoint.dx - arrowSize, endPoint.dy + arrowSize / 2);
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
