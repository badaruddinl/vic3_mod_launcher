import 'package:flutter/material.dart';

import '../victoria_ui.dart';

class LaunchEmblem extends StatelessWidget {
  const LaunchEmblem({super.key, this.size = 196});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: VicColors.gold, width: 2),
          gradient: const RadialGradient(
            colors: [Color(0xff0e4b45), Color(0xff071314)],
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 18, spreadRadius: 1),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.1),
          child: Image.asset('assets/brand/app_icon_256.png'),
        ),
      ),
    );
  }
}
