import 'package:flutter/material.dart';

class EllipsisTooltipText extends StatelessWidget {
  const EllipsisTooltipText(
    this.data, {
    super.key,
    this.tooltip,
    this.style,
    this.maxLines = 1,
    this.textAlign,
    this.softWrap,
  });

  final String data;
  final String? tooltip;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? data,
      waitDuration: const Duration(milliseconds: 450),
      child: Text(
        data,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        softWrap: softWrap,
        style: style,
      ),
    );
  }
}
