import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ModListEmptyState extends StatelessWidget {
  const ModListEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: VicColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}
