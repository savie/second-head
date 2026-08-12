export function assertRecoveryIdentity(input: { snapshotShId: string; targetShId: string }) {
  if (input.snapshotShId !== input.targetShId) throw new Error('RECOVERY_IDENTITY_MISMATCH')
  return true
}

export function classifyRecoveryResult(input: {
  restored: boolean
  knownGap?: boolean
}) {
  if (input.restored && !input.knownGap) return 'RECOVERED' as const
  if (input.knownGap) return 'GAP_UNRESOLVED' as const
  return 'GAP_DETECTED' as const
}

export function assertPortableManifest(input: { shId: string; manifestShId: string }) {
  if (input.shId !== input.manifestShId) throw new Error('PORTABILITY_IDENTITY_MISMATCH')
  return true
}
