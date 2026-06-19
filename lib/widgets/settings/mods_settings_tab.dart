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
        ModsToolbar(
          onImportZip: onImportZip,
          onSavePlaysetAs: onSavePlaysetAs,
          onSavePlayset: onSavePlayset,
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
