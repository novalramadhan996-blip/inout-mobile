import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GlobalUtils {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static String dateToString(Timestamp? timestamp) {
    final DateTime now = DateTime.now();
    final DateTime date = timestamp != null ? timestamp.toDate() : now;

    final Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static String dateConversation(Timestamp? timestamp) {
    final DateTime now = DateTime.now();
    final DateTime date = timestamp != null ? timestamp.toDate() : now;

    DateTime dateNow = DateTime(now.year, now.month, now.day);
    DateTime dateCurrent = DateTime(date.year, date.month, date.day);

    log('timestamp ${timestamp?.toDate()}');
    log('different $dateNow VS $dateCurrent');

    if (dateNow.difference(dateCurrent).inDays == 0) {
      return 'Today';
    } else if (dateNow.difference(dateCurrent).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static bool isSameDate(Timestamp? tempDate, Timestamp? currentDate) {
    final DateTime tempDateData =
        tempDate != null ? tempDate.toDate() : DateTime.now();
    final DateTime currentDateData =
        currentDate != null ? currentDate.toDate() : DateTime.now();

    final String tempDateFormat = DateFormat('dd/MM/yyyy').format(tempDateData);
    final String currentDateFormat =
        DateFormat('dd/MM/yyyy').format(currentDateData);

    if (tempDateFormat == currentDateFormat) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> showNotification(
      String title, String body, String channelId, String channelName,
      {int? badgeCount}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics;
    if (badgeCount != null) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        number: badgeCount,
      );
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      );
    }

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    int id = math.Random().nextInt(1000000);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> clearNotification() async {
    bool isAppBadge = await FlutterAppBadger.isAppBadgeSupported();

    await flutterLocalNotificationsPlugin.cancelAll();

    if (isAppBadge) {
      FlutterAppBadger.removeBadge();
    }
  }

  static Future<void> downloadFile(String url, String fileName) async {
    try {
      await Permission.manageExternalStorage.request();
      await Permission.notification.request();

      Dio dio = Dio();

      Directory? directory = Directory("/storage/emulated/0/Download");
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      String filePath = "${directory?.path}/$fileName";

      File file = File(filePath);
      if (await file.exists()) {
        // await file.delete();
        await file.delete(recursive: true);
        log("File lama dihapus: $filePath");

        await Future.delayed(const Duration(seconds: 1));
      }

      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          log("Download Progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      });

      log("Download selesai: $filePath");

      String filePathName = "Download/$fileName";

      await showNotification(
          "Download Selesai",
          "File tersimpan di $filePathName",
          'download_channel',
          'Download Notifications');
    } catch (e) {
      log("Download gagal: $e");
    }
  }
}
