import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class LaunchButton extends StatelessWidget {
  const LaunchButton({super.key, required this.onLaunch});

  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: GildedButton(label: 'START', large: true, onPressed: onLaunch),
    );
  }
}
