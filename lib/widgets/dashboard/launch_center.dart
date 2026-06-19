import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class LaunchCenter extends StatelessWidget {
  const LaunchCenter({
    super.key,
    required this.readyText,
    required this.readyDetail,
    required this.hasErrors,
    required this.onLaunch,
  });

  final String readyText;
  final String readyDetail;
  final bool hasErrors;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 196,
          height: 196,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: VicColors.gold, width: 2),
              gradient: const RadialGradient(
                colors: [Color(0xff0e4b45), Color(0xff071314)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/brand/app_icon_256.png'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasErrors ? Icons.error_outline : Icons.circle,
              color: hasErrors ? VicColors.danger : VicColors.tealBright,
              size: 15,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(readyText, style: vicTitle(context, size: 25)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          readyDetail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VicColors.parchment,
            fontSize: 13,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: GildedButton(label: 'START', large: true, onPressed: onLaunch),
        ),
      ],
    );
  }
}
