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
    decoration: TextDecoration.none,
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
    decoration: TextDecoration.none,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
  );
}
