import 'package:flutter/material.dart';

import '../../models.dart';
import '../mod_manager.dart';
import 'mods_toolbar.dart';
import 'saved_playsets_strip.dart';

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
