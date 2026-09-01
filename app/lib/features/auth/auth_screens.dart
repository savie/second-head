import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import '../home/home_screen.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Forgot password?', style: TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
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

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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

