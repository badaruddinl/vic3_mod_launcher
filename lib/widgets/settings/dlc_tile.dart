import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'victoria_toggle.dart';

class DlcTile extends StatelessWidget {
  const DlcTile({
    super.key,
    required this.dlc,
    required this.enabled,
    required this.onToggle,
  });

  final DlcInfo dlc;
  final bool enabled;
  final ValueChanged<DlcInfo> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? const Color(0x44102121) : const Color(0x332a2825),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? const Color(0x8878522e) : VicColors.goldDark,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onToggle(dlc),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: VicColors.gold,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: DlcTileText(dlc: dlc)),
                  const SizedBox(width: 12),
                  VictoriaToggle(
                    value: enabled,
                    onChanged: (_) => onToggle(dlc),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DlcTileText extends StatelessWidget {
  const DlcTileText({super.key, required this.dlc});

  final DlcInfo dlc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dlc.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: VicColors.parchment,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          dlc.ref,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class DlcEmptyState extends StatelessWidget {
  const DlcEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No local DLC metadata found.',
        style: TextStyle(color: VicColors.muted),
      ),
    );
  }
}
