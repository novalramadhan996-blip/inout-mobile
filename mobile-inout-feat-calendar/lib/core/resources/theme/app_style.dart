import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class AppStyle {
  final Color color;
  final FontWeight? weight;
  AppStyle({required this.color, this.weight});
  static TextStyle headline1 = const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryColor,
  );
  static TextStyle headline3 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );
  static TextStyle link = const TextStyle(
    fontSize: 18,
    color: Colors.blue,
  );
  TextStyle get headline2 => subtitle2.copyWith(color: color, fontWeight: weight);
  TextStyle get headline4 => subtitle4.copyWith(color: color, fontWeight: weight);
}

// Font Weight
const FontWeight superBold = FontWeight.w900;
const FontWeight bold = FontWeight.bold;
const FontWeight semiBold = FontWeight.w600;
const FontWeight mediumBold = FontWeight.w500;
const FontWeight normalBold = FontWeight.normal;
const FontWeight regularBold = FontWeight.w400;

//TextStyle FontSize
const TextStyle title1 = TextStyle(fontSize: 40);
const TextStyle title2 = TextStyle(fontSize: 34);
const TextStyle title3 = TextStyle(fontSize: 30);
const TextStyle title4 = TextStyle(fontSize: 28);

const TextStyle subtitle1 = TextStyle(fontSize: 24);
const TextStyle subtitle2 = TextStyle(fontSize: 20);
const TextStyle subtitle3 = TextStyle(fontSize: 18);
const TextStyle subtitle4 = TextStyle(fontSize: 16);

const TextStyle body1 = TextStyle(fontSize: 14);
const TextStyle body2 = TextStyle(fontSize: 13);
const TextStyle body3 = TextStyle(fontSize: 11);
const TextStyle small = TextStyle(fontSize: 9);
const TextStyle verySmall = TextStyle(fontSize: 8);
