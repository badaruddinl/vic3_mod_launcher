import 'package:flutter/material.dart';

import '../../models.dart';
import '../victoria_ui.dart';

Future<bool?> showUpdateAvailableDialog(
  BuildContext context,
  UpdateCheckResult result,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => VictoriaDialog(
      title: 'Update ${result.latest.label} tersedia',
      icon: Icons.system_update_alt,
      maxWidth: 560,
      actions: [
        VictoriaDialogButton(
          label: 'Later',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        VictoriaDialogButton(
          label: 'Install',
          icon: Icons.download_outlined,
          primary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: SingleChildScrollView(
          child: SelectableText(
            [
              'Current: ${result.current.label}',
              'Latest: ${result.latest.label}',
              if (result.latest.publishedAt != null)
                'Published: ${result.latest.publishedAt!.toLocal()}',
              '',
              result.latest.notes.isEmpty
                  ? 'Tidak ada release notes.'
                  : result.latest.notes,
            ].join('\n'),
            style: const TextStyle(color: VicColors.parchment, height: 1.35),
          ),
        ),
      ),
    ),
  );
}

Future<String?> showUpdateSourceDialog(
  BuildContext context, {
  required String initialValue,
}) async {
  final controller = TextEditingController(text: initialValue);
  final value = await showDialog<String>(
    context: context,
    builder: (context) => VictoriaDialog(
      title: 'Update Source',
      icon: Icons.link,
      maxWidth: 620,
      actions: [
        VictoriaDialogButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        VictoriaDialogButton(
          label: 'Save',
          primary: true,
          onPressed: () => Navigator.of(context).pop(controller.text),
        ),
      ],
      child: SizedBox(
        width: 560,
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Manifest URL or local file path',
            helperText:
                'Example: https://.../latest.json or D:\\path\\latest.json',
          ),
          maxLines: 2,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
      ),
    ),
  );
  controller.dispose();
  return value;
}

class UpdateDownloadProgressDialog {
  StateSetter? _setState;
  var _received = 0;
  int? _total;

  void show(BuildContext context, UpdateInfo update) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          _setState = setState;
          final progress = _total == null || _total == 0
              ? null
              : _received / _total!;
          return VictoriaDialog(
            title: 'Downloading ${update.label}',
            icon: Icons.download_outlined,
            maxWidth: 460,
            actions: const [],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text(
                  _progressLabel,
                  style: const TextStyle(color: VicColors.parchment),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void update(int received, int? total) {
    _received = received;
    _total = total;
    _setState?.call(() {});
  }

  String get _progressLabel {
    final receivedMb = (_received / 1024 / 1024).toStringAsFixed(1);
    final total = _total;
    if (total == null) return '$receivedMb MB';
    final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
    return '$receivedMb / $totalMb MB';
  }
}
