import '../../core/backend/backend_client.dart';

/// Read-only bridge for lifecycle authority records.
///
/// RLS remains the server-side visibility boundary. This service deliberately
/// does not mutate lifecycle authorization tables directly; approvals and
/// execution remain runtime-authority operations.
class LifecycleRuntimeReadService {
  const LifecycleRuntimeReadService();

  Future<List<Map<String, dynamic>>> listCloneAgreements() async {
    final rows = await backendClient
        .from('clone_agreements')
        .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at,target_email')
        .order('created_at', ascending: false);
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> listInheritanceAuthorizations() async {
    final rows = await backendClient
        .from('inheritance_authorizations')
        .select('authorization_id,source_sh_id,target_sh_id,source_account_id,target_account_id,status,scope,created_at,approved_at,revoked_at')
        .order('created_at', ascending: false);
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> listSuccessionRules() async {
    final rows = await backendClient
        .from('succession_rules')
        .select('succession_id,source_sh_id,successor_account_id,status,scope,created_at,revoked_at')
        .order('created_at', ascending: false);
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> listLegacyRecords() async {
    final rows = await backendClient
        .from('legacy_records')
        .select('legacy_id,source_sh_id,legacy_type,payload,provenance,status,retention_until,created_at')
        .order('created_at', ascending: false);
    return _maps(rows);
  }

  Future<List<Map<String, dynamic>>> listRecoverySnapshots() async {
    final rows = await backendClient
        .from('recovery_snapshots')
        .select('snapshot_id,sh_id,account_id,snapshot_kind,manifest,created_at')
        .order('created_at', ascending: false);
    return _maps(rows);
  }

  List<Map<String, dynamic>> _maps(dynamic rows) {
    if (rows is! List) return const <Map<String, dynamic>>[];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
