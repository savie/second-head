import 'package:flutter/material.dart';

import 'core/theme/sh_theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/home/home_screen.dart';

void main() => runApp(const SecondHeadApp());


class SecondHeadApp extends StatefulWidget {
  const SecondHeadApp({super.key});

  @override
  State<SecondHeadApp> createState() => _SecondHeadAppState();
}

class _SecondHeadAppState extends State<SecondHeadApp> {
  @override
  void initState() {
    super.initState();
    shAppearance.addListener(_changed);
  }

  @override
  void dispose() {
    shAppearance.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Widget entry = AuthSession.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();

    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: buildShTheme(light: true),
      darkTheme: buildShTheme(light: false),
      themeMode: shAppearance.themeMode,
      locale: Locale(shAppearance.languageCode),
      home: entry,
    );
  }
}
