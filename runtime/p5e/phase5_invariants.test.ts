import { verifyPhase5IdentityInvariant, verifyPhase5Scope } from './phase5_invariants'

describe('P5E Invariant & Evidence Verification', () => {
  it('rejects a derived SH that silently reuses the source identity', () => {
    expect(() => verifyPhase5IdentityInvariant({
      sourceShId: 'source',
      derivedShId: 'source',
    })).toThrow('PHASE5_IDENTITY_COLLISION')
  })

  it('rejects recovery that replaces the source identity', () => {
    expect(() => verifyPhase5IdentityInvariant({
      sourceShId: 'source',
      recoveryTargetShId: 'replacement',
    })).toThrow('PHASE5_RECOVERY_IDENTITY_REPLACEMENT')
  })

  it('requires authorization and audit evidence at the integration gate', () => {
    expect(verifyPhase5Scope({ authorized: true, audited: true })).toBe(true)
  })
})
