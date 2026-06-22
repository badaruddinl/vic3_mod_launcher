import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';
import 'saved_playset_card.dart';

class SavedPlaysetsStrip extends StatelessWidget {
  const SavedPlaysetsStrip({
    super.key,
    required this.playsets,
    required this.onLoadPlayset,
    required this.onDeletePlayset,
  });

  final List<SavedPlayset> playsets;
  final ValueChanged<SavedPlayset> onLoadPlayset;
  final ValueChanged<SavedPlayset> onDeletePlayset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 126,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: GildedPanel(
          title: 'Saved playsets',
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: playsets.isEmpty
              ? const SavedPlaysetsEmptyState()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: playsets.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) => SavedPlaysetCard(
                    playset: playsets[index],
                    onLoad: onLoadPlayset,
                    onDelete: onDeletePlayset,
                  ),
                ),
        ),
      ),
    );
  }
}

class SavedPlaysetsEmptyState extends StatelessWidget {
  const SavedPlaysetsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No saved playsets yet',
        style: TextStyle(color: VicColors.muted),
      ),
    );
  }
}
