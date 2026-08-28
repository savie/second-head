import { supabase } from '../../services/backend';
import { recordRecoveryJourneyEvent } from '../journey/recovery-journey';

export type RecoverySnapshot = {
  snapshot_id: string;
  sh_id: string;
  account_id: string;
  snapshot_kind: 'FULL' | 'METADATA';
  manifest: Record<string, unknown>;
  created_at: string;
};

export type RecoveryEvent = {
  recovery_event_id: string;
  snapshot_id: string;
  sh_id: string;
  outcome: 'VALIDATED' | 'RESTORED' | 'FAILED';
  continuity_status: 'CONTINUOUS' | 'GAP_DETECTED' | 'GAP_UNRESOLVED' | 'RECOVERED';
  gap_code: string | null;
  created_at: string;
};

export type PortabilityExport = {
  export_id: string;
  snapshot_id: string;
  sh_id: string;
  format: 'JSON';
  manifest: Record<string, unknown>;
  status: 'READY' | 'IMPORTED' | 'REVOKED';
  created_at: string;
  imported_at: string | null;
};

export async function listRecoverySnapshots(shId: string) {
  const { data, error } = await supabase
    .from('recovery_snapshots')
    .select('snapshot_id,sh_id,account_id,snapshot_kind,manifest,created_at')
    .eq('sh_id', shId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as RecoverySnapshot[];
}

export async function listRecoveryEvents(shId: string) {
  const { data, error } = await supabase
    .from('recovery_events')
    .select('recovery_event_id,snapshot_id,sh_id,outcome,continuity_status,gap_code,created_at')
    .eq('sh_id', shId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as RecoveryEvent[];
}

export async function listPortabilityExports(shId: string) {
  const { data, error } = await supabase
    .from('portability_exports')
    .select('export_id,snapshot_id,sh_id,format,manifest,status,created_at,imported_at')
    .eq('sh_id', shId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []) as PortabilityExport[];
}

export async function createRecoverySnapshot(shId: string) {
  const { data, error } = await backend.rpc('runtime_create_recovery_snapshot', {
    p_sh_id: shId,
  });
  if (error) throw error;
  return data as string;
}

export async function restoreRecoverySnapshot(snapshotId: string) {
  const { data, error } = await backend.rpc('runtime_restore_recovery_snapshot', {
    p_snapshot_id: snapshotId,
  });
  if (error) throw error;

  const recoveryEventId = data as string;
  await recordRecoveryJourneyEvent(recoveryEventId);
  return recoveryEventId;
}

export async function createPortabilityExport(snapshotId: string) {
  const { data, error } = await backend.rpc('runtime_create_portability_export', {
    p_snapshot_id: snapshotId,
  });
  if (error) throw error;
  return data as string;
}
