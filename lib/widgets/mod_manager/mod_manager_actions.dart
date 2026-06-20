import 'package:flutter/material.dart';

import 'mod_action_button.dart';

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
      width: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ModActionButton(
              tooltip: 'Enable selected',
              icon: Icons.chevron_right,
              primary: true,
              onPressed: onEnable,
            ),
            const SizedBox(height: 8),
            ModActionButton(
              tooltip: 'Disable selected',
              icon: Icons.chevron_left,
              onPressed: onDisable,
            ),
            const SizedBox(height: 18),
            ModActionButton(
              tooltip: 'Move up',
              icon: Icons.keyboard_arrow_up,
              onPressed: onUp,
            ),
            const SizedBox(height: 8),
            ModActionButton(
              tooltip: 'Move down',
              icon: Icons.keyboard_arrow_down,
              onPressed: onDown,
            ),
            const SizedBox(height: 8),
            ModActionButton(
              tooltip: 'Move to top',
              icon: Icons.vertical_align_top,
              onPressed: onTop,
            ),
            const SizedBox(height: 8),
            ModActionButton(
              tooltip: 'Move to bottom',
              icon: Icons.vertical_align_bottom,
              onPressed: onBottom,
            ),
          ],
        ),
      ),
    );
  }
}
