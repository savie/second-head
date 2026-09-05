import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBackend {
  const AuthBackend();

  Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

  Session? get currentSession => Supabase.instance.client.auth.currentSession;

  Future<void> signIn({required String email, required String password}) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<Session?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: fullName == null || fullName.trim().isEmpty
          ? null
          : {'full_name': fullName.trim()},
    );
    return response.session;
  }

  Future<void> sendPasswordReset(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String password) async {
    if (currentSession == null) {
      throw const AuthException('Password recovery session is no longer active.');
    }
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  Future<dynamic> resolveIdentity() async {
    return Supabase.instance.client.rpc('resolve_identity');
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
