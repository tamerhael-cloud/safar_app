import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal() {
    _loadLocale();
  }

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString('language_code');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', loc.languageCode);
    notifyListeners();
  }

  String translate(String ar, String en) {
    return isArabic ? ar : en;
  }
}
