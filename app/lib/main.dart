import 'package:flutter/material.dart';

import 'core/theme/sh_theme.dart';
import 'features/auth/splash_screen.dart';

void main() => runApp(const SecondHeadApp());

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: buildShTheme(),
      home: const SplashScreen(),
    );
  }
}
