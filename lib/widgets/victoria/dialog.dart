import 'package:flutter/material.dart';

import 'surfaces.dart';
import 'theme.dart';

class VictoriaDialog extends StatelessWidget {
  const VictoriaDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.icon,
    this.maxWidth = 520,
  });

  final String title;
  final IconData? icon;
  final double maxWidth;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: VictoriaFrame(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: VicColors.parchment,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: VicColors.gold, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(title, style: vicTitle(context, size: 22)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0x6678522e)),
                  const SizedBox(height: 14),
                  child,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VictoriaDialogButton extends StatelessWidget {
  const VictoriaDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: primary ? 200 : 132,
      child: GildedButton(
        label: label,
        icon: icon,
        secondary: !primary,
        onPressed: onPressed,
      ),
    );
  }
}
