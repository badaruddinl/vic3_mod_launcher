import 'package:flutter/material.dart';

import '../victoria_ui.dart';
import 'log_entry_row.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: logs.isEmpty
          ? const EmptyLogState()
          : ListView.builder(
              itemCount: logs.take(6).length,
              itemBuilder: (context, index) =>
                  LogEntryRow(message: logs[index]),
            ),
    );
  }
}
