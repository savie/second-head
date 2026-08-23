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

async function rest(path, options = {}) {
  const response = await fetch(`${base}${path}`, { ...options, headers: { ...headers, ...options.headers } });
  const text = await response.text();
  if (!response.ok) throw new Error(`REST_FAILED ${response.status}: ${text}`);
  return text ? JSON.parse(text) : null;
}

async function rpc(name, body, authHeaders) {
  const response = await fetch(`${base}/rest/v1/rpc/${name}`, {
    method: 'POST',
    headers: authHeaders,
    body: JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok) throw new Error(`${name}_FAILED ${response.status}: ${text}`);
  return text ? JSON.parse(text) : null;
}

const signIn = await fetch(`${base}/auth/v1/token?grant_type=password`, {
  method: 'POST', headers,
  body: JSON.stringify({ email: process.env.SH_TEST_EMAIL, password: process.env.SH_TEST_PASSWORD }),
});
if (!signIn.ok) throw new Error(`AUTH_SIGN_IN_FAILED ${signIn.status}: ${await signIn.text()}`);
const auth = await signIn.json();
if (!auth.access_token || !auth.user?.id) throw new Error('AUTH_SESSION_INVALID');
const authHeaders = { ...headers, Authorization: `Bearer ${auth.access_token}` };
const verificationMarker = `recovery-roundtrip-${crypto.randomUUID()}`;
let shId;

try {
  const links = await rest(`/rest/v1/account_auth_links?select=account_id&provider=eq.supabase&subject_ref=eq.${encodeURIComponent(auth.user.id)}`, { headers: authHeaders });
  if (links.length !== 1) throw new Error(`ACCOUNT_LINK_ASSERTION_FAILED: ${JSON.stringify(links)}`);
  const accountId = links[0].account_id;
  const shRows = await rest(`/rest/v1/sh_instances?select=sh_id,account_id,is_primary,status&account_id=eq.${encodeURIComponent(accountId)}&order=is_primary.desc`, { headers: authHeaders });
  if (!shRows.length || shRows.some((row) => row.account_id !== accountId)) throw new Error(`SH_SCOPE_ASSERTION_FAILED: ${JSON.stringify(shRows)}`);
  shId = shRows[0].sh_id;

  const snapshotId = await rpc('runtime_create_recovery_snapshot', { p_sh_id: shId, p_verification_marker: verificationMarker }, authHeaders);
  if (!snapshotId) throw new Error('RECOVERY_SNAPSHOT_ID_MISSING');

  const snapshotRows = await rest(`/rest/v1/recovery_snapshots?select=snapshot_id,sh_id,account_id,snapshot_kind,manifest&snapshot_id=eq.${encodeURIComponent(snapshotId)}`, { headers: authHeaders });
  if (snapshotRows.length !== 1 || snapshotRows[0].sh_id !== shId || snapshotRows[0].account_id !== accountId || snapshotRows[0].manifest?.verification_marker !== verificationMarker) {
    throw new Error(`RECOVERY_SNAPSHOT_SCOPE_FAILED: ${JSON.stringify(snapshotRows)}`);
  }

  const manifest = snapshotRows[0].manifest ?? {};
  const knowledge = Array.isArray(manifest.knowledge) ? manifest.knowledge : [];
  for (const row of knowledge) {
    if (row.scope !== 'PRIVATE' || row.sh_id !== shId) {
      throw new Error(`RECOVERY_KNOWLEDGE_ISOLATION_FAILED: ${JSON.stringify(row)}`);
    }
  }
  if (Object.prototype.hasOwnProperty.call(manifest, 'knowledge') === false) throw new Error('RECOVERY_KNOWLEDGE_MANIFEST_MISSING');

  const recoveryEventId = await rpc('runtime_restore_recovery_snapshot', { p_snapshot_id: snapshotId }, authHeaders);
  if (!recoveryEventId) throw new Error('RECOVERY_EVENT_ID_MISSING');
  const events = await rest(`/rest/v1/recovery_events?select=recovery_event_id,snapshot_id,sh_id,outcome,continuity_status,gap_code&recovery_event_id=eq.${encodeURIComponent(recoveryEventId)}`, { headers: authHeaders });
  if (events.length !== 1 || events[0].snapshot_id !== snapshotId || events[0].sh_id !== shId || events[0].outcome !== 'RESTORED' || events[0].continuity_status !== 'RECOVERED') {
    throw new Error(`RECOVERY_RESULT_ASSERTION_FAILED: ${JSON.stringify(events)}`);
  }

  const exportId = await rpc('runtime_create_portability_export', { p_snapshot_id: snapshotId }, authHeaders);
  if (!exportId) throw new Error('PORTABILITY_EXPORT_ID_MISSING');
  const exports = await rest(`/rest/v1/portability_exports?select=export_id,snapshot_id,sh_id,format,status&export_id=eq.${encodeURIComponent(exportId)}`, { headers: authHeaders });
  if (exports.length !== 1 || exports[0].snapshot_id !== snapshotId || exports[0].sh_id !== shId || exports[0].format !== 'JSON' || exports[0].status !== 'READY') {
    throw new Error(`PORTABILITY_RESULT_ASSERTION_FAILED: ${JSON.stringify(exports)}`);
  }

  console.log(JSON.stringify({ status: 'PASS', account_id: accountId, sh_id: shId, snapshot_id: snapshotId, recovery_event_id: recoveryEventId, export_id: exportId, isolated: true, checks: ['authenticated source SH resolved', 'full recovery snapshot created with verification marker', 'snapshot ownership and SH scope verified', 'private Knowledge manifest present', 'private Knowledge is isolated to the recovered SH', 'snapshot restored with RECOVERED outcome', 'JSON portability export created and verified', 'verification artifacts are cleaned in finally'] }, null, 2));
} finally {
  if (shId) {
    try { await rpc('runtime_cleanup_verification_artifacts', { p_sh_id: shId, p_verification_marker: verificationMarker }, authHeaders); } catch (error) { console.error(`VERIFICATION_CLEANUP_FAILED: ${error instanceof Error ? error.message : String(error)}`); }
  }
  await fetch(`${base}/auth/v1/logout`, { method: 'POST', headers: authHeaders });
}
