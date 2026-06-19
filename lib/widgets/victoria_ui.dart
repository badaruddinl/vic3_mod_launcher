import 'dart:math' as math;

import 'package:flutter/material.dart';

class VicColors {
  static const ink = Color(0xff071314);
  static const panel = Color(0xee0b1b1c);
  static const panelSoft = Color(0xcc102424);
  static const teal = Color(0xff064d48);
  static const tealBright = Color(0xff74d9c7);
  static const gold = Color(0xffd9ad6a);
  static const goldDark = Color(0xff78522e);
  static const parchment = Color(0xfff2dfc4);
  static const muted = Color(0xffbca98d);
  static const danger = Color(0xffd56f5f);
}

TextStyle vicTitle(BuildContext context, {double size = 32}) {
  return TextStyle(
    fontFamily: 'Georgia',
    fontSize: size,
    color: VicColors.parchment,
    height: 1.05,
    letterSpacing: 0,
    shadows: const [
      Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

TextStyle vicLabel(BuildContext context, {double size = 13}) {
  return TextStyle(
    fontSize: size,
    color: VicColors.gold,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
  );
}

class VictoriaShell extends StatelessWidget {
  const VictoriaShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1e211d), Color(0xff071314), Color(0xff031112)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: VictoriaBackdropPainter()),
          Padding(
            padding: const EdgeInsets.all(14),
            child: VictoriaFrame(child: child),
          ),
        ],
      ),
    );
  }
}

class VictoriaFrame extends StatelessWidget {
  const VictoriaFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xbb071314),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VicColors.goldDark, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 24, spreadRadius: 3),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xffc99454), width: 0.7),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GildedPanel extends StatelessWidget {
  const GildedPanel({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
  });

  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VicColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VicColors.goldDark),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || trailing != null) ...[
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!.toUpperCase(),
                        style: vicLabel(context, size: 13),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x5578522e)),
              const SizedBox(height: 12),
            ],
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class GildedButton extends StatelessWidget {
  const GildedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.large = false,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool large;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final height = large ? 74.0 : 46.0;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: secondary
                ? const [Color(0xff151b1c), Color(0xff202625)]
                : const [Color(0xff086259), Color(0xff06433e)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: VicColors.gold, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: VicColors.gold, size: large ? 28 : 20),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: large ? 31 : 17,
                      color: VicColors.parchment,
                      fontWeight: FontWeight.w600,
                      letterSpacing: large ? 5 : 0,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VictoriaBackdropPainter extends CustomPainter {
  const VictoriaBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final haze = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xffd7b06f).withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.23, size.height * 0.28),
              radius: size.shortestSide * 0.55,
            ),
          );
    canvas.drawRect(Offset.zero & size, haze);

    paint.color = const Color(0xaa05090a);
    final baseY = size.height * 0.72;
    final rng = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final x = size.width * (i / 25);
      final w = 12.0 + rng.nextDouble() * 30;
      final h = size.height * (0.10 + rng.nextDouble() * 0.22);
      canvas.drawRect(Rect.fromLTWH(x, baseY - h, w, h), paint);
      if (i % 4 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x + w * 0.35, baseY - h - 55, 7, 55),
          paint,
        );
      }
      if (i % 7 == 0) {
        canvas.drawCircle(Offset(x + w * 0.7, baseY - h - 35), 18, paint);
      }
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
