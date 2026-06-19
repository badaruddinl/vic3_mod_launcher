import 'package:flutter/material.dart';

import 'readiness_step.dart';

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
