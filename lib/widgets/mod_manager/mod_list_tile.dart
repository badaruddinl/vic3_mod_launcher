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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? const Color(0x66215a54) : const Color(0x33101f20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? VicColors.tealBright : const Color(0x5578522e),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  leading ?? ModSourceIcon(source: mod.source),
                  const SizedBox(width: 10),
                  Expanded(child: ModListTileText(mod: mod)),
                  const SizedBox(width: 8),
                  ModCompatibilityBadge(
                    compatible: mod.compatible,
                    supportedVersion: mod.supportedVersion,
                    validation: validation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModSourceIcon extends StatelessWidget {
  const ModSourceIcon({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Icon(
      source == 'external' ? Icons.link : Icons.folder_outlined,
      color: VicColors.gold,
      size: 22,
    );
  }
}

class ModListTileText extends StatelessWidget {
  const ModListTileText({super.key, required this.mod});

  final ModInfo mod;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mod.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: VicColors.parchment,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${mod.source} | supported ${mod.supportedVersion.isEmpty ? 'unknown' : mod.supportedVersion} | mod ${mod.version.isEmpty ? 'unknown' : mod.version}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
