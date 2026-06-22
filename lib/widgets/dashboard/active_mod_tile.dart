import 'dart:io';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../common/ellipsis_tooltip_text.dart';
import '../mod_display_name.dart';
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
    final displayName = formatModDisplayName(mod.name);
    return Row(
      children: [
        ModThumbnail(
          source: mod.source,
          iconPath: mod.iconPath,
          size: compact ? 38 : 62,
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: EllipsisTooltipText(
            displayName,
            tooltip: mod.name,
            maxLines: compact ? 1 : 2,
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
  const ModThumbnail({
    super.key,
    required this.source,
    required this.iconPath,
    this.size = 62,
  });

  final String source;
  final String iconPath;
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
        child: _ModThumbnailContent(
          source: source,
          iconPath: iconPath,
          size: size,
        ),
      ),
    );
  }
}

class _ModThumbnailContent extends StatelessWidget {
  const _ModThumbnailContent({
    required this.source,
    required this.iconPath,
    required this.size,
  });

  final String source;
  final String iconPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.file(
          File(iconPath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _FallbackModIcon(source: source, size: size),
        ),
      );
    }
    return _FallbackModIcon(source: source, size: size);
  }
}

class _FallbackModIcon extends StatelessWidget {
  const _FallbackModIcon({required this.source, required this.size});

  final String source;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      source == 'external' ? Icons.public_outlined : Icons.factory_outlined,
      color: VicColors.gold,
      size: size * 0.48,
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
