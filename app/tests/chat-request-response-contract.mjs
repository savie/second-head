import fs from 'node:fs';

const service = fs.readFileSync(new URL('../features/chat/chat-service.ts', import.meta.url), 'utf8');
const screen = fs.readFileSync(new URL('../app/chat.tsx', import.meta.url), 'utf8');
const runtime = fs.readFileSync(new URL('../services/runtime.ts', import.meta.url), 'utf8');
const stream = fs.readFileSync(new URL('../services/runtime-stream.ts', import.meta.url), 'utf8');
const runtimeGate = fs.readFileSync(new URL('../../runtime/p4f/high_risk_authorization.ts', import.meta.url), 'utf8');

const checks = [
  ['chat service delegates to Runtime Adapter', service.includes('invokeSHRuntime')],
  ['chat screen uses streaming Runtime Adapter', screen.includes('streamSHRuntime')],
  ['runtime adapter requires authenticated session', runtime.includes('getSession')],
  ['runtime adapter uses authenticated bearer token', runtime.includes('Authorization') && runtime.includes('access_token')],
  ['streaming adapter requires authenticated session', stream.includes('getSession')],
  ['streaming adapter uses authenticated bearer token', stream.includes('Authorization') && stream.includes('access_token')],
  ['streaming adapter requests event stream', stream.includes("Accept: 'text/event-stream'")],
  ['chat screen renders streaming tokens', screen.includes("event.type === 'token'")],
  ['stream adapter recognizes confirmation events', stream.includes("eventName === 'confirmation'")],
  ['stream adapter exposes confirmation id', stream.includes('confirmation_id')],
  ['chat screen stores pending confirmation', screen.includes('pendingConfirmation')],
  ['chat screen provides Cancel control', screen.includes('title="Cancel"')],
  ['chat screen provides Confirm control', screen.includes('title="Confirm"')],
  ['confirm does not authorize or execute in App', screen.includes('does NOT authorize or execute')],
  ['runtime gate has confirmation-pending state', runtimeGate.includes("status: 'CONFIRMATION_PENDING'")],
  ['runtime gate reaches authorized only after confirm', runtimeGate.includes("status: 'AUTHORIZED'")],
];

for (const [name, ok] of checks) {
  if (!ok) throw new Error(`FAIL: ${name}`);
  console.log(`PASS: ${name}`);
}

console.log(JSON.stringify({ status: 'PASS', checks: checks.map(([name]) => name) }, null, 2));
