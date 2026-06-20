import 'package:flutter/material.dart';

import 'repair_action_card.dart';

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
