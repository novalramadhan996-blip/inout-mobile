import 'package:flutter/material.dart';

extension PaddingWidget on Widget {
  Widget paddedLTRB({
    double left = 16,
    double top = 16,
    double right = 16,
    double bottom = 16,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: this,
    );
  }

  Widget topPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.only(top: value.toDouble()),
      child: this,
    );
  }

  Widget bottomPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.only(bottom: value.toDouble()),
      child: this,
    );
  }

  Widget leftPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.only(left: value.toDouble()),
      child: this,
    );
  }

  Widget rightPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.only(right: value.toDouble()),
      child: this,
    );
  }

  Widget horizontalPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value.toDouble()),
      child: this,
    );
  }

  Widget verticalPadded([final value = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value.toDouble()),
      child: this,
    );
  }
}
