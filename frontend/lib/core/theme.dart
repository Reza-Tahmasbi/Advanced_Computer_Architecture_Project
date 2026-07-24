// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.grey,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    fontFamily: 'TimesNewRoman',   // ← This applies to ALL text by default

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'TimesNewRoman',
        color: Color(0xFF1F2937),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'TimesNewRoman',
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      titleLarge: TextStyle(
        fontFamily: 'TimesNewRoman',
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'TimesNewRoman',
        fontSize: 17,
        color: Color(0xFF374151),
      ),
      titleMedium: TextStyle(
        fontFamily: 'TimesNewRoman',
        fontSize: 17,
        color: Colors.grey,
      ),
    ),

    // Other styles...
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'TimesNewRoman',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}