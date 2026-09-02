import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/feature/auth/sign_in/sign_in_page.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:auto_route/auto_route.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await notif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final GlobalKey<NavigatorState> navigatorKey =
        sl<GlobalKey<NavigatorState>>();

    await notif.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final context = navigatorKey.currentState?.context;

        if (context == null) {
          return;
        }

        switch (response.actionId) {
          case 'checkin':
            LogHelper.logDebug('masuk checkin');
            AutoRouter.of(context).push(const CheckInRoute());
            break;

          default:
            LogHelper.logDebug("Normal notification tap");
        }
      },
    );
  }

  static Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? channel,
    String? descChannel,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    int id = math.Random().nextInt(10000);

    await notif.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel ?? 'daily_channel',
          descChannel ?? 'Daily Notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'open_action', // ID untuk identifikasi tombol
              'Open',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'dismiss_action',
              'Dismiss',
              cancelNotification: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_notif',
    );
  }

  static Future<void> scheduleWeekly({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? channel,
    String? descChannel,
    int delayMinutes = 0,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // cari hari yang cocok (weekday)
    while (scheduleDate.weekday != weekday || scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    // tambahkan DELAY (bisa minus)
    scheduleDate = scheduleDate.add(Duration(minutes: delayMinutes));

    int id = math.Random().nextInt(100000);

    await notif.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel ?? 'weekly_channel',
          descChannel ?? 'Weekly Notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'checkin',
              'Check In',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_notif',
    );
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? channel,
    String? descChannel,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel ?? 'instant_channel',
      descChannel ?? 'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    int id = math.Random().nextInt(10000);

    await notif.show(id, title, body, platformDetails, payload: 'instant');
  }

  static Future<void> cancelAll() async {
    await notif.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await notif.cancel(id);
  }

  static Future<void> askNotificationPermission() async {
    await Permission.notification.request();
  }

  static Future<void> logScheduledNotif() async {
    final plugin = NotificationService.notif;

    final pending = await plugin.pendingNotificationRequests();

    for (var p in pending) {
      LogHelper.logDebug(
        "debug -> ID: ${p.id}, title: ${p.title}, body: ${p.body}, payload: ${p.payload}",
      );
    }
  }
}
