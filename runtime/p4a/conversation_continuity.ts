export type ConversationRole = 'user' | 'assistant' | 'system'

export interface ConversationRow {
  conversation_id: string
  sh_id: string
  role: ConversationRole
  content: string
  created_at: string
}

export interface ConversationContinuity {
  messages: ConversationRow[]
  time_gap_seconds: number | null
  is_new_virtual_session: boolean
}

export interface ConversationContinuityDeps {
  now: Date
  sessionGapSeconds: number
  loadRecent: (shId: string, limit: number) => Promise<ConversationRow[]>
  append: (input: { shId: string; role: ConversationRole; content: string }) => Promise<void>
}

export async function assembleConversationContinuity(
  shId: string,
  deps: ConversationContinuityDeps,
  limit = 14,
): Promise<ConversationContinuity> {
  const rows = (await deps.loadRecent(shId, limit)).slice().sort(
    (a, b) => Date.parse(a.created_at) - Date.parse(b.created_at),
  )

  const latest = rows.at(-1)
  const timeGap = latest ? Math.max(0, deps.now.getTime() - Date.parse(latest.created_at)) / 1000 : null

  return {
    messages: rows,
    time_gap_seconds: timeGap,
    is_new_virtual_session: timeGap !== null && timeGap > deps.sessionGapSeconds,
  }
}

export function buildConversationRecord(
  shId: string,
  role: ConversationRole,
  content: string,
) {
  if (!content.trim()) throw new Error('CONVERSATION_CONTENT_REQUIRED')
  return { shId, role, content }
}
