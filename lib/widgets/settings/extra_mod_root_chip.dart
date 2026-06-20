import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class ExtraModRootChip extends StatelessWidget {
  const ExtraModRootChip({
    super.key,
    required this.root,
    required this.onRemove,
  });

  final String root;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x66101f20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x5578522e)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  root,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: VicColors.parchment,
                    fontSize: 12.5,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 17),
                color: VicColors.muted,
                onPressed: () => onRemove(root),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
