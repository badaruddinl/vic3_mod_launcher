import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/launcher_config.dart';
import '../victoria_ui.dart';
import 'dlc_settings_tab.dart';
import 'general_settings_tab.dart';
import 'logs_settings_tab.dart';
import 'mods_settings_tab.dart';
import 'repair_settings_tab.dart';

class SettingsTabBody extends StatelessWidget {
  const SettingsTabBody({
    super.key,
    required this.controller,
    required this.config,
    required this.mods,
    required this.availableModIds,
    required this.activeModIds,
    required this.selectedAvailable,
    required this.selectedActive,
    required this.validations,
    required this.dlcs,
    required this.disabledDlcs,
    required this.playsets,
    required this.logs,
    required this.onPickGameRoot,
    required this.onPickUserData,
    required this.onAutoDetect,
    required this.onRefresh,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
    required this.onAutoRepairChanged,
    required this.onDebugModeChanged,
    required this.onAvailableTap,
    required this.onActiveTap,
    required this.onActiveReorder,
    required this.onEnable,
    required this.onDisable,
    required this.onUp,
    required this.onDown,
    required this.onTop,
    required this.onBottom,
    required this.onSavePlayset,
    required this.onSavePlaysetAs,
    required this.onLoadPlayset,
    required this.onDeletePlayset,
    required this.onImportZip,
    required this.onToggleDlc,
    required this.onEnableAllDlc,
    required this.onDiagnose,
    required this.onRepair,
    required this.onRestoreBackup,
  });

  final TabController controller;
  final LauncherConfig config;
  final Map<String, ModInfo> mods;
  final List<String> availableModIds;
  final List<String> activeModIds;
  final Set<String> selectedAvailable;
  final Set<String> selectedActive;
  final Map<String, ModValidation> validations;
  final List<DlcInfo> dlcs;
  final Set<String> disabledDlcs;
  final List<SavedPlayset> playsets;
  final List<String> logs;
  final VoidCallback onPickGameRoot;
  final VoidCallback onPickUserData;
  final VoidCallback onAutoDetect;
  final VoidCallback onRefresh;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;
  final ValueChanged<bool> onAutoRepairChanged;
  final ValueChanged<bool> onDebugModeChanged;
  final ValueChanged<String> onAvailableTap;
  final ValueChanged<String> onActiveTap;
  final void Function(int oldIndex, int newIndex) onActiveReorder;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onTop;
  final VoidCallback onBottom;
  final VoidCallback onSavePlayset;
  final VoidCallback onSavePlaysetAs;
  final ValueChanged<SavedPlayset> onLoadPlayset;
  final ValueChanged<SavedPlayset> onDeletePlayset;
  final VoidCallback onImportZip;
  final ValueChanged<DlcInfo> onToggleDlc;
  final VoidCallback onEnableAllDlc;
  final VoidCallback onDiagnose;
  final VoidCallback onRepair;
  final VoidCallback onRestoreBackup;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VicColors.panel,
        border: Border.all(color: VicColors.goldDark),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: TabBarView(
        controller: controller,
        children: [
          GeneralSettingsTab(
            config: config,
            onPickGameRoot: onPickGameRoot,
            onPickUserData: onPickUserData,
            onAutoDetect: onAutoDetect,
            onAddExtraRoot: onAddExtraRoot,
            onRemoveExtraRoot: onRemoveExtraRoot,
            onAutoRepairChanged: onAutoRepairChanged,
            onDebugModeChanged: onDebugModeChanged,
          ),
          ModsSettingsTab(
            mods: mods,
            availableModIds: availableModIds,
            activeModIds: activeModIds,
            selectedAvailable: selectedAvailable,
            selectedActive: selectedActive,
            validations: validations,
            playsets: playsets,
            onAvailableTap: onAvailableTap,
            onActiveTap: onActiveTap,
            onActiveReorder: onActiveReorder,
            onEnable: onEnable,
            onDisable: onDisable,
            onUp: onUp,
            onDown: onDown,
            onTop: onTop,
            onBottom: onBottom,
            onSavePlayset: onSavePlayset,
            onSavePlaysetAs: onSavePlaysetAs,
            onLoadPlayset: onLoadPlayset,
            onDeletePlayset: onDeletePlayset,
            onImportZip: onImportZip,
          ),
          DlcSettingsTab(
            dlcs: dlcs,
            disabledDlcs: disabledDlcs,
            onToggleDlc: onToggleDlc,
            onEnableAllDlc: onEnableAllDlc,
          ),
          RepairSettingsTab(
            onDiagnose: onDiagnose,
            onRepair: onRepair,
            onRestoreBackup: onRestoreBackup,
            onRefresh: onRefresh,
            onAutoDetect: onAutoDetect,
          ),
          LogsSettingsTab(logs: logs),
        ],
      ),
    );
  }
}
