import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/identity/sh_identity.dart';
import '../../core/supabase/supabase_client.dart';

class AuthService {
  AuthService({required this.identityContext});

  final ShIdentityContext identityContext;

  Future<void> signIn({required String email, required String password}) async {
    await supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await resolveIdentity();
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

    // With email confirmation enabled, signUp can succeed without creating an
    // active session. Do not enter Home until an authenticated session exists.
    if (response.session == null) {
      throw const AuthException(
        'Account created. Check your email to confirm the account before signing in.',
      );
    }

    await resolveIdentity();
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
    identityContext.clear();
  }
}
