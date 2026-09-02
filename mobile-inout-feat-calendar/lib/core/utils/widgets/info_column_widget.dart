import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  final String imagePath;
  final String time;
  final String label;
  final EdgeInsets? margin;

  const InfoColumn({super.key, required this.imagePath, required this.time, required this.label, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 32),
          const SizedBox(height: 10),
          Text(time, style: AppTheme.bodyText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(label, style: AppTheme.bodyText.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}