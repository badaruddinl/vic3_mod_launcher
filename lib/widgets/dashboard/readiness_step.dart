import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ReadinessStep extends StatelessWidget {
  const ReadinessStep({super.key, required this.label, required this.last});

  final String label;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = last ? const Color(0xffffdf7c) : VicColors.tealBright;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: last ? const Color(0xff5b451c) : const Color(0xff064d48),
            border: Border.all(color: last ? VicColors.gold : color),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 12),
            ],
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              last ? Icons.star : Icons.check,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: last ? color : VicColors.parchment,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
