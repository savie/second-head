import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/widgets/sh_brand_mark.dart';
import 'auth_screens.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> signIn() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) { show('Email dan password wajib diisi.'); return; }
    setState(() => loading = true);
    try { await AuthSession.service.signIn(email: email.text, password: password.text); }
    on AuthException catch (e) { if (mounted) show(e.message); }
    catch (e) { if (mounted) show('Sign in gagal: $e'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> google() async {
    setState(() => loading = true);
    try { await AuthSession.service.signInWithGoogle(); }
    on AuthException catch (e) { if (mounted) show(e.message); }
    catch (e) { if (mounted) show('Google sign in gagal: $e'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  void show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(children: [
          Container(width: 76, height: 76, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: shElectric.withValues(alpha: .32)), boxShadow: [BoxShadow(color: shElectric.withValues(alpha: .10), blurRadius: 28, spreadRadius: 4)]), child: const Center(child: ShBrandMark())),
          const SizedBox(height: 18),
          const Text('Second Head', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Human - AI Unity', style: TextStyle(color: shMuted, fontSize: 13)),
          const SizedBox(height: 22),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: shSurface.withValues(alpha: .72), borderRadius: BorderRadius.circular(24), border: Border.all(color: shElectric.withValues(alpha: .18))), child: Column(children: [
            TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), hintText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Password')),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: loading ? null : signIn, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign In'))),
            Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), child: const Text('Forgot password?'))),
            const Row(children: [Expanded(child: Divider(color: shBorder)), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(fontSize: 12, color: shMuted))), Expanded(child: Divider(color: shBorder))]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: loading ? null : google, icon: const Text('G', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), label: const Text('Google'))),
          ])),
          const SizedBox(height: 12),
          TextButton(onPressed: loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen())), child: const Text('Don’t have an account? Sign up')),
        ]),
      ))),
    );
  }
}
