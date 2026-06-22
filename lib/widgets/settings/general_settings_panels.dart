import 'package:flutter/material.dart';

import '../../services/launcher_config.dart';
import '../victoria_ui.dart';
import 'setting_line_shell.dart';
import 'setting_line_text.dart';
import 'settings_lines.dart';
import 'settings_path_fields.dart';
import 'settings_toolbar_button.dart';
import 'victoria_toggle.dart';

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
      height: 242,
      child: GildedPanel(
        title: 'Folders',
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            SettingsPathRow(
              icon: Icons.folder_open,
              title: 'Game Folder',
              subtitle: 'Path to your Victoria 3 installation.',
              value: config.gameRoot,
              onBrowse: onPickGameRoot,
            ),
            const Divider(color: Color(0x5578522e), height: 16),
            SettingsPathRow(
              icon: Icons.folder_copy_outlined,
              title: 'Data Folder',
              subtitle: 'Where mod data and configs are stored.',
              value: config.userDataPath,
              onBrowse: onPickUserData,
            ),
            const Divider(color: Color(0x5578522e), height: 16),
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

class GeneralPreferencesPanel extends StatelessWidget {
  const GeneralPreferencesPanel({
    super.key,
    required this.autoRepair,
    required this.debugMode,
    required this.onAutoRepairChanged,
    required this.onDebugModeChanged,
  });

  final bool autoRepair;
  final bool debugMode;
  final ValueChanged<bool> onAutoRepairChanged;
  final ValueChanged<bool> onDebugModeChanged;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      title: 'Launcher',
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          _CompactSwitchLine(
            title: 'Auto repair descriptors',
            subtitle: 'Fix common .mod issues before launch.',
            value: autoRepair,
            onChanged: onAutoRepairChanged,
          ),
          const Divider(color: Color(0x5578522e), height: 8),
          _CompactSwitchLine(
            title: 'Debug mode',
            subtitle: 'Launch Victoria 3 with -debug_mode.',
            value: debugMode,
            onChanged: onDebugModeChanged,
          ),
        ],
      ),
    );
  }
}

class _CompactSwitchLine extends StatelessWidget {
  const _CompactSwitchLine({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SettingLineText(title: title, subtitle: subtitle),
        ),
        const SizedBox(width: 10),
        VictoriaToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

class AutoDetectPanel extends StatelessWidget {
  const AutoDetectPanel({super.key, required this.onAutoDetect});

  final VoidCallback onAutoDetect;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      title: 'Auto Detect',
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Center(
        child: Row(
          children: [
            const SettingLineIcon(icon: Icons.radar_outlined),
            const SizedBox(width: 12),
            const Expanded(
              child: SettingLineText(
                title: 'Find local paths',
                subtitle: 'Scan common folders and desktop shortcuts.',
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 132,
              height: 42,
              child: SettingsToolbarButton(
                label: 'Detect',
                icon: Icons.play_arrow,
                primary: true,
                onPressed: onAutoDetect,
              ),
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
