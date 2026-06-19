import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ReadinessTimeline extends StatelessWidget {
  const ReadinessTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = ['DETECTING', 'REPAIRING', 'VALIDATING', 'READY'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          ReadinessStep(label: steps[i], last: i == steps.length - 1),
          if (i != steps.length - 1)
            Container(width: 48, height: 1, color: const Color(0x8878522e)),
        ],
      ],
    );
  }
}

class ReadinessStep extends StatelessWidget {
  const ReadinessStep({super.key, required this.label, required this.last});

  final String label;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: last ? const Color(0xff5b451c) : const Color(0xff064d48),
            border: Border.all(
              color: last ? VicColors.gold : VicColors.tealBright,
            ),
            boxShadow: [
              BoxShadow(
                color: (last ? VicColors.gold : VicColors.tealBright)
                    .withValues(alpha: 0.22),
                blurRadius: 12,
              ),
            ],
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              last ? Icons.star : Icons.check,
              color: last ? const Color(0xffffdf7c) : VicColors.tealBright,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: last ? const Color(0xffffdf7c) : VicColors.parchment,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
