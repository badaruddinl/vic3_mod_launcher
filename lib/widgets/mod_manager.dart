import 'package:flutter/material.dart';

import '../models.dart';

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
            child: _ModList(
              title: 'Mod tersedia',
              ids: availableIds,
              mods: mods,
              validations: validations,
              selected: selectedAvailable,
              onTap: onAvailableTap,
            ),
          ),
          SizedBox(
            width: 122,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.tonal(
                    onPressed: onEnable,
                    child: const Text('Enable'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onDisable,
                    child: const Text('Disable'),
                  ),
                  const Divider(height: 28),
                  OutlinedButton(onPressed: onUp, child: const Text('Up')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: onDown, child: const Text('Down')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: onTop, child: const Text('Top')),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onBottom,
                    child: const Text('Bottom'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _ActiveModList(
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

class _ModList extends StatelessWidget {
  const _ModList({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Text(
              '$title (${ids.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ids.length,
              itemBuilder: (context, index) {
                final id = ids[index];
                final mod = mods[id]!;
                final isSelected = selected.contains(id);
                return Material(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  child: ListTile(
                    onTap: () => onTap(id),
                    leading: Icon(
                      mod.source == 'external'
                          ? Icons.link
                          : Icons.folder_outlined,
                    ),
                    title: Text(
                      mod.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${mod.source} | supported ${mod.supportedVersion.isEmpty ? 'unknown' : mod.supportedVersion} | mod ${mod.version.isEmpty ? 'unknown' : mod.version}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _CompatibilityBadge(
                      compatible: mod.compatible,
                      supportedVersion: mod.supportedVersion,
                      validation: validations[id],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveModList extends StatelessWidget {
  const _ActiveModList({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Text(
              '$title (${ids.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: ids.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final id = ids[index];
                final mod = mods[id]!;
                final isSelected = selected.contains(id);
                return Material(
                  key: ValueKey(id),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  child: ListTile(
                    onTap: () => onTap(id),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: SizedBox(
                        width: 34,
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const Icon(Icons.drag_indicator, size: 16),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      mod.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${mod.source} | supported ${mod.supportedVersion.isEmpty ? 'unknown' : mod.supportedVersion} | mod ${mod.version.isEmpty ? 'unknown' : mod.version}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _CompatibilityBadge(
                      compatible: mod.compatible,
                      supportedVersion: mod.supportedVersion,
                      validation: validations[id],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({
    required this.compatible,
    required this.supportedVersion,
    required this.validation,
  });

  final VersionStatus compatible;
  final String supportedVersion;
  final ModValidation? validation;

  @override
  Widget build(BuildContext context) {
    final health = validation?.health;
    final (label, color) = switch (health) {
      ModHealth.ok => ('OK', Colors.green.shade700),
      ModHealth.warning => ('CHECK', Colors.orange.shade800),
      ModHealth.error => ('ERR', Colors.red.shade700),
      null => switch (compatible) {
        VersionStatus.ok => ('OK', Colors.green.shade700),
        VersionStatus.warning => ('CHECK', Colors.orange.shade800),
        VersionStatus.unknown => ('?', Colors.blueGrey.shade600),
      },
    };
    final validationText = validation == null
        ? ''
        : '\nfolder: ${validation!.folderExists ? 'yes' : 'no'}'
              '\nmetadata: ${validation!.metadataExists ? 'yes' : 'no'}'
              '\ndescriptor: ${validation!.descriptorExists ? 'yes' : 'no'}'
              '\nmounted last run: ${validation!.mountedLastRun ? 'yes' : 'no'}';
    return Tooltip(
      message:
          'supported_version: ${supportedVersion.isEmpty ? 'unknown' : supportedVersion}$validationText',
      child: Container(
        width: 54,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
