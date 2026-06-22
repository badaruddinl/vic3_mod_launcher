import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ModActionButton extends StatelessWidget {
  const ModActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: primary ? const Color(0xff07443f) : const Color(0xaa111b1c),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primary ? VicColors.gold : VicColors.goldDark,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onPressed,
              child: Icon(icon, color: VicColors.gold, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
