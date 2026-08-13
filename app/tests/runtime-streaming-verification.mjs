const baseUrl = process.env.SH_SUPABASE_URL;
const anonKey = process.env.SH_SUPABASE_ANON_KEY;
const email = process.env.SH_TEST_EMAIL;
const password = process.env.SH_TEST_PASSWORD;

for (const [name, value] of Object.entries({ SH_SUPABASE_URL: baseUrl, SH_SUPABASE_ANON_KEY: anonKey, SH_TEST_EMAIL: email, SH_TEST_PASSWORD: password })) {
  if (!value) throw new Error(`Missing ${name}`);
}

const authResponse = await fetch(`${baseUrl}/auth/v1/token?grant_type=password`, {
  method: 'POST',
  headers: { apikey: anonKey, 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password }),
});
if (!authResponse.ok) throw new Error(`Auth failed: ${await authResponse.text()}`);
const auth = await authResponse.json();
if (!auth.access_token) throw new Error('Auth response missing access_token');

const runtimeResponse = await fetch(`${baseUrl}/functions/v1/runtime-p4a-001`, {
  method: 'POST',
  headers: {
    apikey: anonKey,
    Authorization: `Bearer ${auth.access_token}`,
    'Content-Type': 'application/json',
    Accept: 'text/event-stream',
  },
  body: JSON.stringify({ user_message: 'streaming verification', stream: true }),
});
if (!runtimeResponse.ok) throw new Error(`Streaming runtime failed: ${await runtimeResponse.text()}`);
if (!runtimeResponse.body) throw new Error('Streaming runtime returned no body');
const contentType = runtimeResponse.headers.get('content-type') ?? '';
if (!contentType.includes('text/event-stream')) throw new Error(`Expected text/event-stream, got ${contentType}`);

const reader = runtimeResponse.body.getReader();
const decoder = new TextDecoder();
let raw = '';
while (true) {
  const { value, done } = await reader.read();
  raw += decoder.decode(value ?? new Uint8Array(), { stream: !done });
  if (done) break;
}

if (!raw.includes('event: token')) throw new Error('Missing token event');
if (!raw.includes('event: complete')) throw new Error('Missing complete event');

const tokenPayloads = raw
  .split('\n\n')
  .filter((block) => block.includes('event: token'))
  .map((block) => block.split('\n').find((line) => line.startsWith('data: '))?.slice(6))
  .filter(Boolean)
  .map((data) => JSON.parse(data));

if (tokenPayloads.length === 0) throw new Error('Missing token payload');
if (!tokenPayloads.some((payload) => typeof payload.text === 'string' && payload.text.length > 0)) {
  throw new Error('Missing non-empty streamed token content');
}

console.log(JSON.stringify({
  status: 'PASS',
  content_type: contentType,
  token_event: true,
  token_payloads: tokenPayloads.length,
  complete_event: true,
}, null, 2));
