import 'dart:async';
import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/geofance_checkin.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundTasks {
  static Timer? _timer;
  static final Constraints _constraints = Constraints(
    networkType: NetworkType.connected, // Requires network connectivity
    requiresCharging: false, // Requires the device to be charging
    requiresBatteryNotLow: false, // Requires battery level to be not low
    requiresStorageNotLow: false, // Requires sufficient storage space
  );

  static void startTracking(ServiceInstance service) {
    service.on("startTaskTrackingLocation").listen((event) async {
      final token = event?["token"] ?? '';

      if (token.isEmpty) return;

      await GeofanceCheckin.fetchEmployeeDetailInBackground();

      _timer?.cancel();
      _timer = Timer.periodic(Duration(minutes: AppConst.backgroundPeriode), (
        _,
      ) {
        GeofanceCheckin.fetchEmployeeDetailInBackground();
      });
    });
  }

  static void taskUpdateToken(ServiceInstance service) async {
    service.on("taskUpdateToken").listen((event) async {
      if (event == null) {
        LogHelper.logDebug("Debug -> main_common : event null, skip");
        return;
      }

      final updatedToken = event["token"];
      LogHelper.logDebug(
        "Debug -> main_common : Token received: $updatedToken",
      );

      // --- VALIDATION TOKEN ---
      if (updatedToken == null || updatedToken.toString().trim().isEmpty) {
        LogHelper.logDebug(
          "Debug -> main_common : Token kosong, skip register background task",
        );
        return;
      }

      // --- CANCEL OLD TASKS ---
      try {
        LogHelper.logDebug(
          "Debug -> main_common : Cancel all background tasks...",
        );
        await Workmanager().cancelAll();
      } catch (e) {
        LogHelper.logDebug("Debug -> main_common : Error cancelAll -> $e");
      }

      // --- REGISTER NEW TASK ---
      try {
        LogHelper.logDebug("Debug -> main_common : Register periodic task...");
        await Workmanager().registerPeriodicTask(
          "task_location_update",
          "backgroundTask",
          frequency: Duration(minutes: AppConst.schedulePeriode),
          constraints: _constraints,
          inputData: {"token": updatedToken},
        );

        LogHelper.logDebug(
          "Debug -> main_common : Background task registered with token: $updatedToken",
        );
      } catch (e) {
        LogHelper.logDebug(
          "Debug -> main_common : Error registerPeriodicTask -> $e",
        );
      }
    });
  }
}
