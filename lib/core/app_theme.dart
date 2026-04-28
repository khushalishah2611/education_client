import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFFAF5);
  static const peach = Color(0xFFFDE1CC);
  static const peachSoft = Color(0xFFFFF6EE);
  static const primary = Color(0xFFA0E1BE);
  static const primaryDark = Color(0xFF65C898);
  static const logo = Color(0xFF4A2132);
  static const accent = Color(0xFFE98A2B);
  static const text = Color(0xFF111111);
  static const textMuted = Color(0xFF757575);
  static const border = Color(0xFFD9DEE6);
  static const white = Colors.white;
  static const card = Color(0xFFFFFFFF);
  static const shadow = Color(0x14000000);
  static const softOrange = Color(0xFFFFB567);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
