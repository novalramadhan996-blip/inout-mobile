// ignore_for_file: deprecated_member_use

import 'package:auto_route/auto_route.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: GestureDetector(
            onDoubleTap: () {
              // Debugging Escape
              if (kDebugMode || kProfileMode) Navigator.of(context).pop();
            },
            child: SimpleDialog(
              backgroundColor: Colors.black54,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator().bottomPadded(10),
                      Text(
                        "Loading",
                        style: AppTheme.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static dismissDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void confirmDialog(
    context, {
    String? title,
    String? message,
    String? positiveLabel,
    String? negativeLabel,
    Function? dialogCallback,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ''),
          content: Text(message ?? ''),
          actions: [
            TextButton(
              child: Text(negativeLabel ?? "Cancel"),
              onPressed: () => context.pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryColor, width: 1),
              ),
              child: Text(positiveLabel ?? "Yes"),
              onPressed: () {
                context.pop();
                dialogCallback?.call();
              },
            ),
          ],
        );
      },
    );
  }
}
