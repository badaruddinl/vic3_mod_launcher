import 'package:flutter/material.dart';

import '../../models.dart';
import '../common/ellipsis_tooltip_text.dart';
import '../victoria_ui.dart';

class SavedPlaysetCard extends StatelessWidget {
  const SavedPlaysetCard({
    super.key,
    required this.playset,
    required this.onLoad,
    required this.onDelete,
  });

  final SavedPlayset playset;
  final ValueChanged<SavedPlayset> onLoad;
  final ValueChanged<SavedPlayset> onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 246,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x99101f20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: VicColors.goldDark),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onLoad(playset),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
              child: Row(
                children: [
                  const Icon(Icons.bookmark_outline, color: VicColors.gold),
                  const SizedBox(width: 10),
                  Expanded(child: _SavedPlaysetText(playset: playset)),
                  IconButton(
                    tooltip: 'Delete playset',
                    icon: const Icon(Icons.delete_outline),
                    color: VicColors.muted,
                    onPressed: () => onDelete(playset),
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

class _SavedPlaysetText extends StatelessWidget {
  const _SavedPlaysetText({required this.playset});

  final SavedPlayset playset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllipsisTooltipText(
          playset.name,
          style: const TextStyle(
            color: VicColors.parchment,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        EllipsisTooltipText(
          playset.modifiedAt.toLocal().toString(),
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
