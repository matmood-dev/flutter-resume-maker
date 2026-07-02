import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = '.SF Pro Display';

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textWhite,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle get displayLarge => _base(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displayMedium => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displaySmall => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineLarge => _base(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleLarge => _base(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get titleMedium => _base(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get titleSmall => _base(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get bodyLarge => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelSmall => _base(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get buttonLarge => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get buttonMedium => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get buttonSmall => _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle primary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  static TextStyle accent(TextStyle style) {
    return style.copyWith(color: AppColors.accent);
  }

  static TextStyle grey(TextStyle style) {
    return style.copyWith(color: AppColors.textGrey);
  }
}
