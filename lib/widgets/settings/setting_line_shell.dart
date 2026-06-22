import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingLineShell extends StatelessWidget {
  const SettingLineShell({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}

class SettingLineIcon extends StatelessWidget {
  const SettingLineIcon({super.key, required this.icon, this.muted = false});

  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: muted ? const Color(0x552a2825) : const Color(0x55064d48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: muted ? VicColors.goldDark : VicColors.teal),
      ),
      child: SizedBox.square(
        dimension: 34,
        child: Icon(
          icon,
          color: muted ? VicColors.muted : VicColors.gold,
          size: 19,
        ),
      ),
    );
  }
}
