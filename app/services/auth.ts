import { supabase } from './supabase';

export async function signInWithPassword(email: string, password: string) {
  const result = await supabase.auth.signInWithPassword({ email, password });
  if (result.error) return result;

  const { data: account, error: accountError } = await supabase
    .from('accounts')
    .select('status')
    .maybeSingle();

  if (accountError) {
    await supabase.auth.signOut();
    throw accountError;
  }

  if (!account || account.status === 'deactivated') {
    await supabase.auth.signOut();
    throw new Error('ACCOUNT_DEACTIVATED: this account is permanently deactivated and cannot sign in.');
  }

  return result;
}

export async function signUpWithPassword(email: string, password: string) {
  return supabase.auth.signUp({ email, password });
}

export async function signOut() {
  return supabase.auth.signOut();
}

export async function getSession() {
  return supabase.auth.getSession();
}

export function onAuthStateChange(callback: Parameters<typeof supabase.auth.onAuthStateChange>[0]) {
  return supabase.auth.onAuthStateChange(callback);
}
