import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingsTabs extends StatelessWidget {
  const SettingsTabs({super.key, required this.controller});

  final TabController controller;

  static const _tabs = [
    _SettingsTabData('General', Icons.tune),
    _SettingsTabData('Mods', Icons.extension_outlined),
    _SettingsTabData('DLC', Icons.inventory_2_outlined),
    _SettingsTabData('Repair', Icons.construction_outlined),
  ];

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
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff123130), Color(0xff071b1c)],
          ),
          border: Border.all(color: VicColors.gold, width: 1.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        labelColor: VicColors.gold,
        unselectedLabelColor: VicColors.muted,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontFamily: 'Georgia', fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 15,
        ),
        tabs: _tabs
            .map((tab) => Tab(height: 50, child: _SettingsTabLabel(tab: tab)))
            .toList(growable: false),
      ),
    );
  }
}

class _SettingsTabData {
  const _SettingsTabData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SettingsTabLabel extends StatelessWidget {
  const _SettingsTabLabel({required this.tab});

  final _SettingsTabData tab;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(tab.icon, size: 17),
        const SizedBox(width: 7),
        Flexible(
          child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        return Row(
          children: [
            SizedBox(
              width: compact ? 126 : 150,
              child: GildedButton(
                label: 'Back',
                icon: Icons.chevron_left,
                secondary: true,
                onPressed: onBack,
              ),
            ),
            SizedBox(width: compact ? 10 : 14),
            SizedBox(
              width: compact ? 164 : 190,
              child: GildedButton(
                label: 'Save Playset',
                icon: Icons.save_outlined,
                secondary: true,
                onPressed: onSavePlayset,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: compact ? 184 : 214,
              child: GildedButton(
                label: 'Save Settings',
                icon: Icons.verified_outlined,
                onPressed: onSaveSettings,
              ),
            ),
          ],
        );
      },
    );
  }
}
