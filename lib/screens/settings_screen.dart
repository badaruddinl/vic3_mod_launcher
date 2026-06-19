import 'package:flutter/material.dart';

import '../models.dart';
import '../services/launcher_config.dart';
import '../widgets/mod_manager.dart';
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
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
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
                  const SizedBox(width: 18),
                  const VictoriaWindowButtons(),
                ],
              ),
            ),
            VictoriaHeaderMark(gameVersion: widget.gameVersion, compact: true),
            const SizedBox(height: 16),
            _Tabs(controller: controller),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: VicColors.panel,
                  border: Border.all(color: VicColors.goldDark),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: TabBarView(
                  controller: controller,
                  children: [
                    _GeneralTab(
                      config: widget.config,
                      onPickGameRoot: widget.onPickGameRoot,
                      onPickUserData: widget.onPickUserData,
                      onAutoDetect: widget.onAutoDetect,
                      onRefresh: widget.onRefresh,
                      onAddExtraRoot: widget.onAddExtraRoot,
                      onRemoveExtraRoot: widget.onRemoveExtraRoot,
                      onAutoRepairChanged: widget.onAutoRepairChanged,
                      onDebugModeChanged: widget.onDebugModeChanged,
                    ),
                    _ModsTab(
                      mods: widget.mods,
                      availableModIds: widget.availableModIds,
                      activeModIds: widget.activeModIds,
                      selectedAvailable: widget.selectedAvailable,
                      selectedActive: widget.selectedActive,
                      validations: widget.validations,
                      playsets: widget.playsets,
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
                    ),
                    _DlcTab(
                      dlcs: widget.dlcs,
                      disabledDlcs: widget.disabledDlcs,
                      onToggleDlc: widget.onToggleDlc,
                      onEnableAllDlc: widget.onEnableAllDlc,
                    ),
                    _RepairTab(
                      onDiagnose: widget.onDiagnose,
                      onRepair: widget.onRepair,
                      onRestoreBackup: widget.onRestoreBackup,
                      onRefresh: widget.onRefresh,
                      onAutoDetect: widget.onAutoDetect,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 180,
                  child: GildedButton(
                    label: 'Back',
                    icon: Icons.chevron_left,
                    secondary: true,
                    onPressed: widget.onBack,
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 220,
                  child: GildedButton(
                    label: 'Save Playset',
                    icon: Icons.save_outlined,
                    secondary: true,
                    onPressed: widget.onSavePlayset,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  child: GildedButton(
                    label: 'Save Settings',
                    icon: Icons.verified_outlined,
                    onPressed: widget.onRefresh,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xdd091819),
        border: Border.all(color: VicColors.goldDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xff102827),
          border: Border.all(color: VicColors.gold),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        labelColor: VicColors.gold,
        unselectedLabelColor: VicColors.muted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Mods'),
          Tab(text: 'DLC'),
          Tab(text: 'Repair'),
        ],
      ),
    );
  }
}

