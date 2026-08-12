import { assertCloneBoundary } from './clone_boundary'

describe('P5B Clone Boundary & Agreement', () => {
  it('requires a distinct clone identity and approved agreement', () => {
    expect(assertCloneBoundary({
      sourceShId: 'source',
      cloneShId: 'clone',
      agreementStatus: 'APPROVED',
      sourceAccountId: 'account-a',
      targetAccountId: 'account-b',
    })).toBe(true)
  })

  it('rejects silent identity collision', () => {
    expect(() => assertCloneBoundary({
      sourceShId: 'same',
      cloneShId: 'same',
      agreementStatus: 'APPROVED',
      sourceAccountId: 'account-a',
      targetAccountId: 'account-b',
    })).toThrow('CLONE_IDENTITY_COLLISION')
  })

  it('rejects cloning without approval', () => {
    expect(() => assertCloneBoundary({
      sourceShId: 'source',
      cloneShId: 'clone',
      agreementStatus: 'PENDING',
      sourceAccountId: 'account-a',
      targetAccountId: 'account-b',
    })).toThrow('CLONE_APPROVAL_REQUIRED')
  })
})
