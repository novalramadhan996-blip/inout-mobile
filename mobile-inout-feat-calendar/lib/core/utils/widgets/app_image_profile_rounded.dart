import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class AppImageProfileRounded extends StatelessWidget {
  final String? profileUrl;
  final String initialName;
  final double width;
  final double height;
  final double? initialNameSize;
  final bool? isBorder;

  const AppImageProfileRounded({
    super.key,
    this.profileUrl,
    required this.initialName,
    required this.width,
    required this.height,
    this.initialNameSize,
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(999),
        border: isBorder == true ? Border.all(
          color: Colors.white, // warna border
          width: 1, // ukuran border di sini
        ) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: 
        profileUrl != null && profileUrl != '' ?
          Image.network(
            profileUrl ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: Text(
                    initialName,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                )
              );
            }
          )
        : SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Text(
                initialName,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: initialNameSize ?? 20
                ),
              ),
            )
          )
      ));
  }
}