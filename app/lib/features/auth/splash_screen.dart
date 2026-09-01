import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import '../home/home_screen.dart';
import 'auth_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final Widget destination = AuthSession.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _WaveBackground(),
            const Center(
              child: ShBrandMark(
                large: true,
                showWordmark: true,
              ),
            ),
            Positioned(
              bottom: 38,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 42,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [shPurple, shCyan],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _WavePainter(),
      );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = const LinearGradient(
        colors: [shPurple, shElectric, shCyan],
      ).createShader(Offset.zero & size);

    for (var i = 0; i < 7; i++) {
      final path = Path();
      final base = size.height * .68 + i * 9;
      path.moveTo(-20, base);
      for (var x = 0.0; x <= size.width + 20; x += 10) {
        final progress = (x / size.width).clamp(0.0, 1.0);
        final edge = progress < .5 ? progress : 1 - progress;
        final y = base +
            16 *
                (i.isEven ? 1 : -1) *
                (0.5 + .5 * (i / 7)) *
                progress *
                .8 *
                edge;
        path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        paint..color = Colors.white.withValues(alpha: .32),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
