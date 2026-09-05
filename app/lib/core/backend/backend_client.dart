import 'package:supabase_flutter/supabase_flutter.dart';

const _backendUrl = 'https://pkhkgvsrqeupvwoqjwmd.supabase.co';
const _backendPublishableKey = 'sb_publishable_T9vHVJy999ipBLkxKoBD1w_lWZcmk60';

Future<void> initializeBackend() async {
  await Supabase.initialize(
    url: _backendUrl,
    publishableKey: _backendPublishableKey,
  );
}

SupabaseClient get backendClient => Supabase.instance.client;
