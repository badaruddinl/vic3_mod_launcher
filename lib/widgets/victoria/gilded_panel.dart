import 'package:flutter/material.dart';

import 'theme.dart';

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
