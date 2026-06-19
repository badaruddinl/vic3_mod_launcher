import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingsTabs extends StatelessWidget {
  const SettingsTabs({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xdd091819),
        border: Border.all(color: VicColors.goldDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xff102827),
          border: Border.all(color: VicColors.gold),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        labelColor: VicColors.gold,
        unselectedLabelColor: VicColors.muted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Mods'),
          Tab(text: 'DLC'),
          Tab(text: 'Repair'),
        ],
      ),
    );
  }
}

class SettingsActionBar extends StatelessWidget {
  const SettingsActionBar({
    super.key,
    required this.onBack,
    required this.onSavePlayset,
    required this.onSaveSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onSavePlayset;
  final VoidCallback onSaveSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: GildedButton(
            label: 'Back',
            icon: Icons.chevron_left,
            secondary: true,
            onPressed: onBack,
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 190,
          child: GildedButton(
            label: 'Save Playset',
            icon: Icons.save_outlined,
            secondary: true,
            onPressed: onSavePlayset,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 214,
          child: GildedButton(
            label: 'Save Settings',
            icon: Icons.verified_outlined,
            onPressed: onSaveSettings,
          ),
        ),
      ],
    );
  }
}
