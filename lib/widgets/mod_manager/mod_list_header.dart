import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ModListHeader extends StatelessWidget {
  const ModListHeader({super.key, required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x8878522e))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: vicLabel(context, size: 12))),
          _CountPill(count: count),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff073f3b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VicColors.goldDark),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          '$count',
          style: const TextStyle(
            color: VicColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
