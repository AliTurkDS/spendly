import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A2235);
  static const Color darkCardElevated = Color(0xFF1E2A40);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00E5A0);
  static const Color accentRed = Color(0xFFFF4C6B);
  static const Color accentAmber = Color(0xFFFFB020);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF2563EB);

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: accentCyan,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentGreen,
      tertiary: accentPurple,
      error: accentRed,
      surface: darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentCyan, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
      bodySmall: TextStyle(color: Color(0xFF78909C)),
    ),
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: lightPrimary,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: Color(0xFF10B981),
      tertiary: Color(0xFF8B5CF6),
      error: Color(0xFFEF4444),
      surface: lightSurface,
    ),

    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightPrimary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Color(0xFF1E293B)),
      bodyMedium: TextStyle(color: Color(0xFF475569)),
      bodySmall: TextStyle(color: Color(0xFF94A3B8)),
    ),
  );
}
