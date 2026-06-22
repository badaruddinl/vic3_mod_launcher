import 'package:flutter/material.dart';

import 'launch_center.dart';

class DashboardHeroStage extends StatelessWidget {
  const DashboardHeroStage({
    super.key,
    required this.readyText,
    required this.readyDetail,
    required this.hasErrors,
    required this.onLaunch,
  });

  final String readyText;
  final String readyDetail;
  final bool hasErrors;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LaunchCenter(
        readyText: readyText,
        readyDetail: readyDetail,
        hasErrors: hasErrors,
        emblemSize: 174,
        onLaunch: onLaunch,
      ),
    );
  }
}
