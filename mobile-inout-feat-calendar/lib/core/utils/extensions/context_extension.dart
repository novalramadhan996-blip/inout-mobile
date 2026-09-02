import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // get screen width's size
  double get screenWidth => MediaQuery.of(this).size.width;

  // get screen height's size
  double get screenHeight => MediaQuery.of(this).size.height;
}