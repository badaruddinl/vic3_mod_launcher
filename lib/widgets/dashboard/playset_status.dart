import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class PlaysetStatus extends StatelessWidget {
  const PlaysetStatus({
    super.key,
    required this.title,
    required this.detail,
    required this.hasErrors,
  });

  final String title;
  final String detail;
  final bool hasErrors;

  @override
  Widget build(BuildContext context) {
    final color = hasErrors ? VicColors.danger : VicColors.tealBright;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasErrors ? Icons.error_outline : Icons.circle,
              color: color,
              size: 15,
            ),
            const SizedBox(width: 12),
            Flexible(child: Text(title, style: vicTitle(context, size: 25))),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VicColors.parchment,
            fontSize: 13,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
