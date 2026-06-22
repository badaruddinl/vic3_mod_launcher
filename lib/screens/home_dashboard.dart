import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets/dashboard/home_dashboard_components.dart';
import '../widgets/victoria_ui.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.gameVersion,
    required this.mods,
    required this.activeModIds,
    required this.validations,
    required this.onLaunch,
    required this.onOpenSettings,
    required this.onOpenMods,
    required this.updateMenu,
  });

  final String gameVersion;
  final Map<String, ModInfo> mods;
  final List<String> activeModIds;
  final Map<String, ModValidation> validations;
  final VoidCallback onLaunch;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenMods;
  final Widget updateMenu;

  @override
  Widget build(BuildContext context) {
    final activeMods = activeModIds
        .where(mods.containsKey)
        .map((id) => mods[id]!)
        .toList();
    final hasErrors = activeMods.any((mod) {
      final validation = validations[mod.id];
      return validation?.health == ModHealth.error ||
          mod.compatible == VersionStatus.warning;
    });

    return VictoriaShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          children: [
            VictoriaTitleBar(
              leading: VictoriaIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: onOpenSettings,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  updateMenu,
                  const SizedBox(width: 14),
                  const VictoriaWindowButtons(),
                ],
              ),
            ),
            VictoriaHeaderMark(gameVersion: gameVersion, compact: true),
            const SizedBox(height: 14),
            Expanded(
              child: DashboardHeroStage(
                readyText: hasErrors ? 'Needs attention' : 'Playset ready',
                readyDetail: hasErrors
                    ? 'Some mods need validation before launch.'
                    : 'All enabled content is loaded and checked.',
                hasErrors: hasErrors,
                onLaunch: onLaunch,
              ),
            ),
            const SizedBox(height: 18),
            const ReadinessTimeline(),
            const SizedBox(height: 14),
            SizedBox(
              height: 122,
              child: ActiveModsPreview(
                activeMods: activeMods,
                validations: validations,
                compact: true,
                onShowAll: onOpenMods,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
