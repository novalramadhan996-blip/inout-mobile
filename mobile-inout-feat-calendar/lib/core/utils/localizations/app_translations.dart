import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/en_translation.dart';
import 'package:mobile_in_out/core/utils/localizations/id_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': enTranslation,
    'id': idTranslation,
  };

  static const String _localeKey = 'app_locale';

  static late String _currentLocale;

  static Future<void> init() async {
    _currentLocale = await _getLocale();
  }

  static void setLocale(String locale) {
    _currentLocale = locale;
  }

  static Future<String> _getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en';
  }

  static String translate(String key, {String? locale}) {
    final currentLocale = _currentLocale;
    LogHelper.logDebug('locale $currentLocale');
    return _localizedValues[currentLocale]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static List<LanguageOption> get supportedLanguages => const [
    LanguageOption(code: 'id', name: 'Bahasa Indonesia'),
    LanguageOption(code: 'en', name: 'English'),
  ];
}

class LanguageOption {
  final String code;
  final String name;

  const LanguageOption({required this.code, required this.name});
}
