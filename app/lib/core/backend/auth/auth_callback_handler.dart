import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authResetCallbackUri = 'secondhead://reset-password';
const authOAuthCallbackUri = 'secondhead://auth-callback';

class AuthCallbackHandler {
  AuthCallbackHandler({
    AppLinks? appLinks,
    void Function()? onPasswordRecovery,
  })  : _appLinks = appLinks ?? AppLinks(),
        _onPasswordRecovery = onPasswordRecovery;

  final AppLinks _appLinks;
  final void Function()? _onPasswordRecovery;
  StreamSubscription<Uri>? _subscription;
  String? _lastHandledUri;

  Future<void> start() async {
    _subscription ??= _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handle(uri)),
      onError: (_, __) {},
    );

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handle(initialUri);
    }
  }

  Future<void> _handle(Uri uri) async {
    if (!_isAuthCallback(uri)) return;

    final value = uri.toString();
    if (_lastHandledUri == value) return;
    _lastHandledUri = value;

    await Supabase.instance.client.auth.getSessionFromUrl(uri);

    if (uri.scheme == 'secondhead' && uri.host == 'reset-password') {
      if (Supabase.instance.client.auth.currentSession != null) {
        _onPasswordRecovery?.call();
      }
    }
  }

  bool _isAuthCallback(Uri uri) =>
      uri.scheme == 'secondhead' &&
      (uri.host == 'reset-password' || uri.host == 'auth-callback');

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
