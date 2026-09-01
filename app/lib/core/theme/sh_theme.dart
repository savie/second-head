import 'package:flutter/material.dart';

const shBackground = Color(0xFF050D16);
const shSurface = Color(0xFF0B1622);
const shSurface2 = Color(0xFF111F2C);
const shPurple = Color(0xFF7C3AED);
const shElectric = Color(0xFF2563EB);
const shCyan = Color(0xFF22D3EE);
const shMuted = Color(0xFF9AA8B6);
const shBorder = Color(0xFF273746);

ThemeData buildShTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: shBackground,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: shPurple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: shPurple,
      secondary: shCyan,
      surface: shSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x990B1622),
      hintStyle: const TextStyle(color: shMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: shBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: shPurple),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: shSurface,
      indicatorColor: shPurple.withOpacity(.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
