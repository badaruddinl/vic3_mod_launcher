import 'package:flutter/material.dart';

import '../../services/launcher_config.dart';
import '../victoria_ui.dart';
import 'settings_lines.dart';
import 'settings_path_fields.dart';

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

class SettingsFoldersPanel extends StatelessWidget {
  const SettingsFoldersPanel({
    super.key,
    required this.config,
    required this.onPickGameRoot,
    required this.onPickUserData,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
  });

  final LauncherConfig config;
  final VoidCallback onPickGameRoot;
  final VoidCallback onPickUserData;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GildedPanel(
        title: 'Folders',
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            SettingsPathRow(
              icon: Icons.folder_open,
              title: 'Game Folder',
              subtitle: 'Path to your Victoria 3 installation.',
              value: config.gameRoot,
              onBrowse: onPickGameRoot,
            ),
            const Divider(color: Color(0x5578522e), height: 24),
            SettingsPathRow(
              icon: Icons.folder_copy_outlined,
              title: 'Data Folder',
              subtitle: 'Where mod data and configs are stored.',
              value: config.userDataPath,
              onBrowse: onPickUserData,
            ),
            const Divider(color: Color(0x5578522e), height: 24),
            ExtraModRootsRow(
              roots: config.extraModRoots,
              onAdd: onAddExtraRoot,
              onRemove: onRemoveExtraRoot,
            ),
          ],
        ),
      ),
    );
  }
}

class RepairPreferencesPanel extends StatelessWidget {
  const RepairPreferencesPanel({
    super.key,
    required this.autoRepair,
    required this.onAutoRepairChanged,
    required this.onAutoDetect,
    required this.onRefresh,
  });

  final bool autoRepair;
  final ValueChanged<bool> onAutoRepairChanged;
  final VoidCallback onAutoDetect;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      title: 'Repair',
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          SettingSwitchLine(
            title: 'Auto repair .mod descriptors',
            subtitle: 'Automatically fix common descriptor issues.',
            value: autoRepair,
            onChanged: onAutoRepairChanged,
          ),
          const Divider(color: Color(0x5578522e)),
          SettingActionLine(
            title: 'Auto Detect',
            subtitle: 'Scan common folders and shortcuts.',
            icon: Icons.radar_outlined,
            onPressed: onAutoDetect,
          ),
          const Divider(color: Color(0x5578522e)),
          SettingActionLine(
            title: 'Refresh',
            subtitle: 'Reload game, DLC, mods, and playsets.',
            icon: Icons.refresh,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class LaunchBehaviorPanel extends StatelessWidget {
  const LaunchBehaviorPanel({
    super.key,
    required this.debugMode,
    required this.onDebugModeChanged,
  });

  final bool debugMode;
  final ValueChanged<bool> onDebugModeChanged;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      title: 'Launch Behavior',
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          SettingSwitchLine(
            title: 'Start in debug mode',
            subtitle: 'Launch the game with -debug_mode.',
            value: debugMode,
            onChanged: onDebugModeChanged,
          ),
          const Divider(color: Color(0x5578522e)),
          const ComingSoonLine(
            title: 'Close launcher after game starts',
            subtitle: 'Planned for the next behavior pass.',
          ),
          const Divider(color: Color(0x5578522e)),
          const ComingSoonLine(
            title: 'Show compatibility warnings',
            subtitle: 'Warnings are currently always visible.',
          ),
        ],
      ),
    );
  }
}