class _GeneralTab extends StatelessWidget {
  const _GeneralTab({
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
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          SizedBox(
            height: 330,
            child: GildedPanel(
              title: 'Folders',
              child: Column(
                children: [
                  _PathRow(
                    icon: Icons.folder_open,
                    title: 'Game Folder',
                    subtitle: 'Path to your Victoria 3 installation.',
                    value: config.gameRoot,
                    onBrowse: onPickGameRoot,
                  ),
                  const Divider(color: Color(0x5578522e), height: 28),
                  _PathRow(
                    icon: Icons.folder_copy_outlined,
                    title: 'Data Folder',
                    subtitle: 'Where mod data and configs are stored.',
                    value: config.userDataPath,
                    onBrowse: onPickUserData,
                  ),
                  const Divider(color: Color(0x5578522e), height: 28),
                  _ExtraRoots(
                    roots: config.extraModRoots,
                    onAdd: onAddExtraRoot,
                    onRemove: onRemoveExtraRoot,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GildedPanel(
                    title: 'Repair',
                    child: Column(
                      children: [
                        _SwitchLine(
                          title: 'Auto repair .mod descriptors',
                          subtitle:
                              'Automatically fix common descriptor issues.',
                          value: config.autoRepair,
                          onChanged: onAutoRepairChanged,
                        ),
                        const Divider(color: Color(0x5578522e)),
                        _ActionLine(
                          title: 'Auto Detect',
                          subtitle:
                              'Scan common folders and desktop shortcuts.',
                          icon: Icons.radar_outlined,
                          onPressed: onAutoDetect,
                        ),
                        const Divider(color: Color(0x5578522e)),
                        _ActionLine(
                          title: 'Refresh',
                          subtitle: 'Reload game, DLC, mods, and playsets.',
                          icon: Icons.refresh,
                          onPressed: onRefresh,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: GildedPanel(
                    title: 'Launch Behavior',
                    child: Column(
                      children: [
                        _SwitchLine(
                          title: 'Start in debug mode',
                          subtitle: 'Launch the game with -debug_mode.',
                          value: config.debugMode,
                          onChanged: onDebugModeChanged,
                        ),
                        const Divider(color: Color(0x5578522e)),
                        const _ComingSoonLine(
                          title: 'Close launcher after game starts',
                          subtitle:
                              'Planned setting for the next behavior pass.',
                        ),
                        const Divider(color: Color(0x5578522e)),
                        const _ComingSoonLine(
                          title: 'Show compatibility warnings',
                          subtitle: 'Warnings are currently always visible.',
                        ),
                      ],
                    ),
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

class _ModsTab extends StatelessWidget {
  const _ModsTab({
    required this.mods,
    required this.availableModIds,
    required this.activeModIds,
    required this.selectedAvailable,
    required this.selectedActive,
    required this.validations,
    required this.playsets,
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
  });

  final Map<String, ModInfo> mods;
  final List<String> availableModIds;
  final List<String> activeModIds;
  final Set<String> selectedAvailable;
  final Set<String> selectedActive;
  final Map<String, ModValidation> validations;
  final List<SavedPlayset> playsets;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: onImportZip,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Import ZIP'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onSavePlaysetAs,
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('Save As'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onSavePlayset,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Current'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ModManager(
            mods: mods,
            availableIds: availableModIds,
            activeIds: activeModIds,
            selectedAvailable: selectedAvailable,
            selectedActive: selectedActive,
            validations: validations,
            onAvailableTap: onAvailableTap,
            onActiveTap: onActiveTap,
            onActiveReorder: onActiveReorder,
            onEnable: onEnable,
            onDisable: onDisable,
            onUp: onUp,
            onDown: onDown,
            onTop: onTop,
            onBottom: onBottom,
          ),
        ),
        SizedBox(
          height: 126,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: GildedPanel(
              title: 'Saved playsets',
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final playset in playsets)
                    SizedBox(
                      width: 250,
                      child: ListTile(
                        title: Text(
                          playset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          playset.modifiedAt.toLocal().toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onLoadPlayset(playset),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDeletePlayset(playset),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DlcTab extends StatelessWidget {
  const _DlcTab({
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
      padding: const EdgeInsets.all(22),
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

class _RepairTab extends StatelessWidget {
  const _RepairTab({
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
      padding: const EdgeInsets.all(22),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        children: [
          _RepairAction(
            icon: Icons.bug_report_outlined,
            title: 'Diagnose',
            body:
                'Check paths, descriptors, active mods, and content_load.json.',
            onPressed: onDiagnose,
          ),
          _RepairAction(
            icon: Icons.build_outlined,
            title: 'Repair Descriptors',
            body: 'Generate missing .mod files and descriptor.mod fields.',
            onPressed: onRepair,
          ),
          _RepairAction(
            icon: Icons.restore_page_outlined,
            title: 'Restore Backup',
            body: 'Restore the last content_load.json backup.',
            onPressed: onRestoreBackup,
          ),
          _RepairAction(
            icon: Icons.radar_outlined,
            title: 'Auto Detect',
            body: 'Detect game and data folders again.',
            onPressed: onAutoDetect,
          ),
          _RepairAction(
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

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onBrowse,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: VicColors.gold, size: 32),
        const SizedBox(width: 16),
        SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: VicColors.parchment,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: VicColors.muted)),
            ],
          ),
        ),
        Expanded(child: _PathValue(value: value)),
        const SizedBox(width: 10),
        IconButton.outlined(
          onPressed: onBrowse,
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Browse',
        ),
      ],
    );
  }
}

class _PathValue extends StatelessWidget {
  const _PathValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff0b1718),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: VicColors.goldDark),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          value.isEmpty ? 'Not set' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.parchment),
        ),
      ),
    );
  }
}

class _ExtraRoots extends StatelessWidget {
  const _ExtraRoots({
    required this.roots,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> roots;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.create_new_folder_outlined,
          color: VicColors.gold,
          size: 32,
        ),
        const SizedBox(width: 16),
        const SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Mod Folders',
                style: TextStyle(color: VicColors.parchment, fontSize: 18),
              ),
              SizedBox(height: 3),
              Text(
                'Scan extra folders for mods.',
                style: TextStyle(color: VicColors.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xff0b1718),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: VicColors.goldDark),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (roots.isEmpty)
                    const Text(
                      'No additional folders added.',
                      style: TextStyle(color: VicColors.muted),
                    ),
                  for (final root in roots)
                    ListTile(
                      dense: true,
                      title: Text(
                        root,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => onRemove(root),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Folder'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchLine extends StatelessWidget {
  const _SwitchLine({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VicColors.parchment,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: VicColors.muted,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.86,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _ActionLine extends StatelessWidget {
  const _ActionLine({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: VicColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: VicColors.parchment,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: VicColors.muted,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonLine extends StatelessWidget {
  const _ComingSoonLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VicColors.parchment,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: VicColors.muted,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: VicColors.muted),
        ],
      ),
    );
  }
}

class _RepairAction extends StatelessWidget {
  const _RepairAction({
    required this.icon,
    required this.title,
    required this.body,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: VicColors.gold, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VicColors.parchment,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(color: VicColors.muted)),
              ],
            ),
          ),
          FilledButton(onPressed: onPressed, child: const Text('Run')),
        ],
      ),
    );
  }
}
