import 'package:flutter/material.dart';

import '../../services/launcher_config.dart';
import 'general_settings_panels.dart';

class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({
    super.key,
    required this.config,
    required this.onPickGameRoot,
    required this.onPickUserData,
    required this.onAutoDetect,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
    required this.onAutoRepairChanged,
    required this.onDebugModeChanged,
  });

  final LauncherConfig config;
  final VoidCallback onPickGameRoot;
  final VoidCallback onPickUserData;
  final VoidCallback onAutoDetect;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;
  final ValueChanged<bool> onAutoRepairChanged;
  final ValueChanged<bool> onDebugModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          SizedBox(
            height: 242,
            child: SettingsFoldersPanel(
              config: config,
              onPickGameRoot: onPickGameRoot,
              onPickUserData: onPickUserData,
              onAddExtraRoot: onAddExtraRoot,
              onRemoveExtraRoot: onRemoveExtraRoot,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 146,
            child: GeneralPreferencesPanel(
              autoRepair: config.autoRepair,
              debugMode: config.debugMode,
              onAutoRepairChanged: onAutoRepairChanged,
              onDebugModeChanged: onDebugModeChanged,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: AutoDetectPanel(onAutoDetect: onAutoDetect)),
        ],
      ),
    );
  }
}
