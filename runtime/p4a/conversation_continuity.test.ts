import { assembleConversationContinuity, buildConversationRecord } from './conversation_continuity'

const now = new Date('2026-08-12T12:00:00Z')

test('keeps recent conversation chronological and detects virtual session boundary', async () => {
  const result = await assembleConversationContinuity('sh-1', {
    now,
    sessionGapSeconds: 3600,
    loadRecent: async () => [
      { conversation_id: '2', sh_id: 'sh-1', role: 'assistant', content: 'b', created_at: '2026-08-12T10:00:00Z' },
      { conversation_id: '1', sh_id: 'sh-1', role: 'user', content: 'a', created_at: '2026-08-12T09:59:00Z' },
    ],
    append: async () => undefined,
  })

  expect(result.messages.map((m) => m.conversation_id)).toEqual(['1', '2'])
  expect(result.is_new_virtual_session).toBe(true)
})

test('does not create a session table or mutate context during assembly', async () => {
  const result = await assembleConversationContinuity('sh-1', {
    now,
    sessionGapSeconds: 3600,
    loadRecent: async () => [],
    append: async () => { throw new Error('append must not run during assembly') },
  })

  expect(result.messages).toEqual([])
  expect(result.is_new_virtual_session).toBe(false)
})

test('rejects empty conversation content', () => {
  expect(() => buildConversationRecord('sh-1', 'user', '   ')).toThrow('CONVERSATION_CONTENT_REQUIRED')
})
