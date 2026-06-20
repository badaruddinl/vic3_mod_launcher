import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaWindowButton extends StatelessWidget {
  const VictoriaWindowButton({
    super.key,
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
      child: SizedBox.square(
        dimension: 34,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: onPressed,
            radius: 22,
            child: Icon(icon, color: VicColors.gold, size: 24),
          ),
        ),
      ),
    );
  }
}

class VictoriaRoundIconButton extends StatelessWidget {
  const VictoriaRoundIconButton({
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
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
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
