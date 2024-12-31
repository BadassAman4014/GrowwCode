import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en', 'US'); // Default to English

  Locale get locale => _locale;

  void setLocale(String languageCode) {
    // Convert the string language code to a Locale object
    switch (languageCode) {
      case 'hi':
        _locale = Locale('hi', 'IN'); // Hindi
        break;
      case 'te':
        _locale = Locale('te', 'IN'); // Hindi
        break;
      case 'en':
      default:
        _locale = Locale('en', 'US'); // Default to English
        break;
    }

    notifyListeners(); // Notify listeners of the locale change
  }
}



