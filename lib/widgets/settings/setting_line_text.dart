import 'package:flutter/material.dart';

import '../common/ellipsis_tooltip_text.dart';
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllipsisTooltipText(
          title,
          style: const TextStyle(
            color: VicColors.parchment,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 3),
        EllipsisTooltipText(
          subtitle,
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
