import 'package:flutter/material.dart';

import '../victoria_ui.dart';

Future<String?> showSavePlaysetDialog(BuildContext context) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => VictoriaDialog(
      title: 'Save Playset',
      icon: Icons.bookmark_add_outlined,
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
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Playset name'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
    ),
  );
  controller.dispose();
  return name;
}
