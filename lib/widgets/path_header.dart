import 'package:flutter/material.dart';

import '../services/launcher_config.dart';

class PathHeader extends StatelessWidget {
  const PathHeader({
    super.key,
    required this.config,
    required this.gameVersion,
    required this.onPickUserData,
    required this.onPickGameRoot,
    required this.onAutoDetect,
    required this.onRefresh,
    required this.onImportZip,
    required this.onRepair,
    required this.onSave,
    required this.onLaunch,
    required this.onAutoRepairChanged,
  });

  final LauncherConfig config;
  final String gameVersion;
  final VoidCallback onPickUserData;
  final VoidCallback onPickGameRoot;
  final VoidCallback onAutoDetect;
  final VoidCallback onRefresh;
  final VoidCallback onImportZip;
  final VoidCallback onRepair;
  final VoidCallback onSave;
  final VoidCallback onLaunch;
  final ValueChanged<bool> onAutoRepairChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _PathLine(
                    label: 'Game',
                    value: config.gameRoot,
                    onBrowse: onPickGameRoot,
                  ),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'Version',
                  value: gameVersion.isEmpty ? 'unknown' : gameVersion,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PathLine(
                    label: 'Data',
                    value: config.userDataPath,
                    onBrowse: onPickUserData,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: config.autoRepair,
                      onChanged: (value) => onAutoRepairChanged(value ?? true),
                    ),
                    const Text('Auto repair .mod'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onAutoDetect,
                  icon: const Icon(Icons.radar_outlined),
                  label: const Text('Auto Detect'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onImportZip,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Import ZIP'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onRepair,
                  icon: const Icon(Icons.build_outlined),
                  label: const Text('Repair Descriptors'),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Playset'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onLaunch,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Launch Game'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PathLine extends StatelessWidget {
  const _PathLine({
    required this.label,
    required this.value,
    required this.onBrowse,
  });

  final String label;
  final String value;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: Container(
            height: 36,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: SelectableText(
              value.isEmpty ? 'not set' : value,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onBrowse,
          icon: const Icon(Icons.folder_open),
          tooltip: 'Browse',
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
