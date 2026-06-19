import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'mod_list_tile.dart';

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
      child: ListView.builder(
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
      child: ReorderableListView.builder(
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
              child: SizedBox(
                width: 34,
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: VicColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: VicColors.gold,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModListFrame extends StatelessWidget {
  const ModListFrame({
    super.key,
    required this.title,
    required this.count,
    required this.child,
  });

  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc071314),
        border: Border.all(color: VicColors.goldDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x8878522e))),
            ),
            child: Text('$title ($count)', style: vicLabel(context, size: 12)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
