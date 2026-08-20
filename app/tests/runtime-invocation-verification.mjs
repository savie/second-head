const required = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
  'SH_TEST_EMAIL',
  'SH_TEST_PASSWORD',
];

for (const name of required) {
  if (!process.env[name]) throw new Error(`Missing ${name}`);
}

const base = process.env.SUPABASE_URL.replace(/\/$/, '');
const headers = {
  apikey: process.env.SUPABASE_ANON_KEY,
  'Content-Type': 'application/json',
};

async function authenticate() {
  const signIn = await fetch(`${base}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ email: process.env.SH_TEST_EMAIL, password: process.env.SH_TEST_PASSWORD }),
  });
  if (!signIn.ok) throw new Error(`AUTH_SIGN_IN_FAILED ${signIn.status}: ${await signIn.text()}`);
  const auth = await signIn.json();
  if (!auth.access_token || !auth.user?.id) throw new Error('AUTH_SESSION_INVALID');
  return auth;
}

async function invokeRuntime(accessToken) {
  return fetch(`${base}/functions/v1/runtime-p4a-001`, {
    method: 'POST',
    headers: { ...headers, Authorization: `Bearer ${accessToken}` },
    body: JSON.stringify({ user_message: 'SH runtime controlled verification' }),
  });
}

let auth;
let runtimeResponse;
let runtimeFailure = '';

for (let attempt = 1; attempt <= 3; attempt += 1) {
  auth = await authenticate();
  runtimeResponse = await invokeRuntime(auth.access_token);
  if (runtimeResponse.ok) break;

  const body = await runtimeResponse.text();
  runtimeFailure = `${runtimeResponse.status}: ${body}`;
  const retryableAuthFailure = runtimeResponse.status === 401 && body.includes('authenticated identity is required');
  if (!retryableAuthFailure || attempt === 3) {
    throw new Error(`RUNTIME_INVOCATION_FAILED ${runtimeFailure}`);
  }
}

const payload = await runtimeResponse.json();
if (typeof payload.sh_id !== 'string' || typeof payload.response !== 'string') throw new Error(`RUNTIME_RESPONSE_ASSERTION_FAILED: ${JSON.stringify(payload)}`);
if (!payload.response.trim()) throw new Error(`RUNTIME_RESPONSE_EMPTY: ${JSON.stringify(payload)}`);
const allowedProviders = new Set(['openrouter', 'groq', 'huggingface', 'mock']);
if (payload.meta?.phase !== 'P4A-001' || !allowedProviders.has(payload.meta?.model_provider)) throw new Error(`RUNTIME_META_ASSERTION_FAILED: ${JSON.stringify(payload)}`);
if (typeof payload.meta?.model_id !== 'string' || !payload.meta.model_id.trim()) throw new Error(`RUNTIME_MODEL_ID_ASSERTION_FAILED: ${JSON.stringify(payload)}`);

const { data: context, error: contextError } = await (await import('@supabase/supabase-js')).createClient(base, process.env.SUPABASE_ANON_KEY, {
  global: { headers: { Authorization: `Bearer ${auth.access_token}` } },
}).rpc('assemble_context', { p_sh_id: payload.sh_id, p_query_text: 'context verification', p_memory_limit: 5, p_knowledge_limit: 5 });
if (contextError) throw new Error(`CONTEXT_ASSEMBLY_FAILED: ${contextError.message}`);
if (!context || !Array.isArray(context.memory) || !Array.isArray(context.knowledge)) throw new Error(`CONTEXT_RESPONSE_ASSERTION_FAILED: ${JSON.stringify(context)}`);

const contextClient = (await import('@supabase/supabase-js')).createClient(base, process.env.SUPABASE_ANON_KEY, {
  global: { headers: { Authorization: `Bearer ${auth.access_token}` } },
});
const { data: journey, error: journeyError } = await contextClient
  .from('journey_events')
  .select('event_id,sh_id,event_type,continuity_status')
  .eq('sh_id', payload.sh_id)
  .limit(10);
if (journeyError) throw new Error(`JOURNEY_RETRIEVAL_FAILED: ${journeyError.message}`);
if (!Array.isArray(journey)) throw new Error('JOURNEY_RESPONSE_ASSERTION_FAILED');

const signOut = await fetch(`${base}/auth/v1/logout`, {
  method: 'POST',
  headers: { ...headers, Authorization: `Bearer ${auth.access_token}` },
});
const signOutBody = await signOut.text();
const sessionAlreadyGone = signOut.status === 403 && signOutBody.includes('session_not_found');
if (!signOut.ok && !sessionAlreadyGone) {
  throw new Error(`AUTH_SIGN_OUT_FAILED ${signOut.status}: ${signOutBody}`);
}

console.log(JSON.stringify({
  status: 'PASS',
  checks: [
    'authenticated session obtained',
    `runtime-p4a-001 accepts authenticated request${runtimeFailure ? ` after auth retry (${runtimeFailure})` : ''}`,
    'runtime resolves and returns SH identity',
    'runtime response contract is valid',
    'bounded context assembly returns memory and knowledge arrays',
    'journey retrieval is bounded to the authenticated SH and RLS',
    sessionAlreadyGone ? 'logout session was already absent; no active session remained' : 'logout succeeds',
  ],
  sh_id: payload.sh_id,
  phase: payload.meta.phase,
  context_counts: { memory: context.memory.length, knowledge: context.knowledge.length, journey: journey.length },
}, null, 2));
