const required = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SH_TEST_EMAIL', 'SH_TEST_PASSWORD'];
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
const verificationMarker = `recovery-journey-${crypto.randomUUID()}`;
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
  const recoveryEventId = await rpc('runtime_restore_recovery_snapshot', { p_snapshot_id: snapshotId }, authHeaders);
  if (!recoveryEventId) throw new Error('RECOVERY_EVENT_ID_MISSING');

  const recoveryRows = await rest(`/rest/v1/recovery_events?select=recovery_event_id,sh_id,outcome,continuity_status,gap_code&recovery_event_id=eq.${encodeURIComponent(recoveryEventId)}`, { headers: authHeaders });
  if (recoveryRows.length !== 1 || recoveryRows[0].sh_id !== shId || recoveryRows[0].outcome !== 'RESTORED' || recoveryRows[0].continuity_status !== 'RECOVERED') {
    throw new Error(`RECOVERY_RESULT_ASSERTION_FAILED: ${JSON.stringify(recoveryRows)}`);
  }

  const sourceRef = `recovery:${recoveryEventId}`;
  const before = await rest(`/rest/v1/journey_events?select=event_id,sh_id,event_type,continuity_status,source_ref&sh_id=eq.${encodeURIComponent(shId)}&source_ref=eq.${encodeURIComponent(sourceRef)}`, { headers: authHeaders });
  if (before.length !== 0) throw new Error(`RECOVERY_JOURNEY_PREEXISTING_FAILED: ${JSON.stringify(before)}`);

  const journeyEventId = await rpc('runtime_record_journey_event', {
    p_sh_id: shId,
    p_event_type: 'RECOVERY',
    p_occurred_at: new Date().toISOString(),
    p_continuity_status: 'RECOVERED',
    p_gap_code: null,
    p_payload: { recovery_event_id: recoveryEventId, outcome: 'RESTORED', verification_marker: verificationMarker },
    p_source_ref: sourceRef,
  }, authHeaders);
  if (!journeyEventId) throw new Error('RECOVERY_JOURNEY_EVENT_ID_MISSING');

  const after = await rest(`/rest/v1/journey_events?select=event_id,sh_id,event_type,continuity_status,source_ref,payload&sh_id=eq.${encodeURIComponent(shId)}&source_ref=eq.${encodeURIComponent(sourceRef)}`, { headers: authHeaders });
  if (after.length !== 1) throw new Error(`RECOVERY_JOURNEY_EXACTLY_ONE_FAILED: ${JSON.stringify(after)}`);
  const event = after[0];
  if (event.event_id !== journeyEventId || event.event_type !== 'RECOVERY' || event.continuity_status !== 'RECOVERED' || event.sh_id !== shId || event.payload?.recovery_event_id !== recoveryEventId || event.payload?.verification_marker !== verificationMarker) {
    throw new Error(`RECOVERY_JOURNEY_ASSERTION_FAILED: ${JSON.stringify(event)}`);
  }

  console.log(JSON.stringify({ status: 'PASS', mode: 'AUTHENTICATED_RUNTIME_INTEGRATION', account_id: accountId, sh_id: shId, snapshot_id: snapshotId, recovery_event_id: recoveryEventId, journey_event_id: journeyEventId, isolated: true, assertions: ['authenticated test account resolved', 'owned SH resolved', 'Recovery restored with RECOVERED outcome', 'canonical RECOVERY Journey recorder accepted the event', 'exactly one RECOVERY/RECOVERED event exists for the recovery_event_id', 'Journey event is scoped to the recovered SH', 'verification artifacts are cleaned in finally'] }, null, 2));
} finally {
  if (shId) {
    try { await rpc('runtime_cleanup_verification_artifacts', { p_sh_id: shId, p_verification_marker: verificationMarker }, authHeaders); } catch (error) { console.error(`VERIFICATION_CLEANUP_FAILED: ${error instanceof Error ? error.message : String(error)}`); }
  }
  await fetch(`${base}/auth/v1/logout`, { method: 'POST', headers: authHeaders });
}
