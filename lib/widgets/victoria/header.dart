import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaHeaderMark extends StatelessWidget {
  const VictoriaHeaderMark({
    super.key,
    required this.gameVersion,
    this.compact = false,
  });

  final String gameVersion;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 58.0 : 70.0;
    final titleSize = compact ? 29.0 : 34.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: iconSize,
          width: iconSize,
          child: Image.asset('assets/brand/app_icon_256.png'),
        ),
        SizedBox(height: compact ? 3 : 5),
        Text(
          'Victoria 3 Mod Launcher',
          style: vicTitle(context, size: titleSize),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xff063f3b),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VicColors.gold),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Text(
              gameVersion.isEmpty ? 'unknown' : 'v$gameVersion',
              style: const TextStyle(
                color: VicColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
