export type InheritanceStatus = 'PENDING' | 'APPROVED' | 'REVOKED'

export function assertInheritanceBoundary(input: {
  sourceShId: string
  targetShId: string
  authorizationStatus: InheritanceStatus
}) {
  if (input.sourceShId === input.targetShId) throw new Error('INHERITANCE_IDENTITY_COLLISION')
  if (input.authorizationStatus !== 'APPROVED') throw new Error('INHERITANCE_AUTHORIZATION_REQUIRED')
  return true
}

export function assertLegacyBoundary(input: {
  sourceShId: string
  legacyType: string
  status: 'PRESERVED' | 'RELEASED' | 'PURGED'
}) {
  if (!input.sourceShId.trim()) throw new Error('LEGACY_SOURCE_REQUIRED')
  if (!input.legacyType.trim()) throw new Error('LEGACY_TYPE_REQUIRED')
  if (input.status === 'PURGED') return { permanentDelete: true }
  return { permanentDelete: false }
}
