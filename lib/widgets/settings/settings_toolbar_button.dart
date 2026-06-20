import 'package:flutter/material.dart';

import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';

class SettingsToolbarButton extends StatelessWidget {
  const SettingsToolbarButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary ? const Color(0xff073f3b) : const Color(0x99121b1c),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: VicColors.gold),
                  const SizedBox(width: 8),
                  Flexible(
                    child: EllipsisTooltipText(
                      label,
                      style: const TextStyle(
                        color: VicColors.parchment,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
