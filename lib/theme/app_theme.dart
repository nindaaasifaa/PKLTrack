import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFFF3D77E);
  static const Color accent = Color(0xFFD2A52D);
  static const Color surface = Color(0xFFFFFEF9);
  static const Color background = Color(0xFFFFFBF0);
  static const Color onPrimary = Color(0xFF383321);
  static const Color onSurface = Color(0xFF383321);
  static const Color muted = Color(0xFF756D54);
  static const Color outline = Color(0xFFF0E4BE);
  static const Color primaryContainer = Color(0xFFFFF2C6);
  static const Color progressTrack = Color(0xFFF8F0D8);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: accent,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: onSurface,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimary,
      outline: outline,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: accent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: muted),
      floatingLabelStyle: const TextStyle(color: accent),
      prefixIconColor: accent,
      suffixIconColor: muted,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onPrimary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: progressTrack,
    ),
  );
}
