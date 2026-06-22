import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaVersionBadge extends StatelessWidget {
  const VictoriaVersionBadge({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff063f3b),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VicColors.gold),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Text(
          version.isEmpty ? 'unknown' : 'v$version',
          style: const TextStyle(
            color: VicColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
