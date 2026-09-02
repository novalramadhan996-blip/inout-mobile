import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';

class AlarmService {
  static Future<void> scheduleAlarm({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
    int? alarmDistance,
  }) async {
    final scheduleDate = nextWeeklySchedule(
      weekday,
      hour,
      minute,
      alarmDistance,
    );

    LogHelper.logDebug('alarm scheduledate $scheduleDate');

    final id = int.parse("$weekday$hour$minute");

    AlarmSettings alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduleDate,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: false,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'notification_icon',
        iconColor: Color(0xff862778),
      ),
      payload: payload,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAll() async {
    await Alarm.stopAll();
  }

  static Future<void> cancel(int id) async {
    await Alarm.stop(id);
  }

  static DateTime nextWeeklySchedule(
    int weekday,
    int hour,
    int minute,
    int? alarmDistance,
  ) {
    final now = DateTime.now();

    final adjusted = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(minutes: alarmDistance ?? 0));

    final int finalHour = adjusted.hour;
    final int finalMinute = adjusted.minute;

    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      finalHour,
      finalMinute,
    );

    int diff = weekday - now.weekday;

    LogHelper.logDebug('alarm weekday $weekday');
    LogHelper.logDebug('alarm now weekday ${now.weekday}');
    LogHelper.logDebug('alarm diff $diff');

    if (scheduled.isBefore(now)) {
      diff += 7;
      LogHelper.logDebug('alarm diff +7 $diff');
    }

    return scheduled.add(Duration(days: diff));
  }
}
