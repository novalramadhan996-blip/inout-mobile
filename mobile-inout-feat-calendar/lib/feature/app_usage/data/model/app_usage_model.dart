class AppUsageModel {
  final String appName;
  final String packageName;
  final String versionName;
  final int versionCode;
  final int installedAt;
  final int updatedAt;
  final int lastTimeUsed;
  final int totalTime;

  AppUsageModel({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.installedAt,
    required this.updatedAt,
    required this.lastTimeUsed,
    required this.totalTime,
  });

  factory AppUsageModel.fromMap(Map<dynamic, dynamic> map) {
    return AppUsageModel(
      appName: map['app_name'] ?? '',
      packageName: map['package_name'] ?? '',
      versionName: map['version_name'] ?? '',
      versionCode: map['version_code'] ?? 0,
      installedAt: map['installed_at'] ?? 0,
      updatedAt: map['updated_at'] ?? 0,
      lastTimeUsed: map['lastTimeUsed'] ?? 0,
      totalTime: map['totalTime'] ?? 0,
    );
  }

  Duration get usageDuration => Duration(milliseconds: totalTime);

  DateTime get lastUsedDate =>
      DateTime.fromMillisecondsSinceEpoch(lastTimeUsed);

  DateTime get installedDate =>
      DateTime.fromMillisecondsSinceEpoch(installedAt);
}
