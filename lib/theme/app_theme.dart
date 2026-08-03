import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkGreen = Color(0xFF00261B);
  static const Color forestGreen = Color(0xFF006E0A);
  static const Color vibrantGreen = Color(0xFF69FD5D);
  static const Color darkGreenAccent = Color(0xFF00730B);
  static const Color textSecondary = Color(0xFF414944);
  static const Color notchColor = Color(0xFFC0C8C3);
  static const Color cardGradientEnd = Color(0xFF0B3D2E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forestGreen,
        primary: AppColors.forestGreen,
        surface: AppColors.background,
      ),
      fontFamily: 'Roboto',
    );
  }
}
