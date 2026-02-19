import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark Mode Colors ──
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);

  // ── Light Mode Colors ──
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF0F2F5);

  // ── Vibrant Accents (shared) ──
  static const Color accentPurple = Color(0xFFBB86FC);
  static const Color accentTeal = Color(0xFF03DAC6);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentBlue = Color(0xFF6C9FFF);

  // ── Difficulty Colors ──
  static const Color difficultyEasy = Color(0xFF4ECDC4);
  static const Color difficultyMedium = Color(0xFFFFD93D);
  static const Color difficultyHard = Color(0xFFFF6B6B);

  // ── Dark Theme ──
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: accentPurple,
      secondary: accentTeal,
      surface: surfaceDark,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundBlack,
      selectedItemColor: accentTeal,
      unselectedItemColor: Colors.white38,
    ),
  );

  // ── Light Theme ──
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF2D3436)),
      titleTextStyle: TextStyle(
        color: Color(0xFF2D3436),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: accentPurple,
      secondary: accentTeal,
      surface: surfaceLight,
      onSurface: Color(0xFF2D3436),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF2D3436),
      displayColor: const Color(0xFF2D3436),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: Color(0xFF7C4DFF),
      unselectedItemColor: Color(0xFF9E9E9E),
    ),
  );

  // ── Helper: Is dark mode check ──
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color bg(BuildContext context) =>
      isDark(context) ? backgroundBlack : backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color card(BuildContext context) =>
      isDark(context) ? cardDark : cardLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF2D3436);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white70 : const Color(0xFF636E72);

  static Color textMuted(BuildContext context) =>
      isDark(context) ? Colors.white38 : const Color(0xFFB2BEC3);

  static Color dividerColor(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.08);
}
