import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

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

class ActiveModTile extends StatelessWidget {
  const ActiveModTile({super.key, required this.mod, required this.validation});

  final ModInfo mod;
  final ModValidation? validation;

  @override
  Widget build(BuildContext context) {
    final ok =
        validation?.health == ModHealth.ok ||
        mod.compatible == VersionStatus.ok;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xff102524),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: VicColors.goldDark),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
          ),
          child: SizedBox(
            width: 62,
            height: 62,
            child: Icon(
              mod.source == 'external'
                  ? Icons.public_outlined
                  : Icons.factory_outlined,
              color: VicColors.gold,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            mod.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: VicColors.parchment,
              fontSize: 16,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          ok ? Icons.check_circle_outline : Icons.error_outline,
          color: ok ? VicColors.tealBright : VicColors.danger,
          size: 22,
        ),
      ],
    );
  }
}
