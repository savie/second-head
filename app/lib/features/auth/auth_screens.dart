import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import '../home/home_screen.dart';

/// Temporary foundation-level session state.
/// The real authenticated session will be resolved through the SH auth/session
/// boundary when that integration is implemented.
class AuthSession {
  static bool isAuthenticated = false;
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
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: ShBrandMark(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: shMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...fields.expand((w) => [w, const SizedBox(height: 12)]),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [shPurple, shElectric],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (footer != null) footer!,
                  if (secondary != null) ...[
                    const SizedBox(height: 14),
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

class _AuthField extends StatefulWidget {
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
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscure,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, size: 23, color: shMuted),
        hintText: widget.hint,
        suffixIcon: widget.trailing
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 23,
                  color: shMuted,
                ),
              )
            : null,
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to SECOND HEAD',
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
      onPrimary: () {
        AuthSession.isAuthenticated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'Don’t have an account? ',
                  style: TextStyle(fontSize: 14, color: shMuted),
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

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot password?',
      subtitle:
          'No worries! Enter your email and we’ll send you a link to reset your password.',
      fields: const [_AuthField(hint: 'Email')],
      primaryLabel: 'Send Reset Link',
      onPrimary: () => Navigator.of(context).pop(),
      footer: Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Back to sign in',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create your account',
      subtitle: 'Let’s get you started',
      fields: const [
        _AuthField(hint: 'Full name', icon: Icons.person_outline),
        _AuthField(hint: 'Email'),
        _AuthField(
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: true,
          trailing: true,
        ),
        _AuthField(
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          obscure: true,
          trailing: true,
        ),
      ],
      primaryLabel: 'Create Account',
      onPrimary: () {
        AuthSession.isAuthenticated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      footer: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(fontSize: 14, color: shMuted),
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
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: Divider(color: shBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(fontSize: 13, color: shMuted),
                ),
              ),
              Expanded(child: Divider(color: shBorder)),
            ],
          ),
        ),
        const _SocialButton(
          label: 'Google',
          leading: Text(
            'G',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _SocialButton(
          label: 'Apple',
          leading: Icon(CupertinoIcons.logo_apple, size: 23),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.leading,
  });

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: leading,
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: shSurface2,
          foregroundColor: Colors.white,
          side: const BorderSide(color: shBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
