import 'package:flutter/material.dart';

import '../../core/backend/auth/auth_backend_error.dart';
import '../../core/identity/sh_identity.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import '../home/home_screen.dart';
import 'auth_service.dart';

class AuthSession {
  static final ShIdentityContext identityContext = ShIdentityContext();
  static final AuthService service = AuthService(identityContext: identityContext);

  static final emailController = TextEditingController();
  static final passwordController = TextEditingController();
  static final fullNameController = TextEditingController();
  static final confirmPasswordController = TextEditingController();

  static bool get isAuthenticated => identityContext.hasIdentity;
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
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final List<Widget> fields;
  final Widget? footer;
  final Widget? secondary;
  final bool loading;

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
                  const Align(alignment: Alignment.center, child: ShBrandMark()),
                  const SizedBox(height: 24),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.4, color: shMuted)),
                  const SizedBox(height: 28),
                  ...fields.expand((w) => [w, const SizedBox(height: 12)]),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [shPurple, shElectric]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: FilledButton(
                        onPressed: loading ? null : onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(primaryLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  if (footer != null) footer!,
                  if (secondary != null) ...[const SizedBox(height: 14), secondary!],
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
    required this.controller,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final bool trailing;
  final TextEditingController controller;

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
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.hint == 'Email' ? TextInputType.emailAddress : TextInputType.text,
      autocorrect: false,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, size: 23, color: shMuted),
        hintText: widget.hint,
        suffixIcon: widget.trailing
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 23, color: shMuted),
              )
            : null,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (AuthSession.emailController.text.trim().isEmpty || AuthSession.passwordController.text.isEmpty) {
      _showError('Email dan password wajib diisi.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthSession.service.signIn(email: AuthSession.emailController.text, password: AuthSession.passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on AuthBackendError catch (error) {
      if (mounted) _showError(error.message);
    } catch (error) {
      if (mounted) _showError('Sign in gagal: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Second Head',
      subtitle: 'Human - AI Unity',
      fields: [
        _AuthField(hint: 'Email', controller: AuthSession.emailController),
        _AuthField(hint: 'Password', icon: Icons.lock_outline, obscure: true, trailing: true, controller: AuthSession.passwordController),
      ],
      primaryLabel: 'Sign In', onPrimary: _signIn, loading: _loading,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Forgot password?', style: TextStyle(fontSize: 14)))),
          const SizedBox(height: 2),
          Center(child: TextButton(onPressed: _loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen())), child: const Text.rich(TextSpan(text: 'Don’t have an account? ', style: TextStyle(fontSize: 14, color: shMuted), children: [TextSpan(text: 'Sign up', style: TextStyle(color: shCyan))])))),
        ],
      ),
      secondary: const _SocialButtons(),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _loading = false;

  Future<void> _sendReset() async {
    final email = AuthSession.emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email wajib diisi.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthSession.service.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sudah dikirim jika email terdaftar.')));
    } on AuthBackendError catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot password', subtitle: 'Enter your email and we’ll send you a link to reset your password.',
      fields: [_AuthField(hint: 'Email', controller: AuthSession.emailController)],
      primaryLabel: 'Send Reset Link', onPrimary: _sendReset, loading: _loading,
      footer: Align(alignment: Alignment.center, child: TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(), child: const Text('Back to sign in', style: TextStyle(fontSize: 14)))),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _loading = false;

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    final email = AuthSession.emailController.text.trim();
    final password = AuthSession.passwordController.text;
    final confirmation = AuthSession.confirmPasswordController.text;
    if (AuthSession.fullNameController.text.trim().isEmpty || email.isEmpty || password.isEmpty || confirmation.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }
    if (password != confirmation) {
      _showError('Password dan konfirmasi password tidak sama.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthSession.service.signUp(email: email, password: password, fullName: AuthSession.fullNameController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on AuthBackendError catch (error) {
      if (mounted) _showError(error.message);
    } catch (error) {
      if (mounted) _showError('Sign up gagal: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create Second Head Account', subtitle: 'Let’s get you started',
      fields: [
        _AuthField(hint: 'Full name', icon: Icons.person_outline, controller: AuthSession.fullNameController),
        _AuthField(hint: 'Email', controller: AuthSession.emailController),
        _AuthField(hint: 'Password', icon: Icons.lock_outline, obscure: true, trailing: true, controller: AuthSession.passwordController),
        _AuthField(hint: 'Confirm password', icon: Icons.lock_outline, obscure: true, trailing: true, controller: AuthSession.confirmPasswordController),
      ],
      primaryLabel: 'Create Account', onPrimary: _signUp, loading: _loading,
      footer: Center(child: TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(), child: const Text.rich(TextSpan(text: 'Already have an account? ', style: TextStyle(fontSize: 14, color: shMuted), children: [TextSpan(text: 'Sign in', style: TextStyle(color: shCyan))])))),
      secondary: const _SocialButtons(),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Row(children: [Expanded(child: Divider(color: shBorder)), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(fontSize: 13, color: shMuted))), Expanded(child: Divider(color: shBorder))])),
      const _SocialButton(label: 'Google', leading: Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
      const SizedBox(height: 10),
      const _SocialButton(label: 'Apple', leading: Icon(Icons.apple, size: 23)),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.leading});

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(
      onPressed: () {}, icon: leading,
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(backgroundColor: shSurface2, foregroundColor: Colors.white, side: const BorderSide(color: shBorder, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    ));
  }
}
