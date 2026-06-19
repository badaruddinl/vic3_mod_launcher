import 'package:flutter/material.dart';

import 'settings_toolbar_button.dart';

class ModsToolbar extends StatelessWidget {
  const ModsToolbar({
    super.key,
    required this.onImportZip,
    required this.onSavePlaysetAs,
    required this.onSavePlayset,
  });

  final VoidCallback onImportZip;
  final VoidCallback onSavePlaysetAs;
  final VoidCallback onSavePlayset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          SettingsToolbarButton(
            label: 'Import ZIP',
            icon: Icons.archive_outlined,
            onPressed: onImportZip,
          ),
          SettingsToolbarButton(
            label: 'Save As',
            icon: Icons.save_as_outlined,
            onPressed: onSavePlaysetAs,
          ),
          SettingsToolbarButton(
            label: 'Save Current',
            icon: Icons.save_outlined,
            primary: true,
            onPressed: onSavePlayset,
          ),
        ],
      ),
    );
  }
}
