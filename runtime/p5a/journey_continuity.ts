export type JourneyEventType =
  | 'LIFECYCLE'
  | 'EXPERIENCE'
  | 'MEMORY'
  | 'LEARNING'
  | 'EVOLUTION'
  | 'MIGRATION'
  | 'RECOVERY'
  | 'CONTINUITY'
  | 'SHARING'
  | 'INHERITANCE'
  | 'LEGACY'

export type ContinuityStatus = 'CONTINUOUS' | 'GAP_DETECTED' | 'GAP_UNRESOLVED' | 'RECOVERED'

export interface JourneyEventInput {
  shId: string
  eventType: JourneyEventType
  occurredAt?: string
  continuityStatus?: ContinuityStatus
  gapCode?: string | null
  payload?: Record<string, unknown>
  sourceRef?: string | null
}

export function validateJourneyEvent(input: JourneyEventInput) {
  if (!input.shId.trim()) throw new Error('JOURNEY_SH_ID_REQUIRED')
  if (!input.eventType) throw new Error('JOURNEY_EVENT_TYPE_REQUIRED')

  const status = input.continuityStatus ?? 'CONTINUOUS'
  if ((status === 'GAP_DETECTED' || status === 'GAP_UNRESOLVED') && !input.gapCode?.trim()) {
    throw new Error('JOURNEY_GAP_CODE_REQUIRED')
  }

  return {
    ...input,
    continuityStatus: status,
    payload: input.payload ?? {},
  }
}

export function classifyContinuityGap(input: {
  expectedAt: string
  observedAt: string
  gapThresholdSeconds: number
  gapCode?: string
}) {
  const deltaSeconds = Math.max(0, (Date.parse(input.observedAt) - Date.parse(input.expectedAt)) / 1000)
  if (deltaSeconds <= input.gapThresholdSeconds) {
    return { continuityStatus: 'CONTINUOUS' as const, gapSeconds: deltaSeconds, gapCode: null }
  }

  return {
    continuityStatus: 'GAP_DETECTED' as const,
    gapSeconds: deltaSeconds,
    gapCode: input.gapCode?.trim() || 'TEMPORAL_GAP',
  }
}
