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
    return Column(
      children: [
        SizedBox(
          height: 142,
          child: ActiveModsPreview(
            activeMods: activeMods,
            validations: validations,
            compact: true,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: LaunchCenter(
              readyText: readyText,
              readyDetail: readyDetail,
              hasErrors: hasErrors,
              emblemSize: 158,
              onLaunch: onLaunch,
            ),
          ),
        ),
      ],
    );
  }
}
