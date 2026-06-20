import 'package:flutter/material.dart';

import '../dashboard/log_entry_row.dart';
import '../victoria_ui.dart';

class LogsSettingsTab extends StatelessWidget {
  const LogsSettingsTab({super.key, required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GildedPanel(
        title: 'Logs',
        trailing: Text(
          '${logs.length} entries',
          style: const TextStyle(color: VicColors.muted, fontSize: 12),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: logs.isEmpty
            ? const EmptyLogState()
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) =>
                    LogEntryRow(message: logs[index]),
              ),
      ),
    );
  }
}
