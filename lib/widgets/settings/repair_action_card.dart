import 'package:flutter/material.dart';

import '../victoria_ui.dart';
import 'settings_toolbar_button.dart';

class RepairActionCard extends StatelessWidget {
  const RepairActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          RepairActionIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: RepairActionText(title: title, body: body),
          ),
          const SizedBox(width: 12),
          SettingsToolbarButton(
            label: 'Run',
            icon: Icons.play_arrow,
            primary: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class RepairActionIcon extends StatelessWidget {
  const RepairActionIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x55064d48),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: VicColors.goldDark),
      ),
      child: SizedBox.square(
        dimension: 46,
        child: Icon(icon, color: VicColors.gold, size: 28),
      ),
    );
  }
}

class RepairActionText extends StatelessWidget {
  const RepairActionText({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: VicColors.parchment,
            fontFamily: 'Georgia',
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
