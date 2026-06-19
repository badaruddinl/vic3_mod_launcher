import 'package:flutter/material.dart';

import '../models.dart';
import '../services/launcher_config.dart';
import '../widgets/settings/settings_shell_parts.dart';
import '../widgets/settings/settings_tab_body.dart';
import '../widgets/victoria_ui.dart';

class LauncherSettingsScreen extends StatefulWidget {
  const LauncherSettingsScreen({
    super.key,
    required this.config,
    required this.gameVersion,
    required this.mods,
    required this.availableModIds,
    required this.activeModIds,
    required this.selectedAvailable,
    required this.selectedActive,
    required this.validations,
    required this.dlcs,
    required this.disabledDlcs,
    required this.playsets,
    required this.onBack,
    required this.updateMenu,
    required this.onPickGameRoot,
    required this.onPickUserData,
    required this.onAutoDetect,
    required this.onRefresh,
    required this.onDiagnose,
    required this.onImportZip,
    required this.onRepair,
    required this.onRestoreBackup,
    required this.onSavePlayset,
    required this.onSavePlaysetAs,
    required this.onLoadPlayset,
    required this.onDeletePlayset,
    required this.onAutoRepairChanged,
    required this.onDebugModeChanged,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
    required this.onAvailableTap,
    required this.onActiveTap,
    required this.onActiveReorder,
    required this.onEnable,
    required this.onDisable,
    required this.onUp,
    required this.onDown,
    required this.onTop,
    required this.onBottom,
    required this.onToggleDlc,
    required this.onEnableAllDlc,
  });

  final LauncherConfig config;
  final String gameVersion;
  final Map<String, ModInfo> mods;
  final List<String> availableModIds;
  final List<String> activeModIds;
  final Set<String> selectedAvailable;
  final Set<String> selectedActive;
  final Map<String, ModValidation> validations;
  final List<DlcInfo> dlcs;
  final Set<String> disabledDlcs;
  final List<SavedPlayset> playsets;
  final VoidCallback onBack;
  final Widget updateMenu;
  final VoidCallback onPickGameRoot;
  final VoidCallback onPickUserData;
  final VoidCallback onAutoDetect;
  final VoidCallback onRefresh;
  final VoidCallback onDiagnose;
  final VoidCallback onImportZip;
  final VoidCallback onRepair;
  final VoidCallback onRestoreBackup;
  final VoidCallback onSavePlayset;
  final VoidCallback onSavePlaysetAs;
  final ValueChanged<SavedPlayset> onLoadPlayset;
  final ValueChanged<SavedPlayset> onDeletePlayset;
  final ValueChanged<bool> onAutoRepairChanged;
  final ValueChanged<bool> onDebugModeChanged;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;
  final ValueChanged<String> onAvailableTap;
  final ValueChanged<String> onActiveTap;
  final void Function(int oldIndex, int newIndex) onActiveReorder;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onTop;
  final VoidCallback onBottom;
  final ValueChanged<DlcInfo> onToggleDlc;
  final VoidCallback onEnableAllDlc;

  @override
  State<LauncherSettingsScreen> createState() => _LauncherSettingsScreenState();
}

class _LauncherSettingsScreenState extends State<LauncherSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VictoriaShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
        child: Column(
          children: [
            VictoriaTitleBar(
              leading: VictoriaIconButton(
                icon: Icons.arrow_back,
                tooltip: 'Back',
                onPressed: widget.onBack,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.updateMenu,
                  const SizedBox(width: 14),
                  const VictoriaWindowButtons(),
                ],
              ),
            ),
            VictoriaHeaderMark(gameVersion: widget.gameVersion, compact: true),
            const SizedBox(height: 12),
            SettingsTabs(controller: controller),
            Expanded(
              child: SettingsTabBody(
                controller: controller,
                config: widget.config,
                mods: widget.mods,
                availableModIds: widget.availableModIds,
                activeModIds: widget.activeModIds,
                selectedAvailable: widget.selectedAvailable,
                selectedActive: widget.selectedActive,
                validations: widget.validations,
                dlcs: widget.dlcs,
                disabledDlcs: widget.disabledDlcs,
                playsets: widget.playsets,
                onPickGameRoot: widget.onPickGameRoot,
                onPickUserData: widget.onPickUserData,
                onAutoDetect: widget.onAutoDetect,
                onRefresh: widget.onRefresh,
                onAddExtraRoot: widget.onAddExtraRoot,
                onRemoveExtraRoot: widget.onRemoveExtraRoot,
                onAutoRepairChanged: widget.onAutoRepairChanged,
                onDebugModeChanged: widget.onDebugModeChanged,
                onAvailableTap: widget.onAvailableTap,
                onActiveTap: widget.onActiveTap,
                onActiveReorder: widget.onActiveReorder,
                onEnable: widget.onEnable,
                onDisable: widget.onDisable,
                onUp: widget.onUp,
                onDown: widget.onDown,
                onTop: widget.onTop,
                onBottom: widget.onBottom,
                onSavePlayset: widget.onSavePlayset,
                onSavePlaysetAs: widget.onSavePlaysetAs,
                onLoadPlayset: widget.onLoadPlayset,
                onDeletePlayset: widget.onDeletePlayset,
                onImportZip: widget.onImportZip,
                onToggleDlc: widget.onToggleDlc,
                onEnableAllDlc: widget.onEnableAllDlc,
                onDiagnose: widget.onDiagnose,
                onRepair: widget.onRepair,
                onRestoreBackup: widget.onRestoreBackup,
              ),
            ),
            const SizedBox(height: 14),
            SettingsActionBar(
              onBack: widget.onBack,
              onSavePlayset: widget.onSavePlayset,
              onSaveSettings: widget.onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
