import 'package:flutter/material.dart';
import 'core/navigation/sh_navigation_shell.dart';
import 'features/conversation/conversation_view.dart';
import 'features/journey/journey_view.dart';
import 'features/lifecycle/lifecycle_view.dart';
import 'features/profile/profile_view.dart';
import 'core/theme/sh_theme.dart';
import 'features/more/more_views.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/auth_screens.dart';

final ValueNotifier<Uint8List?> _profilePhoto = ValueNotifier<Uint8List?>(null);

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

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WaveBackground(),
          Center(child: ShBrandMark(large: true, showWordmark: true)),
          Positioned(
            bottom: 38,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [shPurple, shCyan]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _WavePainter());
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = const LinearGradient(
        colors: [shPurple, shElectric, shCyan],
      ).createShader(Offset.zero & size);

    for (var i = 0; i < 7; i++) {
      final path = Path();
      final base = size.height * .68 + i * 9;
      path.moveTo(-20, base);
      for (var x = 0.0; x <= size.width + 20; x += 10) {
        final y = base +
            16 * (i.isEven ? 1 : -1) *
                (0.5 + .5 * (i / 7)) *
                (x / size.width).clamp(0.0, 1.0) *
                0.8 *
                (x / size.width < .5 ? x / size.width : 1 - x / size.width);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint..opacity = .32);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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


