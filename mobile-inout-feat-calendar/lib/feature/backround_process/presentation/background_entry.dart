import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/config/app_config.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_service.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_task.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    try {
      await service.setForegroundNotificationInfo(
        title: "Service berjalan",
        content: "Tracking lokasi aktif",
      );
    } catch (e) {
      // Android 14+ may block startForeground from background context
      // Error is non-fatal; service continues running without notification
    }
  }

  await dotenv.load(fileName: AppConfig.envFileName);

  BackgroundService.initializeDI();

  BackgroundTasks.startTracking(service);
  BackgroundTasks.taskUpdateToken(service);

  final timer = Timer.periodic(const Duration(minutes: 1), (event) async {
    if (service is AndroidServiceInstance) {
      try {
        await service.setForegroundNotificationInfo(
          title: "Service berjalan",
          content: "Tracking lokasi aktif",
        );
      } catch (e) {
        // Silently handle Android 14+ foreground restriction
      }
    }
  });

  service.on('destroy').listen((event) {
    timer.cancel();
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
