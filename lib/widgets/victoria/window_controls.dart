import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button.dart';

class VictoriaTitleBar extends StatelessWidget {
  const VictoriaTitleBar({
    super.key,
    required this.leading,
    required this.trailing,
  });

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          const Positioned.fill(child: DragToMoveArea(child: SizedBox())),
          Align(alignment: Alignment.centerLeft, child: leading),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}

class VictoriaWindowButtons extends StatelessWidget {
  const VictoriaWindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VictoriaWindowButton(
          tooltip: 'Minimize',
          icon: Icons.remove,
          onPressed: () => windowManager.minimize(),
        ),
        const SizedBox(width: 8),
        VictoriaWindowButton(
          tooltip: 'Close',
          icon: Icons.close,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class VictoriaIconButton extends StatelessWidget {
  const VictoriaIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return VictoriaRoundIconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
