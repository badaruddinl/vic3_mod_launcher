import 'package:flutter/material.dart';

import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';

class SettingsRowLabel extends StatelessWidget {
  const SettingsRowLabel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.width = 220,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: VicColors.gold, size: 30),
        const SizedBox(width: 14),
        SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EllipsisTooltipText(
                title,
                style: const TextStyle(
                  color: VicColors.parchment,
                  fontFamily: 'Georgia',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              EllipsisTooltipText(
                subtitle,
                style: const TextStyle(color: VicColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
