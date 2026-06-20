import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingLineText extends StatelessWidget {
  const SettingLineText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: VicColors.parchment,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: VicColors.muted,
            fontSize: 11.5,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
