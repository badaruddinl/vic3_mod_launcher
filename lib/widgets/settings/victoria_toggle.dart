import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class VictoriaToggle extends StatelessWidget {
  const VictoriaToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 58,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? const Color(0xff064d48) : const Color(0xff2a2825),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: value ? VicColors.tealBright : VicColors.goldDark,
            ),
            boxShadow: [
              if (value)
                BoxShadow(
                  color: VicColors.tealBright.withValues(alpha: 0.18),
                  blurRadius: 10,
                ),
            ],
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? VicColors.tealBright : VicColors.muted,
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 5),
                ],
              ),
              child: SizedBox.square(
                dimension: 22,
                child: Icon(
                  value ? Icons.check : Icons.close,
                  color: const Color(0xff071314),
                  size: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
