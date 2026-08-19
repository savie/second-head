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
  preserveSelectedTransferAsLegacy,
  recordInheritance,
  recordLegacy,
  type InheritanceAuthorization,
  type LegacyRecord,
  type SuccessionRule,
  type TransferSelection,
} from '../features/inheritance/inheritance-service';

function describeError(err: unknown, fallback: string) {
  if (err instanceof Error) return err.message;
  if (typeof err === 'object' && err !== null) {
    const candidate = err as { message?: unknown; code?: unknown; details?: unknown; hint?: unknown };
    const parts = [candidate.message, candidate.code, candidate.details, candidate.hint].filter((v): v is string => typeof v === 'string' && v.length > 0);
    if (parts.length) return parts.join(' | ');
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
  const [scopeJson, setScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[],"experience_ids":[],"journey_event_ids":[]}');
  const [legacyScopeJson, setLegacyScopeJson] = useState('{"memory_ids":[],"knowledge_ids":[],"experience_ids":[],"journey_event_ids":[]}');
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

  function parseScope(value: string): TransferSelection {
    const parsed = JSON.parse(value) as TransferSelection;
    return parsed;
  }

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Inheritance / Legacy / Succession</Text>
      <Text>Current account: {currentAccountId}</Text>
      <Text>Transfers are explicit selections. Private/non-transferable Journey events are rejected by the backend; Reference / Value / History source-domain IDs are not silently approximated.</Text>

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Succession rule</Text>
      <TextInput placeholder="Source SH ID" value={successionSourceShId} onChangeText={setSuccessionSourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Successor Account ID" value={successorAccountId} onChangeText={setSuccessorAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput multiline value={scopeJson} onChangeText={setScopeJson} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8, minHeight: 90 }} />
      <Button title="Create succession rule" disabled={busy || !successionSourceShId || !successorAccountId} onPress={() => void run(() => createSuccessionRule({ sourceShId: successionSourceShId, successorAccountId, scope: parseScope(scopeJson) }), v => `Succession created: ${String((v as SuccessionRule).succession_id)}`)} />

      {loading ? <ActivityIndicator /> : null}{notice ? <Text>{notice}</Text> : null}{error ? <Text>{error}</Text> : null}
      {succession.map(item => <View key={item.succession_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}><Text>ID: {item.succession_id}</Text><Text>Status: {item.status}</Text><Text>Scope: {JSON.stringify(item.scope)}</Text>{item.status === 'ACTIVE' && item.successor_account_id === currentAccountId ? <Button title="Execute selected succession" disabled={busy} onPress={() => void run(() => executeSuccession(item.succession_id), v => `Succession executed: ${String(v)}`)} /> : null}</View>)}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Inheritance authorization</Text>
      <TextInput placeholder="Source SH ID" value={inheritanceSourceShId} onChangeText={setInheritanceSourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Target SH ID" value={targetShId} onChangeText={setTargetShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Source Account ID" value={sourceAccountId} onChangeText={setSourceAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Target Account ID" value={targetAccountId} onChangeText={setTargetAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput multiline value={scopeJson} onChangeText={setScopeJson} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8, minHeight: 90 }} />
      <Button title="Create authorization with selected scope" disabled={busy || !inheritanceSourceShId || !targetShId || !sourceAccountId || !targetAccountId} onPress={() => void run(() => createInheritanceAuthorization({ sourceShId: inheritanceSourceShId, targetShId, sourceAccountId, targetAccountId, scope: parseScope(scopeJson) }), v => `Authorization created: ${String((v as InheritanceAuthorization).authorization_id)}`)} />
      {authorizations.map(item => <View key={item.authorization_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}><Text>ID: {item.authorization_id}</Text><Text>Status: {item.status}</Text><Text>Scope: {JSON.stringify(item.scope)}</Text>{item.status === 'PENDING' && item.source_account_id === currentAccountId ? <Button title="Approve" disabled={busy} onPress={() => void run(() => approveInheritance(item.authorization_id), () => 'Inheritance approved')} /> : null}{item.status === 'APPROVED' && item.source_account_id === currentAccountId ? <Button title="Execute selected inheritance" disabled={busy} onPress={() => void run(() => recordInheritance(item.authorization_id), v => `Inheritance executed: ${String(v)}`)} /> : null}</View>)}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Legacy</Text>
      <TextInput placeholder="Source SH ID" value={legacySourceShId} onChangeText={setLegacySourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Legacy Type (for historical record path)" value={legacyType} onChangeText={v => setLegacyType(v.toUpperCase() as LegacyRecord['legacy_type'])} autoCapitalize="characters" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput multiline value={legacyScopeJson} onChangeText={setLegacyScopeJson} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8, minHeight: 90 }} />
      <Button title="Preserve selected transfer as legacy" disabled={busy || !legacySourceShId} onPress={() => void run(() => preserveSelectedTransferAsLegacy({ sourceShId: legacySourceShId, scope: parseScope(legacyScopeJson) }), v => `Selected legacy preserved: ${String(v)}`)} />
      <Button title="Record legacy type" disabled={busy || !legacySourceShId || !legacyType} onPress={() => void run(() => recordLegacy({ sourceShId: legacySourceShId, legacyType }), v => `Legacy recorded: ${String(v)}`)} />
      {legacy.slice(0, 10).map(item => <View key={item.legacy_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}><Text>{item.legacy_id}</Text><Text>{item.legacy_type} · {item.status}</Text></View>)}
      <Button title="Refresh" disabled={busy} onPress={() => void refresh()} />
    </ScrollView>
  );
}
