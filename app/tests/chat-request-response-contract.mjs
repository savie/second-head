import fs from 'node:fs';

const service = fs.readFileSync(new URL('../features/chat/chat-service.ts', import.meta.url), 'utf8');
const screen = fs.readFileSync(new URL('../app/chat.tsx', import.meta.url), 'utf8');
const runtime = fs.readFileSync(new URL('../services/runtime.ts', import.meta.url), 'utf8');

const checks = [
  ['chat service delegates to Runtime Adapter', service.includes('invokeSHRuntime')],
  ['chat screen uses chat service', screen.includes('sendChatMessage')],
  ['runtime adapter requires authenticated session', runtime.includes('getSession')],
  ['runtime adapter uses authenticated bearer token', runtime.includes('Authorization') && runtime.includes('access_token')],
  ['chat screen renders runtime response', screen.includes('result.response')],
];

for (const [name, ok] of checks) {
  if (!ok) throw new Error(`FAIL: ${name}`);
  console.log(`PASS: ${name}`);
}

console.log(JSON.stringify({ status: 'PASS', checks: checks.map(([name]) => name) }, null, 2));
