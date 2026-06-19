import 'package:flutter/material.dart';

import '../models.dart';
import '../services/launcher_config.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.config,
    required this.dlcs,
    required this.disabledDlcs,
    required this.logs,
    required this.playsets,
    required this.onToggleDlc,
    required this.onEnableAllDlc,
    required this.onAddExtraRoot,
    required this.onRemoveExtraRoot,
    required this.onSavePlaysetAs,
    required this.onLoadPlayset,
    required this.onDeletePlayset,
  });

  final LauncherConfig config;
  final List<DlcInfo> dlcs;
  final Set<String> disabledDlcs;
  final List<String> logs;
  final List<SavedPlayset> playsets;
  final ValueChanged<DlcInfo> onToggleDlc;
  final VoidCallback onEnableAllDlc;
  final VoidCallback onAddExtraRoot;
  final ValueChanged<String> onRemoveExtraRoot;
  final VoidCallback onSavePlaysetAs;
  final ValueChanged<SavedPlayset> onLoadPlayset;
  final ValueChanged<SavedPlayset> onDeletePlayset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _Panel(
              title: 'DLC',
              trailing: TextButton(
                onPressed: onEnableAllDlc,
                child: const Text('Enable all'),
              ),
              child: ListView.builder(
                itemCount: dlcs.length,
                itemBuilder: (context, index) {
                  final dlc = dlcs[index];
                  final enabled = !disabledDlcs.contains(dlc.ref.toLowerCase());
                  return CheckboxListTile(
                    dense: true,
                    value: enabled,
                    onChanged: (_) => onToggleDlc(dlc),
                    title: Text(
                      dlc.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      dlc.ref,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: _Panel(
              title: 'Playsets',
              trailing: IconButton(
                onPressed: onSavePlaysetAs,
                icon: const Icon(Icons.save_as_outlined),
                tooltip: 'Save current playset',
              ),
              child: ListView(
                children: [
                  for (final playset in playsets)
                    ListTile(
                      dense: true,
                      title: Text(
                        playset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        playset.modifiedAt.toLocal().toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onLoadPlayset(playset),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDeletePlayset(playset),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: _Panel(
              title: 'Folder mod tambahan',
              trailing: IconButton(
                onPressed: onAddExtraRoot,
                icon: const Icon(Icons.add),
                tooltip: 'Tambah folder',
              ),
              child: ListView(
                children: [
                  for (final root in config.extraModRoots)
                    ListTile(
                      dense: true,
                      title: Text(
                        root,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => onRemoveExtraRoot(root),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 3,
            child: _Panel(
              title: 'Log',
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: SelectableText(
                    logs[index],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
