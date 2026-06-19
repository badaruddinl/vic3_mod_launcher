import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingsPathRow extends StatelessWidget {
  const SettingsPathRow({
    super.key,
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
        Icon(icon, color: VicColors.gold, size: 30),
        const SizedBox(width: 14),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: VicColors.parchment,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: VicColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(child: PathValueField(value: value)),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: onBrowse,
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Browse',
        ),
      ],
    );
  }
}

class PathValueField extends StatelessWidget {
  const PathValueField({super.key, required this.value});

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          value.isEmpty ? 'Not set' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.parchment, fontSize: 13),
        ),
      ),
    );
  }
}

class ExtraModRootsRow extends StatelessWidget {
  const ExtraModRootsRow({
    super.key,
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
          size: 30,
        ),
        const SizedBox(width: 14),
        const SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Mod Folders',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: VicColors.parchment, fontSize: 16),
              ),
              SizedBox(height: 2),
              Text(
                'Scan extra folders for mods.',
                style: TextStyle(color: VicColors.muted, fontSize: 12),
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
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (roots.isEmpty)
                    const Text(
                      'No additional folders added.',
                      style: TextStyle(color: VicColors.muted, fontSize: 13),
                    ),
                  for (final root in roots)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
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
