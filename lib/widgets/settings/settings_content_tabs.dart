import 'package:flutter/material.dart';

import '../../models.dart';
import '../mod_manager.dart';
import '../victoria_ui.dart';

class ModsSettingsTab extends StatelessWidget {
  const ModsSettingsTab({
    super.key,
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
        SavedPlaysetsStrip(
          playsets: playsets,
          onLoadPlayset: onLoadPlayset,
          onDeletePlayset: onDeletePlayset,
        ),
      ],
    );
  }
}

class SavedPlaysetsStrip extends StatelessWidget {
  const SavedPlaysetsStrip({
    super.key,
    required this.playsets,
    required this.onLoadPlayset,
    required this.onDeletePlayset,
  });

  final List<SavedPlayset> playsets;
  final ValueChanged<SavedPlayset> onLoadPlayset;
  final ValueChanged<SavedPlayset> onDeletePlayset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

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

class RepairSettingsTab extends StatelessWidget {
  const RepairSettingsTab({
    super.key,
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
      padding: const EdgeInsets.all(18),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          RepairActionCard(
            icon: Icons.bug_report_outlined,
            title: 'Diagnose',
            body:
                'Check paths, descriptors, active mods, and content_load.json.',
            onPressed: onDiagnose,
          ),
          RepairActionCard(
            icon: Icons.build_outlined,
            title: 'Repair Descriptors',
            body: 'Generate missing .mod files and descriptor.mod fields.',
            onPressed: onRepair,
          ),
          RepairActionCard(
            icon: Icons.restore_page_outlined,
            title: 'Restore Backup',
            body: 'Restore the last content_load.json backup.',
            onPressed: onRestoreBackup,
          ),
          RepairActionCard(
            icon: Icons.radar_outlined,
            title: 'Auto Detect',
            body: 'Detect game and data folders again.',
            onPressed: onAutoDetect,
          ),
          RepairActionCard(
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

class RepairActionCard extends StatelessWidget {
  const RepairActionCard({
    super.key,
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: VicColors.gold, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: VicColors.parchment,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: VicColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: onPressed, child: const Text('Run')),
        ],
      ),
    );
  }
}
