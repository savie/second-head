export type CloneAgreementStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'REVOKED'

export interface CloneAgreement {
  agreementId: string
  sourceShId: string
  sourceAccountId: string
  targetAccountId: string
  status: CloneAgreementStatus
  scope: Record<string, unknown>
}

export function assertCloneBoundary(input: {
  sourceShId: string
  cloneShId: string
  agreementStatus: CloneAgreementStatus
  sourceAccountId: string
  targetAccountId: string
}) {
  if (input.sourceShId === input.cloneShId) throw new Error('CLONE_IDENTITY_COLLISION')
  if (input.sourceAccountId === input.targetAccountId) throw new Error('CLONE_TARGET_MUST_BE_DISTINCT')
  if (input.agreementStatus !== 'APPROVED') throw new Error('CLONE_APPROVAL_REQUIRED')
  return true
}
