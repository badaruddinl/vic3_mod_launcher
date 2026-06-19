import 'package:flutter/material.dart';

import '../models.dart';
import 'mod_manager/mod_list_panel.dart';
import 'mod_manager/mod_manager_actions.dart';

class ModManager extends StatelessWidget {
  const ModManager({
    super.key,
    required this.mods,
    required this.availableIds,
    required this.activeIds,
    required this.selectedAvailable,
    required this.selectedActive,
    required this.validations,
    required this.onAvailableTap,
    required this.onActiveTap,
    required this.onActiveReorder,
    required this.onEnable,
    required this.onDisable,
    required this.onUp,
    required this.onDown,
    required this.onTop,
    required this.onBottom,
  });

  final Map<String, ModInfo> mods;
  final List<String> availableIds;
  final List<String> activeIds;
  final Set<String> selectedAvailable;
  final Set<String> selectedActive;
  final Map<String, ModValidation> validations;
  final ValueChanged<String> onAvailableTap;
  final ValueChanged<String> onActiveTap;
  final void Function(int oldIndex, int newIndex) onActiveReorder;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onTop;
  final VoidCallback onBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ModListPanel(
              title: 'Mod tersedia',
              ids: availableIds,
              mods: mods,
              validations: validations,
              selected: selectedAvailable,
              onTap: onAvailableTap,
            ),
          ),
          ModManagerActions(
            onEnable: onEnable,
            onDisable: onDisable,
            onUp: onUp,
            onDown: onDown,
            onTop: onTop,
            onBottom: onBottom,
          ),
          Expanded(
            child: ActiveModListPanel(
              title: 'Urutan mod aktif',
              ids: activeIds,
              mods: mods,
              validations: validations,
              selected: selectedActive,
              onTap: onActiveTap,
              onReorder: onActiveReorder,
            ),
          ),
        ],
      ),
    );
  }
}
