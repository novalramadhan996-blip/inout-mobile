import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/dimension.dart';

class AppButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onPress;

  final bool isLoading;
  final Color color;
  final bool isButtonOutline;
  final bool isDisabled;

  // NEW: icon param
  final IconData? icon;
  final double iconSize;
  final double width;

  const AppButton({
    super.key,
    required this.buttonName,
    required this.onPress,
    this.color = AppColors.primaryColor,
    this.isLoading = false,
    this.isButtonOutline = false,
    this.isDisabled = false,
    this.icon,
    this.iconSize = 22,
    this.width = double.infinity,
  });

  factory AppButton.outline({
    required String buttonName,
    required VoidCallback? onPress,
    bool isLoading = false,
    Color backgroundColor = AppColors.whiteColor,
    bool isDisabled = false,
    IconData? icon,
    double iconSize = 22,
    double width = double.infinity,
  }) {
    return AppButton(
      buttonName: buttonName,
      onPress: onPress,
      isLoading: isLoading,
      color: backgroundColor,
      isButtonOutline: true,
      isDisabled: isDisabled,
      icon: icon,
      iconSize: iconSize,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disabledState = isLoading || isDisabled;

    final Color backgroundColor = disabledState ? AppColors.greyColor : color;

    final Color textColor = isButtonOutline
        ? (disabledState ? AppColors.greyColor : AppColors.primaryColor)
        : Colors.white;

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: isButtonOutline ? backgroundColor : color,
      foregroundColor: isButtonOutline ? AppColors.primaryColor : Colors.white,
      minimumSize: Size.fromHeight(Dimension.heightButton),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.rounded),
        side: isButtonOutline
            ? const BorderSide(color: AppColors.primaryColor, width: 1)
            : BorderSide.none,
      ),
    );

    // Loading state
    if (isLoading) {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          style: style,
          onPressed: null,
          child: const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    // Normal state (with icon / without icon)
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: style,
        onPressed: disabledState ? null : onPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              buttonName,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
