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
    required this.onRefresh,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
    required this.onAutoRepairChanged,
    required this.onDebugModeChanged,
  });

  final LauncherConfig config;
  final VoidCallback onPickGameRoot;
  final VoidCallback onPickUserData;
  final VoidCallback onAutoDetect;
  final VoidCallback onRefresh;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;
  final ValueChanged<bool> onAutoRepairChanged;
  final ValueChanged<bool> onDebugModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          SettingsFoldersPanel(
            config: config,
            onPickGameRoot: onPickGameRoot,
            onPickUserData: onPickUserData,
            onAddExtraRoot: onAddExtraRoot,
            onRemoveExtraRoot: onRemoveExtraRoot,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: RepairPreferencesPanel(
                    autoRepair: config.autoRepair,
                    onAutoRepairChanged: onAutoRepairChanged,
                    onAutoDetect: onAutoDetect,
                    onRefresh: onRefresh,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LaunchBehaviorPanel(
                    debugMode: config.debugMode,
                    onDebugModeChanged: onDebugModeChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
