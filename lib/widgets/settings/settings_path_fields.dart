import 'package:flutter/material.dart';

import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';
import 'extra_mod_root_chip.dart';
import 'settings_field_box.dart';
import 'settings_row_label.dart';

class SettingsPathRow extends StatelessWidget {
  const SettingsPathRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onBrowse,
    this.labelWidth = 134,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onBrowse;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SettingsRowLabel(
          icon: icon,
          title: title,
          subtitle: subtitle,
          width: labelWidth,
        ),
        Expanded(child: PathValueField(value: value)),
        const SizedBox(width: 8),
        BrowsePathButton(onPressed: onBrowse),
      ],
    );
  }
}

class PathValueField extends StatelessWidget {
  const PathValueField({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return SettingsFieldBox(
      child: Padding(
        padding: EdgeInsets.zero,
        child: EllipsisTooltipText(
          value.isEmpty ? 'Not set' : value,
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
        const SettingsRowLabel(
          icon: Icons.create_new_folder_outlined,
          title: 'Mod Folders',
          subtitle: 'Extra scan paths.',
          width: 134,
        ),
        Expanded(
          child: SettingsFieldBox(
            padding: const EdgeInsets.all(9),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (roots.isEmpty)
                    const Text(
                      'No additional folders added.',
                      style: TextStyle(color: VicColors.muted, fontSize: 13),
                    ),
                  for (final root in roots)
                    ExtraModRootChip(root: root, onRemove: onRemove),
                  TextButton(
                    onPressed: onAdd,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Text('Add Folder', maxLines: 1),
                      ],
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
