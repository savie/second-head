import 'package:flutter/material.dart';
import 'core/navigation/sh_navigation_shell.dart';
import 'features/conversation/conversation_view.dart';
import 'features/journey/journey_view.dart';
import 'features/lifecycle/lifecycle_view.dart';
import 'features/profile/profile_view.dart';
import 'core/theme/sh_theme.dart';
import 'features/more/more_views.dart';
import 'core/widgets/sh_brand_mark.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
      home: const _SplashScreen(),
    );
  }
}

class ShBrandMark extends StatelessWidget {
  const ShBrandMark({this.large = false, this.showWordmark = false});

  final bool large;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final size = large ? 116.0 : 48.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset('assets/brand/unity.png', fit: BoxFit.contain),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          const Text(
            'SECOND HEAD',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Dual Mind. Infinite Potential.',
            style: TextStyle(fontSize: 11, color: shMuted),
          ),
          const Text(
            'Human – AI Unity.',
            style: TextStyle(fontSize: 11, color: shMuted),
          ),
        ],
      ],
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
          MaterialPageRoute(builder: (_) => const _LoginScreen()),
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

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.fields = const [],
    this.footer,
    this.secondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final List<Widget> fields;
  final Widget? footer;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: ShBrandMark(),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: shMuted),
                  ),
                  const SizedBox(height: 24),
                  ...fields.expand((w) => [w, const SizedBox(height: 10)]),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 43,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [shPurple, shElectric]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(primaryLabel),
                      ),
                    ),
                  ),
                  if (footer != null) footer!,
                  if (secondary != null) ...[
                    const SizedBox(height: 10),
                    secondary!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hint,
    this.icon = Icons.mail_outline,
    this.obscure = false,
    this.trailing = false,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: shMuted),
        hintText: hint,
        suffixIcon: trailing
            ? const Icon(Icons.visibility_outlined, size: 17, color: shMuted)
            : null,
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to Second Head',
      fields: const [
        _AuthField(hint: 'Email'),
        _AuthField(
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: true,
          trailing: true,
        ),
      ],
      primaryLabel: 'Sign In',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _ForgotPasswordScreen()),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Forgot password?', style: TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _SignUpScreen()),
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'Don’t have an account? ',
                  style: TextStyle(fontSize: 10, color: shMuted),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(color: shCyan),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      secondary: const _SocialButtons(),
    );
  }
}

class _ForgotPasswordScreen extends StatelessWidget {
  const _ForgotPasswordScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'No worries! Enter your email and we’ll send you a link to reset your password.',
      fields: const [_AuthField(hint: 'Email')],
      primaryLabel: 'Send Reset Link',
      onPrimary: () => Navigator.of(context).pop(),
      footer: Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to sign in', style: TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}

class _SignUpScreen extends StatelessWidget {
  const _SignUpScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create your account',
      subtitle: 'Let’s get you started',
      fields: const [
        _AuthField(hint: 'Full name', icon: Icons.person_outline),
        _AuthField(hint: 'Email'),
        _AuthField(hint: 'Password', icon: Icons.lock_outline, obscure: true, trailing: true),
        _AuthField(hint: 'Confirm password', icon: Icons.lock_outline, obscure: true, trailing: true),
      ],
      primaryLabel: 'Create Account',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(fontSize: 10, color: shMuted),
              children: [
                TextSpan(
                  text: 'Sign in',
                  style: TextStyle(color: shCyan),
                ),
              ],
            ),
          ),
        ),
      ),
      secondary: const _SocialButtons(),
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

final ValueNotifier<List<RecentConversationEntry>> recentConversations =
    ValueNotifier<List<RecentConversationEntry>>([
  const RecentConversationEntry('Today Priorities', 'Summary and top priorities'),
  const RecentConversationEntry('SH Roadmap', 'Project planning and milestones'),
  const RecentConversationEntry('Ideas & Notes', 'Personalized ideas and notes'),
]);
