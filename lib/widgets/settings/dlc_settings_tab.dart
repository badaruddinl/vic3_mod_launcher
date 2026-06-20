import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'dlc_tile.dart';
import 'settings_toolbar_button.dart';

class DlcSettingsTab extends StatelessWidget {
  const DlcSettingsTab({
    super.key,
    required this.dlcs,
    required this.disabledDlcs,
    required this.onToggleDlc,
    required this.onEnableAllDlc,
  });

  final List<DlcInfo> dlcs;
  final Set<String> disabledDlcs;
  final ValueChanged<DlcInfo> onToggleDlc;
  final VoidCallback onEnableAllDlc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GildedPanel(
        title: 'DLC',
        trailing: SettingsToolbarButton(
          label: 'Enable all',
          icon: Icons.done_all,
          onPressed: onEnableAllDlc,
        ),
        child: dlcs.isEmpty
            ? const DlcEmptyState()
            : ListView.builder(
                itemCount: dlcs.length,
                itemBuilder: (context, index) {
                  final dlc = dlcs[index];
                  final enabled = !disabledDlcs.contains(dlc.ref.toLowerCase());
                  return DlcTile(
                    dlc: dlc,
                    enabled: enabled,
                    onToggle: onToggleDlc,
                  );
                },
              ),
      ),
    );
  }
}
