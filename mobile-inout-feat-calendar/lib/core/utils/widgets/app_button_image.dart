import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/dimension.dart';

class AppButtonImage extends StatelessWidget {
  final String buttonName;
  final String iconPng;
  final bool isLoading;
  final Color backgroundColor;

  final void Function()? onPress;
  const AppButtonImage({
    super.key,
    required this.buttonName,
    required this.iconPng,
    this.isLoading = false,
    this.onPress,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size.fromHeight(Dimension.heightButton),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimension.rounded),
        ),
      ),
      onPressed: !isLoading ? onPress : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            iconPng,
            width: 30,
          ),
          Text(
            buttonName,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: isLoading ? const CircularProgressIndicator() : null,
          )
        ],
      ),
    );
  }
}
