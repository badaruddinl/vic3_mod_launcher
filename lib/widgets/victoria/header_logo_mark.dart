import 'package:flutter/material.dart';

class VictoriaLogoMark extends StatelessWidget {
  const VictoriaLogoMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset('assets/brand/app_icon_256.png'),
    );
  }
}
