import 'dart:math';

import 'package:app/direction.dart';
import 'package:flutter/material.dart';

class DirectionIndicator extends StatelessWidget {
  final List<Direction> directions;

  DirectionIndicator({required this.directions});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(500, 500), // You can adjust the size as needed
      painter: DirectionPainter(directions),
    );
  }
}

class DirectionPainter extends CustomPainter {
  final List<Direction> directions;

  DirectionPainter(this.directions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the circle
    canvas.drawCircle(center, radius, paint);

    // Draw the segments
    for (var i = 0; i < directions.length; i++) {
      final startAngle = 2 * i * pi / directions.length;
      final sweepAngle = 2 * pi / directions.length;

      paint.color = directions[i].hasLooked
          ? Colors.green
          : const Color.fromARGB(255, 250, 250, 250);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
