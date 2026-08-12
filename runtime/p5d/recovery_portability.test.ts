import { assertPortableManifest, assertRecoveryIdentity, classifyRecoveryResult } from './recovery_portability'

describe('P5D Recovery, Backup & Portability', () => {
  it('preserves identity during recovery', () => {
    expect(assertRecoveryIdentity({ snapshotShId: 'sh-1', targetShId: 'sh-1' })).toBe(true)
  })

  it('rejects recovery into a different identity', () => {
    expect(() => assertRecoveryIdentity({ snapshotShId: 'sh-1', targetShId: 'sh-2' })).toThrow('RECOVERY_IDENTITY_MISMATCH')
  })

  it('records unresolved continuity loss instead of pretending recovery was perfect', () => {
    expect(classifyRecoveryResult({ restored: true, knownGap: true })).toBe('GAP_UNRESOLVED')
  })

  it('requires portability manifests to preserve the SH identity root', () => {
    expect(() => assertPortableManifest({ shId: 'sh-1', manifestShId: 'sh-2' })).toThrow('PORTABILITY_IDENTITY_MISMATCH')
  })
})
