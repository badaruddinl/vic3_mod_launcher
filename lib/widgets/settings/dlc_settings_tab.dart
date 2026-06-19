import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

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
        trailing: TextButton(
          onPressed: onEnableAllDlc,
          child: const Text('Enable all'),
        ),
        child: ListView.builder(
          itemCount: dlcs.length,
          itemBuilder: (context, index) {
            final dlc = dlcs[index];
            final enabled = !disabledDlcs.contains(dlc.ref.toLowerCase());
            return CheckboxListTile(
              value: enabled,
              onChanged: (_) => onToggleDlc(dlc),
              title: Text(
                dlc.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                dlc.ref,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }
}
