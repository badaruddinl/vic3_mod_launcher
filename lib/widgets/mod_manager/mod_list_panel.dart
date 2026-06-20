import 'package:flutter/material.dart';

import '../../models.dart';
import 'mod_list_empty_state.dart';
import 'mod_list_frame.dart';
import 'mod_list_tile.dart';
import 'mod_order_handle.dart';

class ModListPanel extends StatelessWidget {
  const ModListPanel({
    super.key,
    required this.title,
    required this.ids,
    required this.mods,
    required this.validations,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final List<String> ids;
  final Map<String, ModInfo> mods;
  final Map<String, ModValidation> validations;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ModListFrame(
      title: title,
      count: ids.length,
      child: ids.isEmpty
          ? const ModListEmptyState(message: 'No available mods found.')
          : ListView.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) {
                final id = ids[index];
                final mod = mods[id]!;
                return ModListTile(
                  mod: mod,
                  validation: validations[id],
                  selected: selected.contains(id),
                  onTap: () => onTap(id),
                );
              },
            ),
    );
  }
}

class ActiveModListPanel extends StatelessWidget {
  const ActiveModListPanel({
    super.key,
    required this.title,
    required this.ids,
    required this.mods,
    required this.validations,
    required this.selected,
    required this.onTap,
    required this.onReorder,
  });

  final String title;
  final List<String> ids;
  final Map<String, ModInfo> mods;
  final Map<String, ModValidation> validations;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ModListFrame(
      title: title,
      count: ids.length,
      child: ids.isEmpty
          ? const ModListEmptyState(message: 'Enable mods to build the order.')
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: ids.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final id = ids[index];
                final mod = mods[id]!;
                return ModListTile(
                  key: ValueKey(id),
                  mod: mod,
                  validation: validations[id],
                  selected: selected.contains(id),
                  onTap: () => onTap(id),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: ModOrderHandle(index: index),
                  ),
                );
              },
            ),
    );
  }
}
