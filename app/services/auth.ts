import { backend } from './backend';

export async function signInWithPassword(email: string, password: string) {
  const result = await backend.auth.signInWithPassword({ email, password });
  if (result.error) return result;

  const { data: account, error: accountError } = await supabase
    .from('accounts')
    .select('status')
    .maybeSingle();

  if (accountError) {
    await backend.auth.signOut();
    throw accountError;
  }

  if (!account || account.status === 'deactivated') {
    await backend.auth.signOut();
    throw new Error('ACCOUNT_DEACTIVATED: this account is permanently deactivated and cannot sign in.');
  }

  return result;
}

export async function signUpWithPassword(email: string, password: string) {
  return backend.auth.signUp({ email, password });
}

export async function signOut() {
  return backend.auth.signOut();
}

export async function getSession() {
  return backend.auth.getSession();
}

export function onAuthStateChange(callback: Parameters<typeof backend.auth.onAuthStateChange>[0]) {
  return backend.auth.onAuthStateChange(callback);
}
