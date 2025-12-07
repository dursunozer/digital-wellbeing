import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void toggleLocale() {
    state = state.languageCode == 'en' 
        ? const Locale('tr') 
        : const Locale('en');
  }

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }

  String get currentLanguage => state.languageCode;
  String get flagEmoji => state.languageCode == 'en' ? '🇬🇧' : '🇹🇷';
}
