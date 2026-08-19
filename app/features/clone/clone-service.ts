import { supabase } from '../../services/supabase';

export type CloneAgreement = {
  agreement_id: string;
  source_sh_id: string;
  source_account_id: string;
  target_email: string;
  target_account_id: string | null;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'REVOKED';
  scope: Record<string, unknown>;
  created_at: string;
  approved_at: string | null;
  revoked_at: string | null;
};

const agreementSelect =
  'agreement_id,source_sh_id,source_account_id,target_email,target_account_id,status,scope,created_at,approved_at,revoked_at';

export async function listCloneAgreements() {
  const { data, error } = await supabase
    .from('clone_agreements')
    .select(agreementSelect)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as CloneAgreement[];
}

export async function createCloneAgreement(input: {
  sourceShId: string;
  sourceAccountId: string;
  targetEmail: string;
  scope?: Record<string, unknown>;
}) {
  const targetEmail = input.targetEmail.trim().toLowerCase();
  if (!targetEmail) throw new Error('Target recipient email is required');

  const { data, error } = await supabase
    .from('clone_agreements')
    .insert({
      source_sh_id: input.sourceShId.trim(),
      source_account_id: input.sourceAccountId.trim(),
      target_email: targetEmail,
      target_account_id: null,
      scope: input.scope ?? {},
    })
    .select(agreementSelect)
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
    .select(agreementSelect)
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
    .select(agreementSelect)
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
  if (!data) throw new Error('Clone materialization returned no SH ID');
  return data as string;
}
