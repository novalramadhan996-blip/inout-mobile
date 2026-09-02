import 'package:flutter/material.dart';

class DialogWidget {
  static void progressBar(context, {String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Wrap(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 60,
                  ),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                    height: 60,
                  ),
                  Text(
                    message ?? 'Please wait...',
                    //style: Styles.progressBarTitleTextStyle,
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  static void confirmDialog(
    context, {
    String? message,
    String? positiveLabel,
    String? negativeLabel,
    Function(String)? dialogCallback,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message ?? ''),
          actions: [
            TextButton(
              child: Text(negativeLabel ?? "Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                if (dialogCallback != null) {
                  dialogCallback("Cancel");
                }
              },
            ),
            TextButton(
              child: Text(positiveLabel ?? "Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                if (dialogCallback != null) {
                  dialogCallback("Yes");
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void alertDialog(context, message, {Function()? dialogCallback}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message ?? ''),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                if (dialogCallback != null) {
                  dialogCallback();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void displaySnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      //content: Text('Not implemented, pull request is welcome 👏👏🍺🍺'),
      content: Text(message),
    ));
  }
}
