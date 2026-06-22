import 'package:flutter/material.dart';

import '../victoria_ui.dart';
import 'mod_list_header.dart';

class ModListFrame extends StatelessWidget {
  const ModListFrame({
    super.key,
    required this.title,
    required this.count,
    required this.child,
  });

  final String title;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc071314),
        border: Border.all(color: VicColors.goldDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ModListHeader(title: title, count: count),
          Expanded(child: child),
        ],
      ),
    );
  }
}
