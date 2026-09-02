import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  final ShardPrefService _prefService;
  Locale _locale = const Locale('en');

  LocaleProvider(this._prefService) {
    _init();
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  Future<void> _init() async {
    await _prefService.init();
    _loadLocale();
  }

  void _loadLocale() {
    final savedLocale = _prefService.getString(_localeKey);
    savedLocale.then((value) {
      if (value != null && value.isNotEmpty) {
        _locale = Locale(value);
        notifyListeners();
      }
    });
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    await _prefService.setString(_localeKey, languageCode);
    AppTranslations.setLocale(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return AppTranslations.translate(key);
  }
}
