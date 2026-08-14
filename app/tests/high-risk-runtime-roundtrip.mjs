const base = process.env.SUPABASE_URL;
const anon = process.env.SUPABASE_ANON_KEY;
const email = process.env.SH_TEST_EMAIL;
const password = process.env.SH_TEST_PASSWORD;

if (!base || !anon || !email || !password) throw new Error('Missing controlled verification environment');

async function request(path, options = {}) {
  const response = await fetch(`${base}${path}`, {
    ...options,
    headers: {
      apikey: anon,
      ...(options.headers ?? {}),
    },
  });
  const text = await response.text();
  let payload;
  try { payload = JSON.parse(text); } catch { payload = text; }
  if (!response.ok) throw new Error(`${path} ${response.status}: ${typeof payload === 'string' ? payload : JSON.stringify(payload)}`);
  return payload;
}

async function rpc(name, body, token) {
  return request(`/rest/v1/rpc/${name}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

const session = await request('/auth/v1/token?grant_type=password', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password }),
});
const token = session.access_token;
if (!token) throw new Error('Controlled test login returned no access token');

const identities = await rpc('resolve_identity', {}, token);
if (!Array.isArray(identities) || identities.length !== 1) throw new Error(`Expected exactly one SH identity, got ${JSON.stringify(identities)}`);
const shId = identities[0].sh_id;

const snapshotId = await rpc('runtime_create_recovery_snapshot', { p_sh_id: shId }, token);
if (!snapshotId) throw new Error('Recovery snapshot creation returned no snapshot id');

const actionId = `p4f006-recovery-${Date.now()}`;
const prepare = await request('/functions/v1/runtime-p4f-006', {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mode: 'prepare',
    action_id: actionId,
    operation: 'RECOVERY_RESTORE',
    target_id: snapshotId,
    title: 'Controlled high-risk recovery restore',
    description: 'Restore the controlled SH recovery snapshot as the P4F high-risk E2E proof.',
  }),
});
if (!prepare.confirmation_id || prepare.status !== 'PENDING') throw new Error(`Unexpected prepare result: ${JSON.stringify(prepare)}`);

const confirm = await request('/functions/v1/runtime-p4f-006', {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({ mode: 'confirm', confirmation_id: prepare.confirmation_id }),
});
if (confirm.status !== 'CONFIRMED') throw new Error(`Unexpected confirm result: ${JSON.stringify(confirm)}`);

const execute = await request('/functions/v1/runtime-p4f-006', {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({ mode: 'execute', confirmation_id: prepare.confirmation_id }),
});
if (execute.status !== 'EXECUTED' || !execute.recovery_event_id) throw new Error(`Unexpected execute result: ${JSON.stringify(execute)}`);

const auditRows = await request('/rest/v1/audit_events?select=event_id,event_type,status,metadata,created_at&event_type=eq.RUNTIME_ACTION&order=created_at.desc&limit=20', {
  headers: { Authorization: `Bearer ${token}` },
});
const auditForAction = auditRows.filter((row) => row.metadata?.confirmation_id === prepare.confirmation_id);
if (auditForAction.length < 3) throw new Error(`Expected create/confirm/execute audit rows for ${prepare.confirmation_id}, found ${auditForAction.length}: ${JSON.stringify(auditRows)}`);

const recoveryRows = await request(`/rest/v1/recovery_events?select=recovery_event_id,snapshot_id,sh_id,outcome,continuity_status,gap_code,created_at&recovery_event_id=eq.${encodeURIComponent(execute.recovery_event_id)}`, {
  headers: { Authorization: `Bearer ${token}` },
});
if (recoveryRows.length !== 1 || recoveryRows[0].outcome !== 'RESTORED') throw new Error(`Recovery event verification failed: ${JSON.stringify(recoveryRows)}`);

console.log(JSON.stringify({
  status: 'PASS',
  sh_id: shId,
  snapshot_id: snapshotId,
  action_id: actionId,
  confirmation_id: prepare.confirmation_id,
  confirmation_status: confirm.status,
  execution_status: execute.status,
  recovery_event_id: execute.recovery_event_id,
  audit_rows: auditForAction.length,
  recovery_event: recoveryRows[0],
}, null, 2));
