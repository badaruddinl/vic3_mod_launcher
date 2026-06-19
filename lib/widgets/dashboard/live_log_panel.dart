import 'package:flutter/material.dart';

import '../victoria_ui.dart';

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
                    size: 7,
                    color: VicColors.tealBright,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    log,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VicColors.parchment,
                      fontFamily: 'Consolas',
                      fontSize: 13,
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
