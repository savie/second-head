import 'package:flutter/material.dart';

import 'core/backend/backend_client.dart';
import 'core/theme/sh_theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/auth/update_password_screen.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackend();

  try {
    await AuthSession.service.restoreSession();
  } catch (_) {
    AuthSession.identityContext.clear();
  }

  runApp(const SecondHeadApp(authListenerEnabled: true));
}

class SecondHeadApp extends StatefulWidget {
  const SecondHeadApp({super.key, this.authListenerEnabled = false});

  final bool authListenerEnabled;

  @override
  State<SecondHeadApp> createState() => _SecondHeadAppState();
}

class _SecondHeadAppState extends State<SecondHeadApp> {
  @override
  void initState() {
    super.initState();
    shAppearance.addListener(_changed);
    AuthSession.identityContext.addListener(_changed);
    if (widget.authListenerEnabled) {
      AuthSession.service.startAuthStateListener(onChanged: _changed);
    }
  }

  @override
  void dispose() {
    shAppearance.removeListener(_changed);
    AuthSession.identityContext.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Widget entry;
    if (AuthSession.service.isPasswordRecoveryActive) {
      entry = const UpdatePasswordScreen();
    } else if (AuthSession.isAuthenticated) {
      entry = const HomeScreen();
    } else {
      entry = const LoginScreen();
    }

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
