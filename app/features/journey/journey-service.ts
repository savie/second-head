import { supabase } from '../../services/supabase';

export type JourneyEvent = {
  event_id: string;
  event_type: string;
  occurred_at: string;
  continuity_status: string;
  gap_code: string | null;
  payload: Record<string, unknown> | null;
  source_ref: string | null;
  created_at: string;
};

export async function loadJourneyEvents(shId: string, limit = 50): Promise<JourneyEvent[]> {
  if (!shId.trim()) throw new Error('JOURNEY_SH_ID_REQUIRED');
  const safeLimit = Math.min(Math.max(Math.trunc(limit), 1), 50);

  const { data, error } = await supabase
    .from('journey_events')
    .select('event_id,event_type,occurred_at,continuity_status,gap_code,payload,source_ref,created_at')
    .eq('sh_id', shId)
    .order('occurred_at', { ascending: false })
    .limit(safeLimit);

  if (error) throw new Error(`JOURNEY_RETRIEVAL_FAILED: ${error.message}`);
  return (data ?? []) as JourneyEvent[];
}
