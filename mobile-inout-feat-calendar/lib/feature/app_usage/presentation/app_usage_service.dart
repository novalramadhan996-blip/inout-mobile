import 'package:flutter/services.dart';
import 'package:mobile_in_out/feature/app_usage/data/model/app_usage_model.dart';

class AppUsageService {
  static const _channel = MethodChannel('app_usage_channel');

  static Future<void> openUsageSettings() async {
    await _channel.invokeMethod('openUsageSettings');
  }

  static Future<List<AppUsageModel>> getLastUsedApps() async {
    final List result = await _channel.invokeMethod('getLastUsedApps');
    return result.map((e) => AppUsageModel.fromMap(e)).take(10).toList();
  }

  static Future<List<AppUsageModel>> getMostUsedApps() async {
    final List result = await _channel.invokeMethod('getMostUsedApps');
    return result.map((e) => AppUsageModel.fromMap(e)).take(10).toList();
  }

  static Future<bool> hasUsagePermission() async {
    final bool result = await _channel.invokeMethod('hasUsagePermission');
    return result;
  }
}
