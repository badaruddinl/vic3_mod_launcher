import 'dart:math' as math;

import 'package:flutter/material.dart';

class VictoriaBackdropPainter extends CustomPainter {
  const VictoriaBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final rect = Offset.zero & size;

    final topGlow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x442b2117), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, topGlow);

    final haze = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xffd7b06f).withValues(alpha: 0.20),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.26, size.height * 0.28),
              radius: size.shortestSide * 0.55,
            ),
          );
    canvas.drawRect(Offset.zero & size, haze);

    paint.color = const Color(0x88060a0b);
    final skylineBase = size.height * 0.40;
    final farBase = size.height * 0.47;
    final rng = math.Random(7);
    for (var i = 0; i < 30; i++) {
      final x = size.width * (i / 29);
      final w = 10.0 + rng.nextDouble() * 26;
      final h = size.height * (0.08 + rng.nextDouble() * 0.16);
      canvas.drawRect(Rect.fromLTWH(x, farBase - h, w, h), paint);
      if (i % 4 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x + w * 0.35, farBase - h - 42, 6, 42),
          paint,
        );
      }
    }

    paint.color = const Color(0xaa05090a);
    for (var i = 0; i < 16; i++) {
      final x = size.width * (0.48 + i * 0.035);
      final w = 18.0 + rng.nextDouble() * 34;
      final h = size.height * (0.12 + rng.nextDouble() * 0.23);
      canvas.drawRect(Rect.fromLTWH(x, skylineBase - h, w, h), paint);
    }

    final domeCenter = Offset(size.width * 0.78, skylineBase - 96);
    canvas.drawOval(
      Rect.fromCenter(center: domeCenter, width: 118, height: 118),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(domeCenter.dx - 58, domeCenter.dy, 116, 128),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(domeCenter.dx - 7, domeCenter.dy - 72, 14, 78),
      paint,
    );

    final smokePaint = Paint()
      ..color = const Color(0x2ed9c09b)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    for (var i = 0; i < 7; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.10 + i * 0.075), 122 + i * 7),
          width: 80 + i * 8,
          height: 34 + i * 4,
        ),
        smokePaint,
      );
    }

    final mapPaint = Paint()
      ..color = const Color(0x2278522e)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.78 + i * 0.028);
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y + math.sin(i) * 16),
        mapPaint,
      );
    }
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.08 + i * 0.095);
      canvas.drawLine(
        Offset(x, size.height * 0.77),
        Offset(x + 40, size.height - 20),
        mapPaint,
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xdd020707)],
        stops: const [0.56, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
