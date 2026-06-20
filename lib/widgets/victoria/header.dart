import 'package:flutter/material.dart';

import 'header_logo_mark.dart';
import 'header_ornament.dart';
import 'theme.dart';
import 'version_badge.dart';

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
    final ornamentWidth = compact ? 210.0 : 260.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VictoriaLogoMark(size: iconSize),
        SizedBox(height: compact ? 3 : 5),
        VictoriaHeaderOrnament(width: ornamentWidth),
        const SizedBox(height: 4),
        Text(
          'Victoria 3 Mod Launcher',
          style: vicTitle(context, size: titleSize),
        ),
        const SizedBox(height: 7),
        VictoriaVersionBadge(version: gameVersion),
      ],
    );
  }
}
