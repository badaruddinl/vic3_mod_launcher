import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaFrame extends StatelessWidget {
  const VictoriaFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xbb071314),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VicColors.goldDark, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 22, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xffc99454), width: 0.7),
          ),
          child: child,
        ),
      ),
    );
  }
}
