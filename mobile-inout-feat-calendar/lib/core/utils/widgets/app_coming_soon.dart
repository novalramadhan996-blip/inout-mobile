import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class AppComingSoon extends StatelessWidget {
  const AppComingSoon({
    super.key,
    this.title,
    this.message = "Coming soon...",
    this.icon = Icons.construction,
  });

  final String? title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.greyColor),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: AppStyle.headline3,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppStyle(color: AppColors.greyFont).headline4,
          ),
        ],
      ),
    );
  }
}
