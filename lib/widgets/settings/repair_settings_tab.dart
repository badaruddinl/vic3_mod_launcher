import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class RepairSettingsTab extends StatelessWidget {
  const RepairSettingsTab({
    super.key,
    required this.onDiagnose,
    required this.onRepair,
    required this.onRestoreBackup,
    required this.onRefresh,
    required this.onAutoDetect,
  });

  final VoidCallback onDiagnose;
  final VoidCallback onRepair;
  final VoidCallback onRestoreBackup;
  final VoidCallback onRefresh;
  final VoidCallback onAutoDetect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          RepairActionCard(
            icon: Icons.bug_report_outlined,
            title: 'Diagnose',
            body:
                'Check paths, descriptors, active mods, and content_load.json.',
            onPressed: onDiagnose,
          ),
          RepairActionCard(
            icon: Icons.build_outlined,
            title: 'Repair Descriptors',
            body: 'Generate missing .mod files and descriptor.mod fields.',
            onPressed: onRepair,
          ),
          RepairActionCard(
            icon: Icons.restore_page_outlined,
            title: 'Restore Backup',
            body: 'Restore the last content_load.json backup.',
            onPressed: onRestoreBackup,
          ),
          RepairActionCard(
            icon: Icons.radar_outlined,
            title: 'Auto Detect',
            body: 'Detect game and data folders again.',
            onPressed: onAutoDetect,
          ),
          RepairActionCard(
            icon: Icons.refresh,
            title: 'Refresh',
            body: 'Re-scan all local content.',
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

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
          Icon(icon, color: VicColors.gold, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: VicColors.parchment,
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
            ),
          ),
          FilledButton(onPressed: onPressed, child: const Text('Run')),
        ],
      ),
    );
  }
}
