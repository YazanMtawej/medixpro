import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's active [Locale] and persists the user's choice.
/// Mirrors the pattern used by [ThemeCubit].
class LocaleCubit extends Cubit<Locale> {
  static const _localeKey = "app_locale";

  static const englishLocale = Locale('en');
  static const arabicLocale = Locale('ar');

  LocaleCubit() : super(englishLocale) {
    loadLocale();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'en';
    emit(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Toggle between English and Arabic — used by the language switch.
  Future<void> toggleLocale() async {
    await setLocale(isArabic ? englishLocale : arabicLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
}
