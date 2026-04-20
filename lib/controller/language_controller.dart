import 'package:flutter/material.dart';
import 'pref.dart';
import 'constants.dart';

class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageController() {
    _loadLocale();
  }

  void _loadLocale() async {
    String? langCode = await Pref.getPref(PrefKey.lang);
    if (langCode != null) {
      _locale = Locale(langCode.toLowerCase());
      Constants.lang = langCode.toUpperCase();
      notifyListeners();
    }
  }

  void setLocale(String langCode) async {
    _locale = Locale(langCode.toLowerCase());
    Constants.lang = langCode.toUpperCase();
    await Pref.setPref(key: PrefKey.lang, value: langCode);
    notifyListeners();
  }
}
