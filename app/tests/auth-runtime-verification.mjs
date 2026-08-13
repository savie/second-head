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

const signIn = await fetch(`${base}/auth/v1/token?grant_type=password`, {
  method: 'POST',
  headers,
  body: JSON.stringify({
    email: process.env.SH_TEST_EMAIL,
    password: process.env.SH_TEST_PASSWORD,
  }),
});

if (!signIn.ok) {
  throw new Error(`AUTH_SIGN_IN_FAILED ${signIn.status}: ${await signIn.text()}`);
}

const auth = await signIn.json();
if (!auth.access_token || !auth.user?.id) {
  throw new Error('AUTH_SESSION_INVALID');
}

const authHeaders = {
  ...headers,
  Authorization: `Bearer ${auth.access_token}`,
};

const accountResponse = await fetch(
  `${base}/rest/v1/account_auth_links?select=account_id,provider,subject_ref&provider=eq.supabase&subject_ref=eq.${encodeURIComponent(auth.user.id)}`,
  { headers: authHeaders },
);

if (!accountResponse.ok) {
  throw new Error(`ACCOUNT_LINK_LOOKUP_FAILED ${accountResponse.status}: ${await accountResponse.text()}`);
}

const links = await accountResponse.json();
if (links.length !== 1 || links[0].subject_ref !== auth.user.id) {
  throw new Error(`ACCOUNT_LINK_ASSERTION_FAILED: ${JSON.stringify(links)}`);
}

const accountId = links[0].account_id;
const shResponse = await fetch(
  `${base}/rest/v1/sh_instances?select=sh_id,account_id,sh_type,is_primary,status&account_id=eq.${encodeURIComponent(accountId)}`,
  { headers: authHeaders },
);

if (!shResponse.ok) {
  throw new Error(`SH_LOOKUP_FAILED ${shResponse.status}: ${await shResponse.text()}`);
}

const shRows = await shResponse.json();
if (!shRows.length || shRows.some((row) => row.account_id !== accountId)) {
  throw new Error(`SH_SCOPE_ASSERTION_FAILED: ${JSON.stringify(shRows)}`);
}

const signOut = await fetch(`${base}/auth/v1/logout`, {
  method: 'POST',
  headers: authHeaders,
});

if (!signOut.ok) {
  throw new Error(`AUTH_SIGN_OUT_FAILED ${signOut.status}: ${await signOut.text()}`);
}

console.log(JSON.stringify({
  status: 'PASS',
  checks: [
    'password sign-in returns authenticated user/session',
    'auth user resolves to exactly one account_auth_link',
    'authenticated query resolves only account-scoped SH rows',
    'logout endpoint succeeds',
  ],
  account_id: accountId,
  sh_count: shRows.length,
}, null, 2));
