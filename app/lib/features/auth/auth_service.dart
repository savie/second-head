import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/identity/sh_identity.dart';
import '../../core/supabase/supabase_client.dart';

class AuthService {
  AuthService({required this.identityContext});

  final ShIdentityContext identityContext;
  StreamSubscription<AuthState>? _authSubscription;
  bool _passwordRecoveryActive = false;

  bool get isPasswordRecoveryActive => _passwordRecoveryActive;

  void startAuthStateListener({void Function()? onChanged}) {
    _authSubscription ??= supabaseClient.auth.onAuthStateChange.listen((data) async {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (data.session != null) {
            try {
              await resolveIdentity();
            } catch (_) {
              identityContext.clear();
            }
          }
          break;
        case AuthChangeEvent.passwordRecovery:
          _passwordRecoveryActive = true;
          onChanged?.call();
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _passwordRecoveryActive = false;
          identityContext.clear();
          onChanged?.call();
          break;
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await resolveIdentity();
  }

  Future<void> signInWithGoogle() async {
    await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName == null || fullName.trim().isEmpty
          ? null
          : {'full_name': fullName.trim()},
    );

    if (response.session == null) {
      throw const AuthException(
        'Account created. Check your email to confirm the account before signing in.',
      );
    }

    await resolveIdentity();
  }

  Future<void> sendPasswordReset(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> updatePassword(String password) async {
    if (supabaseClient.auth.currentSession == null) {
      throw const AuthException('Password recovery session is no longer active.');
    }
    await supabaseClient.auth.updateUser(UserAttributes(password: password));
    _passwordRecoveryActive = false;
    await resolveIdentity();
  }

  void finishPasswordRecovery() {
    _passwordRecoveryActive = false;
  }

  Future<void> restoreSession() async {
    if (supabaseClient.auth.currentSession == null) {
      identityContext.clear();
      return;
    }
    await resolveIdentity();
  }

  Future<void> resolveIdentity() async {
    final session = supabaseClient.auth.currentSession;
    if (session == null) {
      identityContext.clear();
      throw const AuthException('No authenticated Supabase session.');
    }

    final result = await supabaseClient.rpc('resolve_identity');
    if (result is! List || result.length != 1 || result.first is! Map) {
      throw const AuthException('Unable to resolve the authenticated SH identity.');
    }

    final row = Map<String, dynamic>.from(result.first as Map);
    final accountId = row['account_id']?.toString();
    final shId = row['sh_id']?.toString();
    final ownershipRole = row['ownership_role']?.toString();

    if (accountId == null || shId == null || ownershipRole == null) {
      throw const AuthException('Authenticated identity is incomplete.');
    }

    identityContext.setIdentity(
      ShIdentity(
        accountId: accountId,
        shId: shId,
        ownershipRole: ownershipRole,
      ),
    );
  }

  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
    _passwordRecoveryActive = false;
    identityContext.clear();
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
  }
}
