import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const IslamicBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF1F2937),
                  const Color(0xFF111827),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFE2E8F0),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Opacity(
            opacity: isDarkMode ? 0.03 : 0.05,
            child: CustomPaint(
              painter: IslamicPatternPainter(),
              size: Size.infinite,
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const tileSize = 50.0;
    final horizontalTiles = (size.width / tileSize).ceil();
    final verticalTiles = (size.height / tileSize).ceil();

    for (var i = 0; i < horizontalTiles; i++) {
      for (var j = 0; j < verticalTiles; j++) {
        final centerX = i * tileSize + tileSize / 2;
        final centerY = j * tileSize + tileSize / 2;

        // Draw octagon
        final path = Path();
        for (var k = 0; k < 8; k++) {
          final angle = k * pi / 4;
          final x = centerX + cos(angle) * tileSize / 3;
          final y = centerY + sin(angle) * tileSize / 3;
          if (k == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);

        // Draw inner star
        final starPath = Path();
        for (var k = 0; k < 8; k++) {
          final outerAngle = k * pi / 4;
          final innerAngle = outerAngle + pi / 8;
          final outerX = centerX + cos(outerAngle) * tileSize / 4;
          final outerY = centerY + sin(outerAngle) * tileSize / 4;
          final innerX = centerX + cos(innerAngle) * tileSize / 6;
          final innerY = centerY + sin(innerAngle) * tileSize / 6;

          if (k == 0) {
            starPath.moveTo(outerX, outerY);
          } else {
            starPath.lineTo(outerX, outerY);
          }
          starPath.lineTo(innerX, innerY);
        }
        starPath.close();
        canvas.drawPath(starPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
