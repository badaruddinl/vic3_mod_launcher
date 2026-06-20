import 'package:flutter/material.dart';

import 'theme.dart';

class GildedButton extends StatelessWidget {
  const GildedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.large = false,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool large;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final height = large ? 58.0 : 44.0;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: secondary
                ? const [Color(0xff151b1c), Color(0xff202625)]
                : const [Color(0xff086259), Color(0xff06433e)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: VicColors.gold, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: VicColors.gold, size: large ? 28 : 20),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: large ? 25 : 16,
                      color: VicColors.parchment,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w600,
                      letterSpacing: large ? 4.2 : 0,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
