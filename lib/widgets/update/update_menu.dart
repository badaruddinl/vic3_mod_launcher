import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/app_logger.dart';
import '../victoria_ui.dart';

class LauncherUpdateMenu extends StatelessWidget {
  const LauncherUpdateMenu({
    super.key,
    required this.checking,
    required this.availableUpdate,
    required this.onCheck,
    required this.onViewUpdate,
    required this.onEditSource,
  });

  final bool checking;
  final UpdateCheckResult? availableUpdate;
  final VoidCallback onCheck;
  final VoidCallback onViewUpdate;
  final VoidCallback onEditSource;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Updates',
      icon: UpdateStatusIcon(
        checking: checking,
        hasUpdate: availableUpdate != null,
      ),
      onSelected: (value) {
        if (value == 'check') onCheck();
        if (value == 'view' && availableUpdate != null) onViewUpdate();
        if (value == 'source') onEditSource();
        if (value == 'logs') AppLogger.openDirectory();
      },
      itemBuilder: (context) => [
        if (availableUpdate != null)
          PopupMenuItem(
            value: 'view',
            child: ListTile(
              leading: const Icon(Icons.system_update),
              title: Text('Update ${availableUpdate!.latest.label}'),
            ),
          ),
        const PopupMenuItem(
          value: 'check',
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Check for Updates'),
          ),
        ),
        const PopupMenuItem(
          value: 'source',
          child: ListTile(
            leading: Icon(Icons.link),
            title: Text('Update Source'),
          ),
        ),
        const PopupMenuItem(
          value: 'logs',
          child: ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Open Logs'),
          ),
        ),
      ],
    );
  }
}

class UpdateStatusIcon extends StatelessWidget {
  const UpdateStatusIcon({
    super.key,
    required this.checking,
    required this.hasUpdate,
  });

  final bool checking;
  final bool hasUpdate;

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: VicColors.gold),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.system_update_alt, color: VicColors.gold),
        if (hasUpdate)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
