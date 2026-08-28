import { createJourneyRuntimeDecisionSink, type JourneyEventRecorder, type JourneySignalDetector } from '../../../runtime/p5a/journey_decision';
import { backend } from '../../services/backend';

type RecoveryRow = {
  recovery_event_id: string;
  sh_id: string;
  outcome: 'VALIDATED' | 'RESTORED' | 'FAILED';
  continuity_status: 'CONTINUOUS' | 'GAP_DETECTED' | 'GAP_UNRESOLVED' | 'RECOVERED';
  gap_code: string | null;
};

const recorder: JourneyEventRecorder = {
  async record(input) {
    const { data, error } = await backend.rpc('runtime_record_journey_event', {
      p_sh_id: input.sh_id,
      p_event_type: input.event_type,
      p_occurred_at: input.occurred_at ?? new Date().toISOString(),
      p_continuity_status: input.continuity_status ?? 'CONTINUOUS',
      p_gap_code: input.gap_code ?? null,
      p_payload: input.payload,
      p_source_ref: input.source_ref ?? null,
    });
    if (error) throw error;
    if (!data) throw new Error('JOURNEY_EVENT_ID_MISSING');
    return data as string;
  },
};

export async function recordRecoveryJourneyEvent(recoveryEventId: string) {
  if (!recoveryEventId.trim()) throw new Error('RECOVERY_EVENT_ID_REQUIRED');

  const { data, error } = await backend
    .from('recovery_events')
    .select('recovery_event_id,sh_id,outcome,continuity_status,gap_code')
    .eq('recovery_event_id', recoveryEventId)
    .single();
  if (error) throw error;

  const recovery = data as RecoveryRow;

  const detector: JourneySignalDetector = {
    async detect() {
      if (recovery.outcome !== 'RESTORED' && recovery.continuity_status !== 'RECOVERED') {
        return { automatic_candidate: null };
      }

      return {
        automatic_candidate: {
          event_type: 'RECOVERY',
          continuity_status: recovery.continuity_status,
          gap_code: recovery.gap_code,
          source_ref: `recovery:${recovery.recovery_event_id}`,
          payload: {
            recovery_event_id: recovery.recovery_event_id,
            outcome: recovery.outcome,
          },
        },
      };
    },
  };

  const sink = createJourneyRuntimeDecisionSink(detector, recorder);
  return sink.decideAndRecord({
    sh_id: recovery.sh_id,
    user_message: '',
    response: recovery,
  });
}
