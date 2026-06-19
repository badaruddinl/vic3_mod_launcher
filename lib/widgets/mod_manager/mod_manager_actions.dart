import 'package:flutter/material.dart';

class ModManagerActions extends StatelessWidget {
  const ModManagerActions({
    super.key,
    required this.onEnable,
    required this.onDisable,
    required this.onUp,
    required this.onDown,
    required this.onTop,
    required this.onBottom,
  });

  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onTop;
  final VoidCallback onBottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonal(
              onPressed: onEnable,
              child: const Text('Enable'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onDisable,
              child: const Text('Disable'),
            ),
            const Divider(height: 28),
            OutlinedButton(onPressed: onUp, child: const Text('Up')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onDown, child: const Text('Down')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onTop, child: const Text('Top')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onBottom, child: const Text('Bottom')),
          ],
        ),
      ),
    );
  }
}
