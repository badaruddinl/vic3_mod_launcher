import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ModOrderHandle extends StatelessWidget {
  const ModOrderHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Row(
        children: [
          Text(
            '${index + 1}',
            style: const TextStyle(
              color: VicColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Icon(Icons.drag_indicator, size: 16, color: VicColors.gold),
        ],
      ),
    );
  }
}
