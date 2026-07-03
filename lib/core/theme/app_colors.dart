import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static Brightness currentBrightness = Brightness.dark;

  static bool get _isDark => currentBrightness == Brightness.dark;

  static const Color primary = Color(0xFF76C8FF);
  static const Color accent = Color(0xFF89E6FF);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);

  static Color get background => _isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5);
  static Color get card => _isDark ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
  static Color get surface => _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);
  static Color get secondary => _isDark ? const Color(0xFF1B1B1B) : const Color(0xFFF0F0F0);
  static Color get textWhite => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  static Color get textGrey => _isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
  static Color get border => _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
}
