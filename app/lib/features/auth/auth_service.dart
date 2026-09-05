import 'dart:async';

import '../../core/backend/auth/auth_backend.dart';
import '../../core/backend/auth/auth_backend_error.dart';
import '../../core/identity/sh_identity.dart';

class AuthService {
  AuthService({required this.identityContext});

  final ShIdentityContext identityContext;
  final AuthBackend _backend = const AuthBackend();
  StreamSubscription<dynamic>? _authSubscription;
  bool _passwordRecoveryActive = false;

  bool get isPasswordRecoveryActive => _passwordRecoveryActive;

  void startAuthStateListener({void Function()? onChanged}) {
    _authSubscription ??= _backend.authStateChanges.listen(
      (data) async {
        switch (data.event.toString()) {
          case 'AuthChangeEvent.signedIn':
          case 'AuthChangeEvent.tokenRefreshed':
          case 'AuthChangeEvent.userUpdated':
            if (data.session != null) {
              try {
                await resolveIdentity();
                onChanged?.call();
              } catch (_) {
                identityContext.clear();
                onChanged?.call();
              }
            }
            break;
          case 'AuthChangeEvent.passwordRecovery':
            _passwordRecoveryActive = true;
            onChanged?.call();
            break;
          case 'AuthChangeEvent.signedOut':
            _passwordRecoveryActive = false;
            identityContext.clear();
            onChanged?.call();
            break;
          default:
            break;
        }
      },
      onError: (_, __) => onChanged?.call(),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _backend.signIn(email: email.trim(), password: password);
      await resolveIdentity();
    } catch (error) {
      throw _toError(error);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _backend.signInWithGoogle();
    } catch (error) {
      throw _toError(error);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final session = await _backend.signUp(
        email: email.trim(),
        password: password,
        fullName: fullName,
      );
      if (session == null) {
        throw const AuthBackendError(
          'Account created. Check your email to confirm the account before signing in.',
        );
      }
      await resolveIdentity();
    } catch (error) {
      throw _toError(error);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _backend.sendPasswordReset(email.trim());
    } catch (error) {
      throw _toError(error);
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _backend.updatePassword(password);
      await resolveIdentity();
    } catch (error) {
      throw _toError(error);
    }
  }

  void finishPasswordRecovery() => _passwordRecoveryActive = false;

  Future<void> restoreSession() async {
    if (_backend.currentSession == null) {
      identityContext.clear();
      return;
    }
    await resolveIdentity();
  }

  Future<void> resolveIdentity() async {
    if (_backend.currentSession == null) {
      identityContext.clear();
      throw const AuthBackendError('No authenticated session.');
    }
    try {
      final result = await _backend.resolveIdentity();
      if (result is! List || result.length != 1 || result.first is! Map) {
        throw const AuthBackendError('Unable to resolve the authenticated SH identity.');
      }
      final row = Map<String, dynamic>.from(result.first as Map);
      final accountId = row['account_id']?.toString();
      final shId = row['sh_id']?.toString();
      final ownershipRole = row['ownership_role']?.toString();
      if (accountId == null || shId == null || ownershipRole == null) {
        throw const AuthBackendError('Authenticated identity is incomplete.');
      }
      identityContext.setIdentity(
        ShIdentity(
          accountId: accountId,
          shId: shId,
          ownershipRole: ownershipRole,
        ),
      );
    } catch (error) {
      throw _toError(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _backend.signOut();
    } catch (error) {
      throw _toError(error);
    } finally {
      _passwordRecoveryActive = false;
      identityContext.clear();
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
  }

  AuthBackendError _toError(Object error) {
    if (error is AuthBackendError) return error;
    return AuthBackendError(error.toString());
  }
}
