import { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import {
  approveInheritance,
  createInheritanceAuthorization,
  createSuccessionRule,
  executeSuccession,
  listInheritanceAuthorizations,
  listLegacyRecords,
  listSuccessionRules,
  recordInheritance,
  recordLegacy,
  type InheritanceAuthorization,
  type LegacyRecord,
  type SuccessionRule,
} from '../features/inheritance/inheritance-service';

function describeError(err: unknown, fallback: string) {
  if (err instanceof Error) return err.message;
  if (typeof err === 'object' && err !== null) {
    const candidate = err as { message?: unknown; code?: unknown; details?: unknown; hint?: unknown };
    const parts = [candidate.message, candidate.code, candidate.details, candidate.hint]
      .filter((value): value is string => typeof value === 'string' && value.length > 0);
    if (parts.length > 0) return parts.join(' | ');
  }
  return fallback;
}

export default function InheritanceScreen() {
  const { session, context } = useAuth();
  const [succession, setSuccession] = useState<SuccessionRule[]>([]);
  const [authorizations, setAuthorizations] = useState<InheritanceAuthorization[]>([]);
  const [legacy, setLegacy] = useState<LegacyRecord[]>([]);
  const [successionSourceShId, setSuccessionSourceShId] = useState(context?.shInstances[0]?.sh_id ?? '');
  const [inheritanceSourceShId, setInheritanceSourceShId] = useState('');
  const [legacySourceShId, setLegacySourceShId] = useState('');
  const [successorAccountId, setSuccessorAccountId] = useState('');
  const [targetShId, setTargetShId] = useState('');
  const [sourceAccountId, setSourceAccountId] = useState('');
  const [targetAccountId, setTargetAccountId] = useState(context?.account.account_id ?? '');
  const [legacyType, setLegacyType] = useState<LegacyRecord['legacy_type']>('HISTORY');
  const [scopeJson, setScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[]}');
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const currentAccountId = context?.account.account_id ?? '';

  const refresh = useCallback(async () => {
    setLoading(true); setError(null);
    try {
      const [s, a, l] = await Promise.all([listSuccessionRules(), listInheritanceAuthorizations(), listLegacyRecords()]);
      setSuccession(s); setAuthorizations(a); setLegacy(l);
    } catch (err) { setError(describeError(err, 'Unable to load P5C data')); }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { if (context) void refresh(); }, [context, refresh]);

  if (!session) return <Redirect href="/login" />;
  if (!context) return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;

  async function run(action: () => Promise<string | object>, message: (value: string | object) => string) {
    setBusy(true); setError(null); setNotice(null);
    try { const result = await action(); setNotice(message(result)); await refresh(); }
    catch (err) { setError(describeError(err, 'P5C operation failed')); }
    finally { setBusy(false); }
  }

  function parseScope() {
    const parsed = JSON.parse(scopeJson) as Record<string, unknown>;
    return parsed;
  }

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Inheritance / Legacy / Succession</Text>
      <Text>Current account: {currentAccountId}</Text>
      <Text>P5C preserves the boundary: inheritance is not identity transfer, succession does not automatically grant private data, and legacy is not full private state.</Text>

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Succession rule</Text>
      <Text style={{ fontWeight: '600' }}>Source SH ID</Text>
      <TextInput placeholder="Enter the SH ID owned by the source account" value={successionSourceShId} onChangeText={setSuccessionSourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Successor Account ID</Text>
      <TextInput placeholder="Enter the account ID that will become the successor" value={successorAccountId} onChangeText={setSuccessorAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Selected transfer scope JSON</Text>
      <TextInput multiline value={scopeJson} onChangeText={setScopeJson} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8, minHeight: 80 }} />
      <Button title="Create succession rule" disabled={busy || !successionSourceShId || !successorAccountId} onPress={() => void run(() => createSuccessionRule({ sourceShId: successionSourceShId, successorAccountId, scope: parseScope() }), (v) => `Succession created: ${String((v as SuccessionRule).succession_id)}`)} />

      {loading ? <ActivityIndicator /> : null}
      {notice ? <Text>{notice}</Text> : null}
      {error ? <Text>{error}</Text> : null}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Succession rules</Text>
      {succession.length === 0 ? <Text>No succession rules.</Text> : succession.map((item) => (
        <View key={item.succession_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>ID: {item.succession_id}</Text><Text>Status: {item.status}</Text><Text>Source SH: {item.source_sh_id}</Text><Text>Successor account: {item.successor_account_id}</Text><Text>Scope: {JSON.stringify(item.scope)}</Text>
          {item.status === 'ACTIVE' && item.successor_account_id === currentAccountId ? <Button title="Execute selected succession" disabled={busy} onPress={() => void run(() => executeSuccession(item.succession_id), (v) => `Succession executed: ${String(v)}`)} /> : null}
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Inheritance authorization</Text>
      <Text style={{ fontWeight: '600' }}>Source SH ID</Text>
      <TextInput placeholder="Enter the SH ID that grants inheritance authorization" value={inheritanceSourceShId} onChangeText={setInheritanceSourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Target SH ID</Text>
      <TextInput placeholder="Enter the SH ID that receives the authorized inheritance" value={targetShId} onChangeText={setTargetShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Source Account ID</Text>
      <TextInput placeholder="Enter the account ID that owns the source SH" value={sourceAccountId} onChangeText={setSourceAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Target Account ID</Text>
      <TextInput placeholder="Enter the account ID that owns the target SH" value={targetAccountId} onChangeText={setTargetAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Button title="Create authorization" disabled={busy || !inheritanceSourceShId || !targetShId || !sourceAccountId || !targetAccountId} onPress={() => void run(() => createInheritanceAuthorization({ sourceShId: inheritanceSourceShId, targetShId, sourceAccountId, targetAccountId }), (v) => `Authorization created: ${String((v as InheritanceAuthorization).authorization_id)}`)} />

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Authorizations</Text>
      {authorizations.length === 0 ? <Text>No inheritance authorizations.</Text> : authorizations.map((item) => (
        <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>ID: {item.authorization_id}</Text><Text>Status: {item.status}</Text><Text>Source SH: {item.source_sh_id}</Text><Text>Target SH: {item.target_sh_id}</Text>
          {item.status === 'PENDING' && item.source_account_id === currentAccountId ? <Button title="Approve" disabled={busy} onPress={() => void run(() => approveInheritance(item.authorization_id), () => 'Inheritance approved')} /> : null}
          {item.status === 'APPROVED' && item.source_account_id === currentAccountId ? <Button title="Record inheritance" disabled={busy} onPress={() => void run(() => recordInheritance(item.authorization_id), (v) => `Inheritance recorded: ${String(v)}`)} /> : null}
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Legacy</Text>
      <Text style={{ fontWeight: '600' }}>Source SH ID</Text>
      <TextInput placeholder="Enter the SH ID whose legacy record is being recorded" value={legacySourceShId} onChangeText={setLegacySourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Text style={{ fontWeight: '600' }}>Legacy Type</Text>
      <TextInput placeholder="MEMORY / KNOWLEDGE / EXPERIENCE / JOURNEY / HISTORY / VALUE / REFERENCE" value={legacyType} onChangeText={(v) => setLegacyType(v.toUpperCase() as LegacyRecord['legacy_type'])} autoCapitalize="characters" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Button title="Record legacy" disabled={busy || !legacySourceShId || !legacyType} onPress={() => void run(() => recordLegacy({ sourceShId: legacySourceShId, legacyType }), (v) => `Legacy recorded: ${String(v)}`)} />
      {legacy.slice(0, 10).map((item) => <View key={item.legacy_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}><Text>{item.legacy_id}</Text><Text>{item.legacy_type} · {item.status}</Text></View>)}

      <Button title="Refresh" disabled={busy} onPress={() => void refresh()} />
    </ScrollView>
  );
}
