import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingSwitchLine extends StatelessWidget {
  const SettingSwitchLine({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class SettingActionLine extends StatelessWidget {
  const SettingActionLine({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: VicColors.gold),
            const SizedBox(width: 11),
            Expanded(
              child: SettingLineText(title: title, subtitle: subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonLine extends StatelessWidget {
  const ComingSoonLine({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
          const Icon(Icons.lock_outline, color: VicColors.muted),
        ],
      ),
    );
  }
}

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
