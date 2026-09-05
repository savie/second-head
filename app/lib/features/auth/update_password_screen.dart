import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/sh_theme.dart';
import 'auth_screens.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (_password.text.length < 8) {
      _show('Password baru minimal 8 karakter.');
      return;
    }
    if (_password.text != _confirmation.text) {
      _show('Password dan konfirmasi password tidak sama.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthSession.service.updatePassword(_password.text);
      AuthSession.service.finishPasswordRecovery();
    } on AuthException catch (error) {
      if (mounted) _show(error.message);
    } catch (error) {
      if (mounted) _show('Gagal memperbarui password: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: shSurface.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: shElectric.withValues(alpha: .18)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_reset_rounded, size: 48, color: shElectric),
                    const SizedBox(height: 16),
                    const Text('Set new password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    const Text('Choose a new password for your SECOND HEAD account.', textAlign: TextAlign.center, style: TextStyle(color: shMuted, fontSize: 13, height: 1.45)),
                    const SizedBox(height: 22),
                    TextField(controller: _password, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'New password')),
                    const SizedBox(height: 12),
                    TextField(controller: _confirmation, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Confirm password')),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: _loading ? null : _update, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Password'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
