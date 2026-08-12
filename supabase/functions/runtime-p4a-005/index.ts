import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 })

  const authHeader = req.headers.get('Authorization') ?? ''
  if (!authHeader.startsWith('Bearer ')) {
    return Response.json({ error: 'UNAUTHENTICATED' }, { status: 401 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  )

  const { data: { user }, error: userError } = await supabase.auth.getUser()
  if (userError || !user) return Response.json({ error: 'UNAUTHENTICATED' }, { status: 401 })

  const body = await req.json()
  const shId = String(body.sh_id ?? '')
  const role = String(body.role ?? '')
  const content = String(body.content ?? '')

  if (!shId || !['user', 'assistant', 'system'].includes(role) || !content.trim()) {
    return Response.json({ error: 'INVALID_CONVERSATION_INPUT' }, { status: 400 })
  }

  const { data, error } = await supabase.rpc('runtime_record_conversation', {
    p_sh_id: shId,
    p_role: role,
    p_content: content,
    p_metadata: body.metadata ?? {},
  })

  if (error) return Response.json({ error: error.message }, { status: 403 })
  return Response.json({ conversation: data })
})
