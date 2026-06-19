import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'theme.dart';

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
        _WindowButton(
          tooltip: 'Minimize',
          icon: Icons.remove,
          onPressed: () => windowManager.minimize(),
        ),
        const SizedBox(width: 8),
        _WindowButton(
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
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x44102121),
        border: Border.all(color: VicColors.goldDark),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: VicColors.gold,
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onPressed,
          radius: 22,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, color: VicColors.gold, size: 24),
          ),
        ),
      ),
    );
  }
}
