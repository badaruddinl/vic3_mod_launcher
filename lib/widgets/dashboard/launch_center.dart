import 'package:flutter/material.dart';

import 'launch_button.dart';
import 'launch_emblem.dart';
import 'playset_status.dart';

class LaunchCenter extends StatelessWidget {
  const LaunchCenter({
    super.key,
    required this.readyText,
    required this.readyDetail,
    required this.hasErrors,
    required this.onLaunch,
    this.emblemSize = 196,
  });

  final String readyText;
  final String readyDetail;
  final bool hasErrors;
  final VoidCallback onLaunch;
  final double emblemSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LaunchEmblem(size: emblemSize),
        const SizedBox(height: 10),
        PlaysetStatus(
          title: readyText,
          detail: readyDetail,
          hasErrors: hasErrors,
        ),
        const SizedBox(height: 14),
        LaunchButton(onLaunch: onLaunch),
      ],
    );
  }
}
