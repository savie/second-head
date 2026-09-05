import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://pkhkgvsrqeupvwoqjwmd.supabase.co';

// Supabase publishable keys are intended for client applications. Runtime
// authorization remains enforced by Supabase Auth + RLS.
const _supabasePublishableKey = 'sb_publishable_T9vHVJy999ipBLkxKoBD1w_lWZcmk60';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );
}

SupabaseClient get supabaseClient => Supabase.instance.client;
