export function verifyPhase5IdentityInvariant(input: {
  sourceShId: string
  derivedShId?: string
  recoveryTargetShId?: string
}) {
  if (input.derivedShId !== undefined && input.derivedShId === input.sourceShId) {
    throw new Error('PHASE5_IDENTITY_COLLISION')
  }
  if (input.recoveryTargetShId !== undefined && input.recoveryTargetShId !== input.sourceShId) {
    throw new Error('PHASE5_RECOVERY_IDENTITY_REPLACEMENT')
  }
  return true
}

export function verifyPhase5Scope(input: {
  authorized: boolean
  audited: boolean
}) {
  if (!input.authorized) throw new Error('PHASE5_AUTHORIZATION_REQUIRED')
  if (!input.audited) throw new Error('PHASE5_AUDIT_REQUIRED')
  return true
}
