import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class SettingsFieldBox extends StatelessWidget {
  const SettingsFieldBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff0b1718),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: VicColors.goldDark),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class BrowsePathButton extends StatelessWidget {
  const BrowsePathButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x99101f20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: VicColors.goldDark),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: const Icon(Icons.more_horiz, color: VicColors.gold),
          ),
        ),
      ),
    );
  }
}
