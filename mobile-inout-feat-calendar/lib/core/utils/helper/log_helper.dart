import 'dart:developer';
import 'package:flutter/foundation.dart';

class LogHelper {
  static Future<void> logDebug(String logger) async {
    if (kReleaseMode) {
      // debugPrint(logger);
    } else {
      log(logger);
    }
  }
}
