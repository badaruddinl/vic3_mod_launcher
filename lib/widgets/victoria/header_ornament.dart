import 'package:flutter/material.dart';

import 'theme.dart';

class VictoriaHeaderOrnament extends StatelessWidget {
  const VictoriaHeaderOrnament({super.key, this.width = 250});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: const [
          Expanded(child: _OrnamentLine()),
          SizedBox(width: 8),
          _OrnamentDiamond(),
          SizedBox(width: 8),
          Expanded(child: _OrnamentLine()),
        ],
      ),
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  const _OrnamentLine();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, VicColors.goldDark, Colors.transparent],
        ),
      ),
      child: SizedBox(height: 1),
    );
  }
}

class _OrnamentDiamond extends StatelessWidget {
  const _OrnamentDiamond();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: VicColors.goldDark,
          border: Border.all(color: VicColors.gold, width: 0.7),
        ),
        child: const SizedBox.square(dimension: 7),
      ),
    );
  }
}
