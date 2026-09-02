import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class Indicator extends StatelessWidget {
  final int index;
  final int selectedBody;

  const Indicator({
    super.key,
    required this.index,
    required this.selectedBody,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: selectedBody >= index
              ? AppColors.whiteColor
              : AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
