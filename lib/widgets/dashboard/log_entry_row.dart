import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class LogEntryRow extends StatelessWidget {
  const LogEntryRow({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 7, color: VicColors.tealBright),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
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
  }
}

class EmptyLogState extends StatelessWidget {
  const EmptyLogState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Waiting for launcher activity',
        style: TextStyle(color: VicColors.muted),
      ),
    );
  }
}
