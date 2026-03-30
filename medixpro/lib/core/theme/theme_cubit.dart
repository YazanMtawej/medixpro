import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {

  static const _themeKey = "app_theme";

  ThemeCubit() : super(ThemeMode.light) {
    loadTheme();
  }

  Future<void> loadTheme() async {

    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_themeKey) ?? false;

    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {

    final prefs = await SharedPreferences.getInstance();

    final isDark = state == ThemeMode.dark;

    final newTheme = isDark ? ThemeMode.light : ThemeMode.dark;

    emit(newTheme);

    await prefs.setBool(_themeKey, newTheme == ThemeMode.dark);
  }
}