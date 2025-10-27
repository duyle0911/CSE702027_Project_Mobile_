import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLang extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString('locale');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('locale', code);
    _locale = Locale(code);
    notifyListeners();
  }
}
