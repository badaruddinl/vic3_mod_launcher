import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'active_mod_tile.dart';

class ActiveModsPreview extends StatelessWidget {
  const ActiveModsPreview({
    super.key,
    required this.activeMods,
    required this.validations,
  });

  final List<ModInfo> activeMods;
  final Map<String, ModValidation> validations;

  @override
  Widget build(BuildContext context) {
    final preview = activeMods.take(3).toList();
    final extra = activeMods.length - preview.length;
    return GildedPanel(
      title: 'Mods in use (${activeMods.length})',
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
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
              ActiveModTile(mod: mod, validation: validations[mod.id]),
              const SizedBox(height: 12),
            ],
          if (extra > 0) ...[
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
          const Divider(color: Color(0x5578522e)),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: VicColors.gold),
              const SizedBox(width: 9),
              Text(
                '${activeMods.length} enabled',
                style: const TextStyle(color: VicColors.gold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
