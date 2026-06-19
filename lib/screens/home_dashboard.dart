import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
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
                  const SizedBox(width: 18),
                  const VictoriaWindowButtons(),
                ],
              ),
            ),
            VictoriaHeaderMark(gameVersion: gameVersion),
            const SizedBox(height: 18),
            Expanded(
              child: _HeroStage(
                activeMods: activeMods,
                validations: validations,
                readyText: readyText,
                readyDetail: readyDetail,
                hasErrors: hasErrors,
                onLaunch: onLaunch,
              ),
            ),
            const SizedBox(height: 8),
            const ReadinessTimeline(),
            const SizedBox(height: 18),
            SizedBox(height: 218, child: LiveLogPanel(logs: logs)),
          ],
        ),
      ),
    );
  }
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 740) {
          return Column(
            children: [
              Expanded(
                child: ActiveModsPreview(
                  activeMods: activeMods,
                  validations: validations,
                ),
              ),
              const SizedBox(height: 14),
              _LaunchCenter(
                readyText: readyText,
                readyDetail: readyDetail,
                hasErrors: hasErrors,
                onLaunch: onLaunch,
              ),
            ],
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 26,
              bottom: 28,
              child: SizedBox(
                width: 286,
                child: ActiveModsPreview(
                  activeMods: activeMods,
                  validations: validations,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 180),
              child: _LaunchCenter(
                readyText: readyText,
                readyDetail: readyDetail,
                hasErrors: hasErrors,
                onLaunch: onLaunch,
              ),
            ),
          ],
        );
      },
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
          if (preview.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No active mods',
                  style: TextStyle(color: VicColors.muted),
                ),
              ),
            )
          else
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 222,
          height: 222,
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
              padding: const EdgeInsets.all(22),
              child: Image.asset('assets/brand/app_icon_256.png'),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasErrors ? Icons.error_outline : Icons.circle,
              color: hasErrors ? VicColors.danger : VicColors.tealBright,
              size: 16,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(readyText, style: vicTitle(context, size: 27)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          readyDetail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VicColors.parchment,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GildedButton(label: 'START', large: true, onPressed: onLaunch),
        ),
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
            Container(width: 62, height: 1, color: const Color(0x8878522e)),
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
