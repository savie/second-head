import { assertInheritanceBoundary, assertLegacyBoundary } from './inheritance_legacy_succession'

describe('P5C Inheritance, Legacy & Succession', () => {
  it('keeps inheritance identity separate from the source', () => {
    expect(assertInheritanceBoundary({
      sourceShId: 'source',
      targetShId: 'target',
      authorizationStatus: 'APPROVED',
    })).toBe(true)
  })

  it('rejects inheritance without authorization', () => {
    expect(() => assertInheritanceBoundary({
      sourceShId: 'source',
      targetShId: 'target',
      authorizationStatus: 'PENDING',
    })).toThrow('INHERITANCE_AUTHORIZATION_REQUIRED')
  })

  it('does not equate preserved legacy with permanent deletion', () => {
    expect(assertLegacyBoundary({
      sourceShId: 'source',
      legacyType: 'JOURNEY',
      status: 'PRESERVED',
    }).permanentDelete).toBe(false)
  })
})
