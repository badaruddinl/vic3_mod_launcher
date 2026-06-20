import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

class ActiveModTile extends StatelessWidget {
  const ActiveModTile({
    super.key,
    required this.mod,
    required this.validation,
    this.compact = false,
  });

  final ModInfo mod;
  final ModValidation? validation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ok =
        validation?.health == ModHealth.ok ||
        mod.compatible == VersionStatus.ok;
    return Row(
      children: [
        ModThumbnail(source: mod.source, size: compact ? 46 : 62),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Text(
            mod.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: VicColors.parchment,
              fontFamily: 'Georgia',
              fontSize: compact ? 14 : 16,
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
  const ModThumbnail({super.key, required this.source, this.size = 62});

  final String source;
  final double size;

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
        width: size,
        height: size,
        child: Icon(
          source == 'external' ? Icons.public_outlined : Icons.factory_outlined,
          color: VicColors.gold,
          size: size * 0.48,
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
