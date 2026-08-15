import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import {
  approveCloneAgreement,
  createCloneAgreement,
  executeClone,
  listCloneAgreements,
  rejectCloneAgreement,
  type CloneAgreement,
} from '../features/clone/clone-service';

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

export default function CloneScreen() {
  const { session, context } = useAuth();
  const [agreements, setAgreements] = useState<CloneAgreement[]>([]);
  const [sourceShId, setSourceShId] = useState('');
  const [sourceAccountId, setSourceAccountId] = useState('');
  const [targetAccountId, setTargetAccountId] = useState(context?.account.account_id ?? '');
  const [cloneName, setCloneName] = useState('');
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const currentAccountId = context?.account.account_id ?? '';

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setAgreements(await listCloneAgreements());
    } catch (err) {
      setError(describeError(err, 'Unable to load clone agreements'));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (context) void refresh();
  }, [context, refresh]);

  const incoming = useMemo(
    () => agreements.filter((item) => item.target_account_id === currentAccountId),
    [agreements, currentAccountId],
  );
  const outgoing = useMemo(
    () => agreements.filter((item) => item.source_account_id === currentAccountId),
    [agreements, currentAccountId],
  );

  if (!session) return <Redirect href="/login" />;
  if (!context) return <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}><ActivityIndicator /></View>;

  async function requestClone() {
    setBusyId('create');
    setError(null);
    setNotice(null);
    try {
      const agreement = await createCloneAgreement({
        sourceShId,
        sourceAccountId,
        targetAccountId: currentAccountId,
      });
      setSourceShId('');
      setSourceAccountId('');
      setNotice(`Clone agreement created: ${agreement.agreement_id}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to create clone agreement'));
    } finally {
      setBusyId(null);
    }
  }

  async function approve(agreementId: string) {
    setBusyId(agreementId);
    setError(null);
    try {
      await approveCloneAgreement(agreementId);
      setNotice(`Agreement approved: ${agreementId}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to approve agreement'));
    } finally {
      setBusyId(null);
    }
  }

  async function reject(agreementId: string) {
    setBusyId(agreementId);
    setError(null);
    try {
      await rejectCloneAgreement(agreementId);
      setNotice(`Agreement rejected: ${agreementId}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to reject agreement'));
    } finally {
      setBusyId(null);
    }
  }

  async function execute(agreementId: string) {
    setBusyId(agreementId);
    setError(null);
    try {
      const cloneShId = await executeClone(agreementId, cloneName);
      setCloneName('');
      setNotice(`Clone created: ${cloneShId}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to execute clone'));
    } finally {
      setBusyId(null);
    }
  }

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Clone</Text>
      <Text>Current account: {currentAccountId}</Text>
      <Text>Create a clone agreement as the target account. The source account must approve it before execution.</Text>

      <TextInput placeholder="Source SH ID" value={sourceShId} onChangeText={setSourceShId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <TextInput placeholder="Source account ID" value={sourceAccountId} onChangeText={setSourceAccountId} autoCapitalize="none" style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
      <Button title={busyId === 'create' ? 'Creating…' : 'Request clone'} onPress={() => void requestClone()} disabled={busyId !== null || !sourceShId || !sourceAccountId} />

      {loading ? <ActivityIndicator /> : null}
      {notice ? <Text>{notice}</Text> : null}
      {error ? <Text>{error}</Text> : null}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Incoming agreements</Text>
      {incoming.length === 0 ? <Text>No incoming clone agreements.</Text> : incoming.map((agreement) => (
        <View key={agreement.agreement_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>Agreement: {agreement.agreement_id}</Text>
          <Text>Source SH: {agreement.source_sh_id}</Text>
          <Text>Status: {agreement.status}</Text>
          {agreement.status === 'PENDING' ? (
            <View style={{ gap: 8 }}>
              <Button title={busyId === agreement.agreement_id ? 'Working…' : 'Approve'} onPress={() => void approve(agreement.agreement_id)} disabled={busyId !== null} />
              <Button title="Reject" onPress={() => void reject(agreement.agreement_id)} disabled={busyId !== null} />
            </View>
          ) : null}
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Outgoing agreements</Text>
      {outgoing.length === 0 ? <Text>No outgoing clone agreements.</Text> : outgoing.map((agreement) => (
        <View key={agreement.agreement_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>Agreement: {agreement.agreement_id}</Text>
          <Text>Target account: {agreement.target_account_id}</Text>
          <Text>Status: {agreement.status}</Text>
          {agreement.status === 'APPROVED' ? (
            <View style={{ gap: 8 }}>
              <TextInput placeholder="Optional clone name" value={cloneName} onChangeText={setCloneName} style={{ borderWidth: 1, padding: 12, borderRadius: 8 }} />
              <Button title={busyId === agreement.agreement_id ? 'Creating…' : 'Create clone'} onPress={() => void execute(agreement.agreement_id)} disabled={busyId !== null} />
            </View>
          ) : null}
        </View>
      ))}

      <Button title="Refresh" onPress={() => void refresh()} disabled={busyId !== null} />
    </ScrollView>
  );
}
