import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

class ModCompatibilityBadge extends StatelessWidget {
  const ModCompatibilityBadge({
    super.key,
    required this.compatible,
    required this.supportedVersion,
    required this.validation,
  });

  final VersionStatus compatible;
  final String supportedVersion;
  final ModValidation? validation;

  @override
  Widget build(BuildContext context) {
    final health = validation?.health;
    final (label, color) = switch (health) {
      ModHealth.ok => ('OK', VicColors.tealBright),
      ModHealth.warning => ('CHECK', Colors.orange.shade300),
      ModHealth.error => ('ERR', VicColors.danger),
      null => switch (compatible) {
        VersionStatus.ok => ('OK', VicColors.tealBright),
        VersionStatus.warning => ('CHECK', Colors.orange.shade300),
        VersionStatus.unknown => ('?', VicColors.muted),
      },
    };
    final validationText = validation == null
        ? ''
        : '\nfolder: ${validation!.folderExists ? 'yes' : 'no'}'
              '\nmetadata: ${validation!.metadataExists ? 'yes' : 'no'}'
              '\ndescriptor: ${validation!.descriptorExists ? 'yes' : 'no'}'
              '\nmounted last run: ${validation!.mountedLastRun ? 'yes' : 'no'}';
    return Tooltip(
      message:
          'supported_version: ${supportedVersion.isEmpty ? 'unknown' : supportedVersion}$validationText',
      child: Container(
        width: 54,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x33102121),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
