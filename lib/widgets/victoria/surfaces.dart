import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaFrame extends StatelessWidget {
  const VictoriaFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xbb071314),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VicColors.goldDark, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 22, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xffc99454), width: 0.7),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GildedPanel extends StatelessWidget {
  const GildedPanel({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
  });

  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VicColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VicColors.goldDark),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || trailing != null) ...[
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!.toUpperCase(),
                        style: vicLabel(context, size: 13),
                      ),
                    ),
                  if (trailing != null)
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: VicColors.muted,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                      ),
                      child: trailing!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x5578522e)),
              const SizedBox(height: 12),
            ],
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

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
