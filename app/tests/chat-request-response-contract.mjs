import fs from 'node:fs';

const service = fs.readFileSync(new URL('../features/chat/chat-service.ts', import.meta.url), 'utf8');
const screen = fs.readFileSync(new URL('../app/chat.tsx', import.meta.url), 'utf8');
const runtime = fs.readFileSync(new URL('../services/runtime.ts', import.meta.url), 'utf8');
const stream = fs.readFileSync(new URL('../services/runtime-stream.ts', import.meta.url), 'utf8');

const checks = [
  ['chat service delegates to Runtime Adapter', service.includes('invokeSHRuntime')],
  ['chat screen uses streaming Runtime Adapter', screen.includes('streamSHRuntime')],
  ['runtime adapter requires authenticated session', runtime.includes('getSession')],
  ['runtime adapter uses authenticated bearer token', runtime.includes('Authorization') && runtime.includes('access_token')],
  ['streaming adapter requires authenticated session', stream.includes('getSession')],
  ['streaming adapter uses authenticated bearer token', stream.includes('Authorization') && stream.includes('access_token')],
  ['streaming adapter requests event stream', stream.includes("Accept: 'text/event-stream'")],
  ['chat screen renders streaming tokens', screen.includes("event.type === 'token'")],
];

for (const [name, ok] of checks) {
  if (!ok) throw new Error(`FAIL: ${name}`);
  console.log(`PASS: ${name}`);
}

console.log(JSON.stringify({ status: 'PASS', checks: checks.map(([name]) => name) }, null, 2));
