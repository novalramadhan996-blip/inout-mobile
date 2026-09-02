import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> init() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences?.getBool(key);
  }

  Future<void> remove(String key) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences?.remove(key);
  }

  Future<void> clear() async {
    List<String> excludeKeys = [PrefServiceKey.email, PrefServiceKey.password];
    _sharedPreferences = await SharedPreferences.getInstance();
    final Set<String>? allKeys = _sharedPreferences?.getKeys();

    for (final key in allKeys ?? <String>{}) {
      if (!excludeKeys.contains(key)) {
        _sharedPreferences?.remove(key);
      }
    }
  }
}

class PrefServiceKey {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String email = 'email';
  static const String password = 'password';
  static const String isLogin = 'is_login';
  static const String myProfile = 'myprofile';
  static const String isNotifChat = 'isNotifChat';
  static const String badgeCounter = 'badgeCounter';
  static const String selectMapType = 'selectMapType';
}
