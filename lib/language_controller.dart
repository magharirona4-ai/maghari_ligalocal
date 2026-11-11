
import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  String _language = 'English';

  String get language => _language;

  bool get isFilipino => _language == 'Filipino';

  void changeLanguage(String newLanguage) {
    if (_language == newLanguage) return;

    _language = newLanguage;
    notifyListeners();
  }

  String translate(String english, String filipino) {
    return isFilipino ? filipino : english;
  }
}

final languageController = LanguageController();
