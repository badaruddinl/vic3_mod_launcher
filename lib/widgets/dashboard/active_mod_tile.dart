import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

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
        ModThumbnail(source: mod.source),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            mod.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: VicColors.parchment,
              fontFamily: 'Georgia',
              fontSize: 16,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 6),
        ModHealthMark(ok: ok),
      ],
    );
  }
}

class ModThumbnail extends StatelessWidget {
  const ModThumbnail({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          source == 'external' ? Icons.public_outlined : Icons.factory_outlined,
          color: VicColors.gold,
          size: 30,
        ),
      ),
    );
  }
}

class ModHealthMark extends StatelessWidget {
  const ModHealthMark({super.key, required this.ok});

  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Icon(
      ok ? Icons.check_circle_outline : Icons.error_outline,
      color: ok ? VicColors.tealBright : VicColors.danger,
      size: 22,
    );
  }
}
