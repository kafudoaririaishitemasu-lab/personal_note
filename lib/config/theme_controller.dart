import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  /// Notifier for current theme
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  /// Load saved theme from storage
  static Future<void> loadThemeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString("themeMode") ?? "light";

    themeModeNotifier.value = themeString == "dark" ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set theme and save to storage
  static Future<void> setTheme(ThemeMode mode) async {
    themeModeNotifier.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", mode == ThemeMode.dark ? "dark" : "light");
  }

  /// Toggle between light and dark
  static Future<void> toggleTheme() async {
    final newMode = themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  /// Check if current theme is dark
  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
}
