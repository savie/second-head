import 'package:flutter/material.dart';

import '../../core/backend/auth/auth_backend_error.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import 'auth_screens.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  AuthMode _mode = AuthMode.signIn;
  bool _loading = false;
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _fullName.dispose(); _email.dispose(); _password.dispose(); _confirmation.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_mode == AuthMode.forgot) { await _forgot(); return; }
    if (_email.text.trim().isEmpty || _password.text.isEmpty) { _show('Email dan password wajib diisi.'); return; }
    if (_mode == AuthMode.signUp) {
      if (_fullName.text.trim().isEmpty || _confirmation.text.isEmpty) { _show('Semua field wajib diisi.'); return; }
      if (_password.text != _confirmation.text) { _show('Password dan konfirmasi password tidak sama.'); return; }
    }
    setState(() => _loading = true);
    try {
      if (_mode == AuthMode.signIn) {
        await AuthSession.service.signIn(email: _email.text, password: _password.text);
      } else {
        await AuthSession.service.signUp(email: _email.text, password: _password.text, fullName: _fullName.text);
      }
    } on AuthBackendError catch (error) { if (mounted) _show(error.message); }
    catch (error) { if (mounted) _show('Authentication gagal: $error'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try { await AuthSession.service.signInWithGoogle(); }
    on AuthBackendError catch (error) { if (mounted) _show(error.message); }
    catch (error) { if (mounted) _show('Google sign in gagal: $error'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _forgot() async {
    if (_email.text.trim().isEmpty) { _show('Email wajib diisi.'); return; }
    setState(() => _loading = true);
    try { await AuthSession.service.sendPasswordReset(_email.text); if (mounted) _show('Reset link sudah dikirim jika email terdaftar.'); }
    on AuthBackendError catch (error) { if (mounted) _show(error.message); }
    catch (error) { if (mounted) _show('Gagal mengirim reset link: $error'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  void _setMode(AuthMode mode) => setState(() { _mode = mode; _password.clear(); _confirmation.clear(); });

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp, isForgot = _mode == AuthMode.forgot;
    final title = isSignUp ? 'Create Second Head Account' : isForgot ? 'Recover your account' : 'Second Head';
    final subtitle = isSignUp ? 'Let’s get you started.' : isForgot ? 'We’ll send a secure link to reset your password.' : 'Human - AI Unity';
    return Scaffold(
      backgroundColor: shBackground,
      body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 28, 18, 32), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(children: [
          Container(width: 76, height: 76, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground, border: Border.all(color: shElectric.withValues(alpha: .32), width: 1.5), boxShadow: [BoxShadow(color: shElectric.withValues(alpha: .10), blurRadius: 28, spreadRadius: 4)]), child: const Center(child: ShBrandMark())),
          const SizedBox(height: 18), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 1.1)),
          const SizedBox(height: 9), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: shMuted, fontSize: 13, height: 1.45)), const SizedBox(height: 22),
          Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: shSurface.withValues(alpha: .72), borderRadius: BorderRadius.circular(24), border: Border.all(color: shElectric.withValues(alpha: .18))), child: Column(children: [
            if (isSignUp) ...[_Field(hint: 'Full name', icon: Icons.person_outline, controller: _fullName), const SizedBox(height: 12)],
            _Field(hint: 'Email', controller: _email),
            if (!isForgot) ...[const SizedBox(height: 12), _Field(hint: 'Password', icon: Icons.lock_outline, obscure: true, controller: _password)],
            if (isSignUp) ...[const SizedBox(height: 12), _Field(hint: 'Confirm password', icon: Icons.lock_outline, obscure: true, controller: _confirmation)],
            const SizedBox(height: 16), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isSignUp ? 'Create Account' : isForgot ? 'Send Reset Link' : 'Sign In'))),
            if (_mode == AuthMode.signIn) Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _loading ? null : () => _setMode(AuthMode.forgot), child: const Text('Forgot password?'))),
            if (!isForgot) ...[const SizedBox(height: 4), const Row(children: [Expanded(child: Divider(color: shBorder)), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(fontSize: 12, color: shMuted))), Expanded(child: Divider(color: shBorder))]), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: _loading ? null : _google, icon: const Text('G', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), label: const Text('Google')))],
          ])),
          const SizedBox(height: 12),
          if (isForgot) TextButton(onPressed: _loading ? null : () => _setMode(AuthMode.signIn), child: const Text('Back to sign in')) else TextButton(onPressed: _loading ? null : () => _setMode(isSignUp ? AuthMode.signIn : AuthMode.signUp), child: Text(isSignUp ? 'Already have an account? Sign in' : 'Don’t have an account? Sign up')),
        ]),
      )))),
    );
  }
}

enum AuthMode { signIn, signUp, forgot }

class _Field extends StatefulWidget {
  const _Field({required this.hint, required this.controller, this.icon = Icons.mail_outline, this.obscure = false});
  final String hint; final TextEditingController controller; final IconData icon; final bool obscure;
  @override State<_Field> createState() => _FieldState();
}
class _FieldState extends State<_Field> {
  late bool _obscure = widget.obscure;
  @override Widget build(BuildContext context) => TextField(controller: widget.controller, obscureText: _obscure, keyboardType: widget.hint == 'Email' ? TextInputType.emailAddress : TextInputType.text, autocorrect: false, decoration: InputDecoration(prefixIcon: Icon(widget.icon, color: shMuted), hintText: widget.hint, suffixIcon: widget.obscure ? IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: shMuted)) : null));
}
