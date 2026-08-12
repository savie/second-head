import { classifyContinuityGap, validateJourneyEvent } from './journey_continuity'

describe('P5A Journey & Continuity Gap', () => {
  it('accepts a continuous event without a gap code', () => {
    expect(validateJourneyEvent({
      shId: 'sh-1',
      eventType: 'EXPERIENCE',
    }).continuityStatus).toBe('CONTINUOUS')
  })

  it('requires an explicit gap code when a gap is declared', () => {
    expect(() => validateJourneyEvent({
      shId: 'sh-1',
      eventType: 'MIGRATION',
      continuityStatus: 'GAP_DETECTED',
    })).toThrow('JOURNEY_GAP_CODE_REQUIRED')
  })

  it('detects a temporal continuity gap without rewriting identity', () => {
    expect(classifyContinuityGap({
      expectedAt: '2026-08-12T10:00:00Z',
      observedAt: '2026-08-12T10:01:30Z',
      gapThresholdSeconds: 30,
    })).toEqual({
      continuityStatus: 'GAP_DETECTED',
      gapSeconds: 90,
      gapCode: 'TEMPORAL_GAP',
    })
  })
})
