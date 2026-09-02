import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class ContainerWithBorder extends StatelessWidget {
  final double width, height, radiusBorder, marginTop, marginBottom;
  final Widget widget;

  const ContainerWithBorder({
    super.key,
    required this.width,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.height = 0,
    required this.radiusBorder,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blackColor),
        borderRadius: BorderRadius.circular(radiusBorder),
      ),
      child: widget,
    );
  }
}
