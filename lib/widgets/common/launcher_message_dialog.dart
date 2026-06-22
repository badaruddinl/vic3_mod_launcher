import 'package:flutter/material.dart';

import '../victoria_ui.dart';

Future<void> showLauncherMessageDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => VictoriaDialog(
      title: title,
      icon: Icons.info_outline,
      actions: [
        VictoriaDialogButton(
          label: 'OK',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: SelectableText(
        body,
        style: const TextStyle(color: VicColors.parchment, height: 1.35),
      ),
    ),
  );
}
