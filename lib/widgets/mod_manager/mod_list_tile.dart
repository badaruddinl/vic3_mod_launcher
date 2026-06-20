import 'package:flutter/material.dart';

import '../../models.dart';
import '../common/ellipsis_tooltip_text.dart';
import '../mod_display_name.dart';
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 190;
                  final badge = ModCompatibilityBadge(
                    compatible: mod.compatible,
                    supportedVersion: mod.supportedVersion,
                    validation: validation,
                  );

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leading ?? ModSourceIcon(source: mod.source),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ModListTileText(mod: mod, narrow: true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(alignment: Alignment.centerRight, child: badge),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      leading ?? ModSourceIcon(source: mod.source),
                      const SizedBox(width: 10),
                      Expanded(child: ModListTileText(mod: mod)),
                      const SizedBox(width: 8),
                      badge,
                    ],
                  );
                },
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
  const ModListTileText({super.key, required this.mod, this.narrow = false});

  final ModInfo mod;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final displayName = formatModDisplayName(mod.name);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllipsisTooltipText(
          displayName,
          tooltip: mod.name,
          maxLines: narrow ? 2 : 1,
          style: const TextStyle(
            color: VicColors.parchment,
            fontWeight: FontWeight.w600,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 2),
        EllipsisTooltipText(
          '${mod.source} | supported ${mod.supportedVersion.isEmpty ? 'unknown' : mod.supportedVersion} | mod ${mod.version.isEmpty ? 'unknown' : mod.version}',
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
