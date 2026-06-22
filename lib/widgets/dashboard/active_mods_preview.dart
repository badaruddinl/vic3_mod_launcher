import 'package:flutter/material.dart';

import '../../models.dart';
import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';
import 'active_mod_tile.dart';

class ActiveModsPreview extends StatelessWidget {
  const ActiveModsPreview({
    super.key,
    required this.activeMods,
    required this.validations,
    this.compact = false,
    this.onShowAll,
  });

  final List<ModInfo> activeMods;
  final Map<String, ModValidation> validations;
  final bool compact;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final preview = activeMods.take(compact ? 1 : 3).toList();
    final extra = activeMods.length - preview.length;
    final showFooter = !compact || extra > 0;
    final footerLabel = compact
        ? '+$extra more'
        : '${activeMods.length} enabled';
    return GildedPanel(
      title: 'Mods in use (${activeMods.length})',
      padding: EdgeInsets.fromLTRB(16, compact ? 13 : 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (preview.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No active mods',
                  style: TextStyle(color: VicColors.muted),
                ),
              ),
            )
          else
            for (final mod in preview) ...[
              ActiveModTile(
                mod: mod,
                validation: validations[mod.id],
                compact: compact,
              ),
              if (!compact) const SizedBox(height: 12),
            ],
          if (extra > 0 && !compact) ...[
            const Divider(color: Color(0x5578522e)),
            Center(
              child: Text(
                '+$extra more',
                style: const TextStyle(
                  color: VicColors.tealBright,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (showFooter) ...[
            if (!compact) const Divider(color: Color(0x5578522e)),
            Row(
              children: [
                if (!compact) ...[
                  const Icon(Icons.inventory_2_outlined, color: VicColors.gold),
                  const SizedBox(width: 9),
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: compact && onShowAll != null
                        ? MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onShowAll,
                              child: SizedBox(
                                width: 96,
                                height: 22,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: EllipsisTooltipText(
                                    footerLabel,
                                    style: const TextStyle(
                                      color: VicColors.gold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : EllipsisTooltipText(
                            footerLabel,
                            style: const TextStyle(
                              color: VicColors.gold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
