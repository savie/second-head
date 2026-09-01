import 'package:flutter/material.dart';

import 'core/theme/sh_theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/home/home_screen.dart';

void main() => runApp(const SecondHeadApp());

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget entry = AuthSession.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();

    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: buildShTheme(),
      home: entry,
    );
  }
}
