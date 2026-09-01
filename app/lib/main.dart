import 'package:flutter/material.dart';
import 'core/navigation/sh_navigation_shell.dart';
import 'features/conversation/conversation_view.dart';
import 'features/journey/journey_view.dart';
import 'features/lifecycle/lifecycle_view.dart';
import 'features/profile/profile_view.dart';
import 'features/more/more_views.dart';
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

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: shBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('or continue with', style: TextStyle(fontSize: 10, color: shMuted)),
              ),
              Expanded(child: Divider(color: shBorder)),
            ],
          ),
        ),
        _SocialButton(label: 'Google', leading: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(height: 7),
        _SocialButton(label: 'Apple', leading: const Text('', style: TextStyle(fontSize: 18))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.leading});

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: leading,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          backgroundColor: shSurface2,
          side: const BorderSide(color: shBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return ShNavigationShell(
      drawer: const SideMenu(),
      pages: const [
        ConversationView(),
        JourneyView(),
        LifecycleView(),
        ProfileView(),
      ],
    );
  }
}


