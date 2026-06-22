import 'package:flutter/material.dart';

import 'surfaces.dart';
import 'theme.dart';

class VictoriaShell extends StatelessWidget {
  const VictoriaShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VicColors.ink,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/brand/launcher_backdrop.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x11071314),
                    Color(0x44071314),
                    Color(0x99031112),
                  ],
                ),
              ),
            ),
            DefaultTextStyle(
              style: const TextStyle(
                color: VicColors.parchment,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: VictoriaFrame(child: child),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
