import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoData {
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  static Future<String?> getId() async {
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    }

    return null;
  }

  static Future<String?> getInfo() async {
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.systemName;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.manufacturer;
    }

    return null;
  }

  static Future<String?> getAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.version.release;
    }

    return null;
  }
}
