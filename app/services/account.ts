import { supabase } from './supabase';

export type AuthenticatedAccount = {
  account_id: string;
  email: string;
  status: string;
};

export type AuthenticatedSH = {
  sh_id: string;
  sh_type: string;
  is_primary: boolean;
  canonical_name: string | null;
  status: string;
  role: string;
};

export async function loadAuthenticatedContext() {
  const { data: authData, error: authError } = await supabase.auth.getUser();
  if (authError) throw authError;
  if (!authData.user) return null;

  const { data: account, error: accountError } = await supabase
    .from('accounts')
    .select('account_id,email,status')
    .maybeSingle();
  if (accountError) throw accountError;
  if (!account) return null;

  const { data: shRows, error: shError } = await supabase
    .from('sh_instances')
    .select('sh_id,sh_type,is_primary,canonical_name,status')
    .eq('account_id', account.account_id)
    .order('is_primary', { ascending: false });
  if (shError) throw shError;

  const { data: ownershipRows, error: ownershipError } = await supabase
    .from('sh_ownership')
    .select('sh_id,role')
    .eq('account_id', account.account_id);
  if (ownershipError) throw ownershipError;

  const roles = new Map((ownershipRows ?? []).map((row) => [row.sh_id, row.role]));

  return {
    userId: authData.user.id,
    account: account as AuthenticatedAccount,
    shInstances: (shRows ?? []).map((row) => ({
      ...row,
      role: roles.get(row.sh_id) ?? 'unknown',
    })) as AuthenticatedSH[],
  };
}
