import 'package:flutter/material.dart';

import '../constants.dart';
import '../models.dart';
import '../widgets/victoria_ui.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.gameVersion,
    required this.mods,
    required this.activeModIds,
    required this.validations,
    required this.logs,
    required this.onLaunch,
    required this.onOpenSettings,
    required this.updateMenu,
  });

  final String gameVersion;
  final Map<String, ModInfo> mods;
  final List<String> activeModIds;
  final Map<String, ModValidation> validations;
  final List<String> logs;
  final VoidCallback onLaunch;
  final VoidCallback onOpenSettings;
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
    final readyText = hasErrors ? 'Needs attention' : 'Playset ready';
    final readyDetail = hasErrors
        ? 'Some mods need validation before launch.'
        : 'All enabled content is loaded and checked.';

    return VictoriaShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          children: [
            _DashboardHeader(
              gameVersion: gameVersion,
              onOpenSettings: onOpenSettings,
              updateMenu: updateMenu,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 320,
                    child: ActiveModsPreview(
                      activeMods: activeMods,
                      validations: validations,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: _LaunchCenter(
                      readyText: readyText,
                      readyDetail: readyDetail,
                      hasErrors: hasErrors,
                      onLaunch: onLaunch,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(height: 205, child: LiveLogPanel(logs: logs)),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.gameVersion,
    required this.onOpenSettings,
    required this.updateMenu,
  });

  final String gameVersion;
  final VoidCallback onOpenSettings;
  final Widget updateMenu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 92,
                width: 92,
                child: Image.asset('assets/brand/app_icon_256.png'),
              ),
              const SizedBox(height: 6),
              Text(appName, style: vicTitle(context, size: 42)),
              const SizedBox(height: 12),
              _VersionPill(
                label: gameVersion.isEmpty ? 'unknown' : 'v$gameVersion',
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            tooltip: 'Settings',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            color: VicColors.gold,
          ),
        ),
        Align(alignment: Alignment.topRight, child: updateMenu),
      ],
    );
  }
}

class _VersionPill extends StatelessWidget {
  const _VersionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff063f3b),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VicColors.gold),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: VicColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class ActiveModsPreview extends StatelessWidget {
  const ActiveModsPreview({
    super.key,
    required this.activeMods,
    required this.validations,
  });

  final List<ModInfo> activeMods;
  final Map<String, ModValidation> validations;

  @override
  Widget build(BuildContext context) {
    final preview = activeMods.take(3).toList();
    final extra = activeMods.length - preview.length;
    return GildedPanel(
      title: 'Mods in use (${activeMods.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final mod in preview) ...[
            _ActiveModTile(mod: mod, validation: validations[mod.id]),
            const SizedBox(height: 14),
          ],
          if (extra > 0) ...[
            const Divider(color: Color(0x5578522e)),
            Center(
              child: Text(
                '+$extra more',
                style: const TextStyle(
                  color: VicColors.tealBright,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          const Divider(color: Color(0x5578522e)),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: VicColors.gold),
              const SizedBox(width: 10),
              Text(
                '${activeMods.length} enabled',
                style: const TextStyle(color: VicColors.gold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveModTile extends StatelessWidget {
  const _ActiveModTile({required this.mod, required this.validation});

  final ModInfo mod;
  final ModValidation? validation;

  @override
  Widget build(BuildContext context) {
    final ok =
        validation?.health == ModHealth.ok ||
        mod.compatible == VersionStatus.ok;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xff102524),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: VicColors.goldDark),
          ),
          child: SizedBox(
            width: 74,
            height: 74,
            child: Icon(
              mod.source == 'external'
                  ? Icons.public_outlined
                  : Icons.factory_outlined,
              color: VicColors.gold,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            mod.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: VicColors.parchment,
              fontSize: 18,
              height: 1.18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          ok ? Icons.check_circle_outline : Icons.error_outline,
          color: ok ? VicColors.tealBright : VicColors.danger,
        ),
      ],
    );
  }
}

class _LaunchCenter extends StatelessWidget {
  const _LaunchCenter({
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
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          width: 285,
          height: 285,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: VicColors.gold, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Image.asset('assets/brand/app_icon_256.png'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasErrors ? Icons.error_outline : Icons.circle,
              color: hasErrors ? VicColors.danger : VicColors.tealBright,
              size: 16,
            ),
            const SizedBox(width: 14),
            Text(readyText, style: vicTitle(context, size: 29)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          readyDetail,
          style: const TextStyle(color: VicColors.parchment, fontSize: 16),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GildedButton(label: 'START', large: true, onPressed: onLaunch),
        ),
        const SizedBox(height: 28),
        const ReadinessTimeline(),
        const Spacer(),
      ],
    );
  }
}

class ReadinessTimeline extends StatelessWidget {
  const ReadinessTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = ['DETECTING', 'REPAIRING', 'VALIDATING', 'READY'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _ReadinessStep(
            label: steps[i],
            ready: true,
            last: i == steps.length - 1,
          ),
          if (i != steps.length - 1)
            Container(width: 70, height: 1, color: const Color(0x8878522e)),
        ],
      ],
    );
  }
}

class _ReadinessStep extends StatelessWidget {
  const _ReadinessStep({
    required this.label,
    required this.ready,
    required this.last,
  });

  final String label;
  final bool ready;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: last ? const Color(0xff5b451c) : const Color(0xff064d48),
            border: Border.all(
              color: last ? VicColors.gold : VicColors.tealBright,
            ),
          ),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              last ? Icons.star : Icons.check,
              color: last ? const Color(0xffffdf7c) : VicColors.tealBright,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: last ? const Color(0xffffdf7c) : VicColors.parchment,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class LiveLogPanel extends StatelessWidget {
  const LiveLogPanel({super.key, required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return GildedPanel(
      title: 'Live log',
      trailing: Text(
        '${logs.length} entries',
        style: const TextStyle(color: VicColors.muted),
      ),
      child: ListView.builder(
        itemCount: logs.take(6).length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 8,
                    color: VicColors.tealBright,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    log,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VicColors.parchment,
                      fontFamily: 'Consolas',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
