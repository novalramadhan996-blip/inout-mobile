// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: const ColorScheme(
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          surface: AppColors.whiteColor,
          background: AppColors.whiteColor,
          error: AppColors.redColors,
          onPrimary: AppColors.whiteColor,
          onSecondary: AppColors.whiteColor,
          onSurface: Colors.black,
          onBackground: AppColors.whiteColor,
          onError: AppColors.whiteColor,
          brightness: Brightness.light,
        ),
      );

  // Part
  static TextStyle get heading5 => GoogleFonts.nunito(
        fontSize: 23,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get heading6 => GoogleFonts.nunito(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get subtitle => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyText => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );


}

extension DarkMode on BuildContext {
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}
