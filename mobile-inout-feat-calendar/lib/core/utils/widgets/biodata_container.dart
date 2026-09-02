import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class BiodataContainer extends StatelessWidget {
  final Widget child;

  const BiodataContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.greyColor.withOpacity(0.3),
        border: Border.all(
          width: 1,
          color: AppColors.greyButtonColor.withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}
