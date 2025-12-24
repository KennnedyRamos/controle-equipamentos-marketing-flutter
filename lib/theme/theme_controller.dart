import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

const _themeKey = 'theme_mode';

/// 🔄 Carrega o tema salvo ao iniciar o app
Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString(_themeKey);

  if (theme == 'dark') {
    themeModeNotifier.value = ThemeMode.dark;
  } else if (theme == 'light') {
    themeModeNotifier.value = ThemeMode.light;
  }
}

/// 🌙 Alterna e salva o tema
Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();

  if (themeModeNotifier.value == ThemeMode.dark) {
    themeModeNotifier.value = ThemeMode.light;
    await prefs.setString(_themeKey, 'light');
  } else {
    themeModeNotifier.value = ThemeMode.dark;
    await prefs.setString(_themeKey, 'dark');
  }
}
