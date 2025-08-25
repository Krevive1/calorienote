import 'package:flutter/material.dart';

class AppLocale {
  AppLocale._();

  // Null means system locale
  static final ValueNotifier<Locale?> current = ValueNotifier<Locale?>(null);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
    Locale('zh'),
    Locale('ko'),
  ];

  static void set(Locale? locale) {
    current.value = locale;
  }
}


