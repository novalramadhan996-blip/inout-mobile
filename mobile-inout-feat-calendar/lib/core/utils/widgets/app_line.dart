import 'package:flutter/material.dart';

class AppLine extends StatelessWidget {
  const AppLine({
    super.key,
    this.height = 2,
    this.width = double.infinity,
    this.color = Colors.grey,
  });

  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ColoredBox(color: color ?? Colors.grey),
    );
  }
}
