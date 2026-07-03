import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Brightness brightness;

  const ThemeState({
    this.themeMode = ThemeMode.dark,
    this.brightness = Brightness.dark,
  });

  bool get isDark => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode, Brightness? brightness}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      brightness: brightness ?? this.brightness,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? true;
    _applyTheme(isDark);
  }

  void _applyTheme(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    AppColors.currentBrightness = brightness;
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      brightness: brightness,
    );
  }

  Future<void> toggleTheme() async {
    final newIsDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', newIsDark);
    _applyTheme(newIsDark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
