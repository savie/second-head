import { supabase } from '../../services/supabase';

export type TransferSelection = {
  memory_ids?: string[];
  knowledge_ids?: string[];
  experience_ids?: string[];
  journey_event_ids?: string[];
  reference_ids?: string[];
  value_ids?: string[];
  history_ids?: string[];
};

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

export type Experience = {
  experience_id: string;
  sh_id: string;
  account_id: string;
  experience_type: string;
  content: string;
  scope: 'PRIVATE' | 'GENERAL';
  visibility: 'OWNER_ONLY' | 'SHARED';
  source_ref: string | null;
  provenance: Record<string, unknown>;
  lifecycle: 'ACTIVE' | 'ARCHIVED' | 'DEACTIVATED';
  occurred_at: string;
  created_at: string;
  updated_at: string;
};

export async function listSuccessionRules() {
  const { data, error } = await supabase.from('succession_rules').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as SuccessionRule[];
}

export async function createSuccessionRule(input: { sourceShId: string; successorAccountId: string; scope?: TransferSelection }) {
  const { data, error } = await supabase.from('succession_rules').insert({ source_sh_id: input.sourceShId.trim(), successor_account_id: input.successorAccountId.trim(), scope: input.scope ?? {} }).select('*').single();
  if (error) throw error;
  return data as SuccessionRule;
}

export async function executeSuccession(successionId: string) {
  const { data, error } = await supabase.rpc('runtime_execute_succession', { p_succession_id: successionId.trim() });
  if (error) throw error;
  return data as string;
}

export async function listExperiences() {
  const { data, error } = await supabase.from('experiences').select('*').order('occurred_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as Experience[];
}

export async function recordExperience(input: {
  shId: string;
  experienceType: string;
  content: string;
  scope?: Experience['scope'];
  visibility?: Experience['visibility'];
  sourceRef?: string | null;
  provenance?: Record<string, unknown>;
  occurredAt?: string;
}) {
  const { data, error } = await supabase.rpc('runtime_record_experience', {
    p_sh_id: input.shId.trim(),
    p_experience_type: input.experienceType.trim(),
    p_content: input.content,
    p_scope: input.scope ?? 'PRIVATE',
    p_visibility: input.visibility ?? 'OWNER_ONLY',
    p_source_ref: input.sourceRef ?? null,
    p_provenance: input.provenance ?? { source: 'sh-app' },
    p_occurred_at: input.occurredAt ?? new Date().toISOString(),
  });
  if (error) throw error;
  return data as string;
}

export async function listInheritanceAuthorizations() {
  const { data, error } = await supabase.from('inheritance_authorizations').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as InheritanceAuthorization[];
}

export async function createInheritanceAuthorization(input: { sourceShId: string; targetShId: string; sourceAccountId: string; targetAccountId: string; scope?: TransferSelection }) {
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
  const { data, error } = await supabase.rpc('runtime_record_inheritance', { p_authorization_id: authorizationId.trim(), p_payload: {}, p_provenance: { source: 'sh-app' } });
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

export async function preserveSelectedTransferAsLegacy(input: { sourceShId: string; scope: TransferSelection }) {
  const { data, error } = await supabase.rpc('runtime_preserve_selected_transfer_as_legacy', {
    p_source_sh_id: input.sourceShId.trim(),
    p_scope: input.scope,
  });
  if (error) throw error;
  return data as string;
}
