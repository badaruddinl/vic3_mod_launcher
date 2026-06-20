import 'package:flutter/material.dart';

import '../../models.dart';
import 'active_mods_preview.dart';
import 'launch_center.dart';

class DashboardHeroStage extends StatelessWidget {
  const DashboardHeroStage({
    super.key,
    required this.activeMods,
    required this.validations,
    required this.readyText,
    required this.readyDetail,
    required this.hasErrors,
    required this.onLaunch,
  });

  final List<ModInfo> activeMods;
  final Map<String, ModValidation> validations;
  final String readyText;
  final String readyDetail;
  final bool hasErrors;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          top: 18,
          bottom: 22,
          child: SizedBox(
            width: 250,
            child: ActiveModsPreview(
              activeMods: activeMods,
              validations: validations,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 142),
          child: LaunchCenter(
            readyText: readyText,
            readyDetail: readyDetail,
            hasErrors: hasErrors,
            onLaunch: onLaunch,
          ),
        ),
      ],
    );
  }
}
