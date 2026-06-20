import 'package:flutter/material.dart';

import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';

class SettingsTabs extends StatelessWidget {
  const SettingsTabs({super.key, required this.controller});

  final TabController controller;

  static const _tabs = [
    _SettingsTabData('General', Icons.tune),
    _SettingsTabData('Mods', Icons.extension_outlined),
    _SettingsTabData('DLC', Icons.inventory_2_outlined),
    _SettingsTabData('Repair', Icons.construction_outlined),
    _SettingsTabData('Logs', Icons.subject_outlined),
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
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontFamily: 'Georgia', fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 11,
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
        Icon(tab.icon, size: 15),
        const SizedBox(width: 4),
        Flexible(child: EllipsisTooltipText(tab.label)),
      ],
    );
  }
}

class SettingsActionBar extends StatelessWidget {
  const SettingsActionBar({
    super.key,
    required this.onSavePlayset,
    required this.onSaveSettings,
  });

  final VoidCallback onSavePlayset;
  final VoidCallback onSaveSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: GildedButton(
                label: 'Playset',
                icon: Icons.save_outlined,
                secondary: true,
                onPressed: onSavePlayset,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GildedButton(
                label: 'Save',
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
