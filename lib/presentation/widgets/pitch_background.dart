import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Dark backdrop with mown-grass stripes and faint pitch markings.
class PitchBackground extends StatelessWidget {
  const PitchBackground({
    super.key,
    required this.child,
    this.glow = true,
    this.lineOpacity = 0.07,
  });

  final Widget child;

  /// Adds a stadium-light glow at the top. Disable under an opaque app bar.
  final bool glow;
  final double lineOpacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: glow
            ? RadialGradient(
                center: const Alignment(0, -1.1),
                radius: 1.3,
                colors: [
                  AppColors.pitch.withValues(alpha: 0.45),
                  AppColors.pitchDark.withValues(alpha: 0.35),
                  AppColors.background,
                ],
                stops: const [0, 0.45, 1],
              )
            : null,
      ),
      child: CustomPaint(
        painter: _PitchPainter(lineOpacity: lineOpacity),
        child: child,
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter({required this.lineOpacity});

  final double lineOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    // Grass stripes.
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.018);
    const bands = 12;
    final bandHeight = size.height / bands;
    for (var i = 0; i < bands; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * bandHeight, size.width, bandHeight),
        stripe,
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: lineOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final field = Rect.fromLTRB(20, 20, size.width - 20, size.height - 20);
    final center = field.center;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(field, const Radius.circular(6)),
        line,
      )
      ..drawLine(
        Offset(field.left, center.dy),
        Offset(field.right, center.dy),
        line,
      )
      ..drawCircle(center, field.width * 0.2, line)
      ..drawCircle(
        center,
        3.5,
        Paint()..color = Colors.white.withValues(alpha: lineOpacity * 1.5),
      );

    // Penalty and goal areas at both ends.
    final boxWidth = field.width * 0.62;
    final boxHeight = field.height * 0.13;
    final goalWidth = field.width * 0.3;
    final goalHeight = field.height * 0.05;
    final arcRadius = field.width * 0.13;

    for (final top in [true, false]) {
      final edge = top ? field.top : field.bottom;
      final dir = top ? 1.0 : -1.0;
      canvas
        ..drawRect(
          Rect.fromCenter(
            center: Offset(center.dx, edge + dir * boxHeight / 2),
            width: boxWidth,
            height: boxHeight,
          ),
          line,
        )
        ..drawRect(
          Rect.fromCenter(
            center: Offset(center.dx, edge + dir * goalHeight / 2),
            width: goalWidth,
            height: goalHeight,
          ),
          line,
        );

      // Penalty arc ("D") just outside the box.
      final spot = Offset(center.dx, edge + dir * boxHeight * 0.72);
      final sweep = math.pi * 0.42;
      canvas.drawArc(
        Rect.fromCircle(center: spot, radius: arcRadius),
        top ? (math.pi - sweep) / 2 : -(math.pi + sweep) / 2,
        sweep,
        false,
        line,
      );
    }
  }

  @override
  bool shouldRepaint(_PitchPainter oldDelegate) =>
      oldDelegate.lineOpacity != lineOpacity;
}
