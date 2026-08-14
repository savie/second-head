import { supabase } from '../../services/supabase';

export type CloneAgreement = {
  agreement_id: string;
  source_sh_id: string;
  source_account_id: string;
  target_account_id: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'REVOKED';
  scope: Record<string, unknown>;
  created_at: string;
  approved_at: string | null;
  revoked_at: string | null;
};

export async function listCloneAgreements() {
  const { data, error } = await supabase
    .from('clone_agreements')
    .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at')
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as CloneAgreement[];
}

export async function createCloneAgreement(input: {
  sourceShId: string;
  sourceAccountId: string;
  targetAccountId: string;
  scope?: Record<string, unknown>;
}) {
  const { data, error } = await supabase
    .from('clone_agreements')
    .insert({
      source_sh_id: input.sourceShId.trim(),
      source_account_id: input.sourceAccountId.trim(),
      target_account_id: input.targetAccountId.trim(),
      scope: input.scope ?? {},
    })
    .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at')
    .single();
  if (error) throw error;
  return data as CloneAgreement;
}

export async function approveCloneAgreement(agreementId: string) {
  const { data, error } = await supabase
    .from('clone_agreements')
    .update({ status: 'APPROVED', approved_at: new Date().toISOString() })
    .eq('agreement_id', agreementId)
    .eq('status', 'PENDING')
    .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at')
    .single();
  if (error) throw error;
  return data as CloneAgreement;
}

export async function rejectCloneAgreement(agreementId: string) {
  const { data, error } = await supabase
    .from('clone_agreements')
    .update({ status: 'REJECTED' })
    .eq('agreement_id', agreementId)
    .eq('status', 'PENDING')
    .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at')
    .single();
  if (error) throw error;
  return data as CloneAgreement;
}

export async function executeClone(agreementId: string, cloneName?: string) {
  const { data, error } = await supabase.rpc('runtime_create_clone', {
    p_agreement_id: agreementId,
    p_clone_name: cloneName?.trim() || null,
  });
  if (error) throw error;
  return data as string;
}
