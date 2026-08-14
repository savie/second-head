import { supabase } from '../../services/supabase';

export type SuccessionRule = {
  succession_id: string;
  source_sh_id: string;
  successor_account_id: string;
  status: 'ACTIVE' | 'REVOKED' | 'CONSUMED';
  scope: Record<string, unknown>;
  created_at: string;
  revoked_at: string | null;
};

export type InheritanceAuthorization = {
  authorization_id: string;
  source_sh_id: string;
  target_sh_id: string;
  source_account_id: string;
  target_account_id: string;
  status: 'PENDING' | 'APPROVED' | 'REVOKED';
  scope: Record<string, unknown>;
  created_at: string;
  approved_at: string | null;
  revoked_at: string | null;
};

export type LegacyRecord = {
  legacy_id: string;
  source_sh_id: string;
  legacy_type: 'MEMORY' | 'KNOWLEDGE' | 'EXPERIENCE' | 'JOURNEY' | 'HISTORY' | 'VALUE' | 'REFERENCE';
  payload: Record<string, unknown>;
  provenance: Record<string, unknown>;
  status: 'PRESERVED' | 'RELEASED' | 'PURGED';
  retention_until: string | null;
  created_at: string;
};

export async function listSuccessionRules() {
  const { data, error } = await supabase.from('succession_rules').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as SuccessionRule[];
}

export async function createSuccessionRule(input: { sourceShId: string; successorAccountId: string; scope?: Record<string, unknown> }) {
  const { data, error } = await supabase.from('succession_rules').insert({ source_sh_id: input.sourceShId.trim(), successor_account_id: input.successorAccountId.trim(), scope: input.scope ?? {} }).select('*').single();
  if (error) throw error;
  return data as SuccessionRule;
}

export async function listInheritanceAuthorizations() {
  const { data, error } = await supabase.from('inheritance_authorizations').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as InheritanceAuthorization[];
}

export async function createInheritanceAuthorization(input: { sourceShId: string; targetShId: string; sourceAccountId: string; targetAccountId: string; scope?: Record<string, unknown> }) {
  const { data, error } = await supabase.from('inheritance_authorizations').insert({ source_sh_id: input.sourceShId.trim(), target_sh_id: input.targetShId.trim(), source_account_id: input.sourceAccountId.trim(), target_account_id: input.targetAccountId.trim(), scope: input.scope ?? {} }).select('*').single();
  if (error) throw error;
  return data as InheritanceAuthorization;
}

export async function approveInheritance(authorizationId: string) {
  const { data, error } = await supabase.from('inheritance_authorizations').update({ status: 'APPROVED', approved_at: new Date().toISOString() }).eq('authorization_id', authorizationId).eq('status', 'PENDING').select('*').single();
  if (error) throw error;
  return data as InheritanceAuthorization;
}

export async function recordInheritance(authorizationId: string) {
  const { data, error } = await supabase.rpc('runtime_record_inheritance', { p_authorization_id: authorizationId, p_payload: {}, p_provenance: { source: 'sh-app' } });
  if (error) throw error;
  return data as string;
}

export async function listLegacyRecords() {
  const { data, error } = await supabase.from('legacy_records').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as LegacyRecord[];
}

export async function recordLegacy(input: { sourceShId: string; legacyType: LegacyRecord['legacy_type']; retentionUntil?: string }) {
  const { data, error } = await supabase.rpc('runtime_record_legacy', { p_source_sh_id: input.sourceShId.trim(), p_legacy_type: input.legacyType, p_payload: {}, p_provenance: { source: 'sh-app' }, p_retention_until: input.retentionUntil || null });
  if (error) throw error;
  return data as string;
}
