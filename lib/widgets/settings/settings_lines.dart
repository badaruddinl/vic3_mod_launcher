import 'package:flutter/material.dart';

import 'setting_line_shell.dart';
import 'setting_line_text.dart';
import 'settings_toolbar_button.dart';
import 'victoria_toggle.dart';

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
    return SettingLineShell(
      child: Row(
        children: [
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
          VictoriaToggle(value: value, onChanged: onChanged),
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
    return SettingLineShell(
      onTap: onPressed,
      child: Row(
        children: [
          SettingLineIcon(icon: icon),
          const SizedBox(width: 11),
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
        ],
      ),
    );
  }
}

class SettingButtonLine extends StatelessWidget {
  const SettingButtonLine({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SettingLineShell(
      child: Row(
        children: [
          SettingLineIcon(icon: icon),
          const SizedBox(width: 11),
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
          const SizedBox(width: 10),
          SettingsToolbarButton(
            label: buttonLabel,
            icon: Icons.play_arrow,
            primary: true,
            onPressed: onPressed,
          ),
        ],
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
    return SettingLineShell(
      child: Row(
        children: [
          Expanded(
            child: SettingLineText(title: title, subtitle: subtitle),
          ),
          const SettingLineIcon(icon: Icons.lock_outline, muted: true),
        ],
      ),
    );
  }
}
