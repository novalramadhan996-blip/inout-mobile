import 'package:shared_preferences/shared_preferences.dart';

class ShardPrefService {
  SharedPreferences? _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _sharedPreferences?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _sharedPreferences?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _sharedPreferences?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _sharedPreferences?.getBool(key) ?? false;
  }

  Future<void> setInt(String key, int value) async {
    await _sharedPreferences?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _sharedPreferences?.getInt(key);
  }

  // remove value from shared preferences
  Future<void> remove(String key) async {
    await _sharedPreferences?.remove(key);
  }

  Future<void> clear() async {
    List<String> excludeKeys = [PrefServiceKey.email];
    _sharedPreferences = await SharedPreferences.getInstance();
    final Set<String>? allKeys = _sharedPreferences?.getKeys();

    for (final key in allKeys ?? <String>{}) {
      if (!excludeKeys.contains(key)) {
        _sharedPreferences?.remove(key);
      }
    }
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class PrefServiceKey {
  static const String authToken = 'auth_token';
  static const String refrehToken = 'refresh_token';
  static const String email = 'email';
  static const String isLogin = 'is_login';
  static const String refreshToken = 'refresh_token';
  static const String appsId = 'appsId';
  static const String groupShiftSchedule = 'groupShiftSchedules';
  static const String isReminder = "isReminder";
  static const String delayAbsensi = "delayAbsensi";
  static const String locationAbsence = "locationAbsence";
  static const String checkInDate = "checkInDate";
  static const String checkOutDate = "checkOutDate";
  static const String isOpenUsageAccess = "isOpenUsageAccess";
  static const String profile = "myprofile";
  static const String employeeDetail = "employeeDetail";
  static const String appLocale = "app_locale";
}
