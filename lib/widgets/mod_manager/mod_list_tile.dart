import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'mod_compatibility_badge.dart';

class ModListTile extends StatelessWidget {
  const ModListTile({
    super.key,
    required this.mod,
    required this.validation,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final ModInfo mod;
  final ModValidation? validation;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x55215a54) : Colors.transparent,
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading:
            leading ??
            Icon(
              mod.source == 'external' ? Icons.link : Icons.folder_outlined,
              color: VicColors.gold,
            ),
        title: Text(
          mod.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.parchment),
        ),
        subtitle: Text(
          '${mod.source} | supported ${mod.supportedVersion.isEmpty ? 'unknown' : mod.supportedVersion} | mod ${mod.version.isEmpty ? 'unknown' : mod.version}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
        trailing: ModCompatibilityBadge(
          compatible: mod.compatible,
          supportedVersion: mod.supportedVersion,
          validation: validation,
        ),
      ),
    );
  }
}
