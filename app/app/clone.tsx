import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, Text, TextInput, View } from 'react-native';
import { Redirect } from 'expo-router';
import { useAuth } from '../state/auth-context';
import {
  approveCloneAgreement,
  createCloneAgreement,
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
  const [recipientEmail, setRecipientEmail] = useState('');
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
        sourceAccountId: currentAccountId,
        targetEmail: recipientEmail,
      });
      setSourceShId('');
      setRecipientEmail('');
      setNotice(`Clone invitation created: ${agreement.agreement_id}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to create clone invitation'));
    } finally {
      setBusyId(null);
    }
  }

  async function approve(agreementId: string) {
    setBusyId(agreementId);
    setError(null);
    try {
      await approveCloneAgreement(agreementId);
      setNotice(`Clone invitation approved: ${agreementId}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to approve clone invitation'));
    } finally {
      setBusyId(null);
    }
  }

  async function reject(agreementId: string) {
    setBusyId(agreementId);
    setError(null);
    try {
      await rejectCloneAgreement(agreementId);
      setNotice(`Clone invitation rejected: ${agreementId}`);
      await refresh();
    } catch (err) {
      setError(describeError(err, 'Unable to reject clone invitation'));
    } finally {
      setBusyId(null);
    }
  }

  return (
    <ScrollView contentContainerStyle={{ padding: 24, gap: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: '700' }}>Clone</Text>
      <Text>Current source account: {currentAccountId}</Text>
      <Text>Create a Clone invitation for a new recipient email. The recipient does not need an Account or SH yet.</Text>

      <Text style={{ fontWeight: '600' }}>Source SH ID</Text>
      <TextInput
        placeholder="Enter the SH ID owned by this account"
        value={sourceShId}
        onChangeText={setSourceShId}
        autoCapitalize="none"
        style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}
      />

      <Text style={{ fontWeight: '600' }}>Recipient email</Text>
      <TextInput
        placeholder="Enter the intended recipient email"
        value={recipientEmail}
        onChangeText={setRecipientEmail}
        autoCapitalize="none"
        autoCorrect={false}
        keyboardType="email-address"
        style={{ borderWidth: 1, padding: 12, borderRadius: 8 }}
      />

      <Text style={{ fontSize: 12 }}>
        After approval, the recipient registers with this email. Registration materializes the Clone as the recipient's PRIMARY SH.
      </Text>

      <Button
        title={busyId === 'create' ? 'Creating…' : 'Create Clone invitation'}
        onPress={() => void requestClone()}
        disabled={busyId !== null || !sourceShId.trim() || !recipientEmail.trim()}
      />

      {loading ? <ActivityIndicator /> : null}
      {notice ? <Text>{notice}</Text> : null}
      {error ? <Text>{error}</Text> : null}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Incoming Clone invitations</Text>
      {incoming.length === 0 ? <Text>No incoming Clone invitations.</Text> : incoming.map((agreement) => (
        <View key={agreement.agreement_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>Agreement: {agreement.agreement_id}</Text>
          <Text>Source SH: {agreement.source_sh_id}</Text>
          <Text>Source account: {agreement.source_account_id}</Text>
          <Text>Recipient email: {agreement.target_email}</Text>
          <Text>Status: {agreement.status}</Text>
          <Text>After registration, this Clone becomes the recipient's PRIMARY SH.</Text>
        </View>
      ))}

      <Text style={{ fontSize: 20, fontWeight: '700' }}>Outgoing Clone invitations</Text>
      {outgoing.length === 0 ? <Text>No outgoing Clone invitations.</Text> : outgoing.map((agreement) => (
        <View key={agreement.agreement_id} style={{ borderWidth: 1, padding: 12, borderRadius: 8, gap: 8 }}>
          <Text>Agreement: {agreement.agreement_id}</Text>
          <Text>Recipient email: {agreement.target_email}</Text>
          <Text>Target account: {agreement.target_account_id ?? 'Not registered yet'}</Text>
          <Text>Status: {agreement.status}</Text>
          {agreement.status === 'PENDING' ? (
            <View style={{ gap: 8 }}>
              <Button title={busyId === agreement.agreement_id ? 'Working…' : 'Approve'} onPress={() => void approve(agreement.agreement_id)} disabled={busyId !== null} />
              <Button title="Reject" onPress={() => void reject(agreement.agreement_id)} disabled={busyId !== null} />
            </View>
          ) : null}
          {agreement.status === 'APPROVED' && !agreement.target_account_id ? (
            <Text>Approved. Waiting for the recipient to register with the intended email.</Text>
          ) : null}
          {agreement.target_account_id ? <Text>Recipient registered and Clone materialization is linked to this Account.</Text> : null}
        </View>
      ))}

      <Button title="Refresh" onPress={() => void refresh()} disabled={busyId !== null} />
    </ScrollView>
  );
}
