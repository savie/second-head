import 'package:flutter/material.dart';

const shBackground = Color(0xFF050D16);
const shSurface = Color(0xFF0B1622);
const shSurface2 = Color(0xFF111F2C);
const shPurple = Color(0xFF7C3AED);
const shElectric = Color(0xFF2563EB);
const shCyan = Color(0xFF22D3EE);
const shMuted = Color(0xFF9AA8B6);
const shBorder = Color(0xFF273746);

const shAccent = shPurple;
const shTextPrimary = Colors.white;
const shTextOnAccent = Colors.white;

ThemeData buildShTheme({bool light = false}) {
  return ThemeData(
    useMaterial3: true,
    brightness: light ? Brightness.light : Brightness.dark,
    scaffoldBackgroundColor: light ? const Color(0xFFF4F7FB) : shBackground,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(seedColor: shPurple, brightness: light ? Brightness.light : Brightness.dark).copyWith(
      primary: shPurple,
      secondary: shCyan,
      surface: light ? const Color(0xFFFFFFFF) : shSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: light ? const Color(0xFFF7F9FC) : const Color(0x990B1622),
      hintStyle: const TextStyle(color: shMuted, fontSize: 16, fontWeight: FontWeight.w400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: light ? const Color(0xFFD2D9E2) : shBorder, width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: shPurple, width: 1.5)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: light ? const Color(0xFFFFFFFF) : shSurface,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? const IconThemeData(color: shPurple, size: 22) : IconThemeData(color: light ? const Color(0xFF46515E) : Colors.white70, size: 22)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: states.contains(WidgetState.selected) ? shPurple : (light ? const Color(0xFF46515E) : Colors.white70))),
    ),
  );
}

class ShAppearanceController extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  String languageCode = 'en';

  void setThemeMode(ThemeMode value) { if (themeMode == value) return; themeMode = value; notifyListeners(); }
  void setLanguage(String value) { if (languageCode == value) return; languageCode = value; notifyListeners(); }
}

final shAppearance = ShAppearanceController();
