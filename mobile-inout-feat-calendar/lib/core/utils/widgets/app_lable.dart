import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';

class AppLabel extends StatelessWidget {
  const AppLabel({
    super.key,
    this.label = "",
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: AppTheme.bodyText.copyWith(
                color: AppColors.secondaryColor,
                fontSize: 15,
              ),
            ),
            isRequired
                ? TextSpan(
                    text: " *",
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.redColors,
                      fontSize: 15,
                    ),
                  )
                : const TextSpan(),
          ],
        ),
      ),
    );
  }
}
