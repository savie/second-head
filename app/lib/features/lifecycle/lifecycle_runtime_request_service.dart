import '../../core/backend/backend_client.dart';
import '../../core/state/sh_profile_state.dart';

/// Canonical request bridge for lifecycle authorization records.
///
/// Request creation is intentionally performed against the canonical tables
/// protected by RLS. Execution remains behind runtime SECURITY DEFINER RPCs.
class LifecycleRuntimeRequestService {
  const LifecycleRuntimeRequestService();

  Future<Map<String, dynamic>> createCloneAgreement({
    required String targetEmail,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final sourceAccountId = _required(profileAccountId.value, 'account');
    final sourceShId = _required(profileShId.value, 'SH');
    final email = targetEmail.trim();
    if (email.isEmpty) throw StateError('Target email is required.');

    final row = await backendClient
        .from('clone_agreements')
        .insert({
          'source_sh_id': sourceShId,
          'source_account_id': sourceAccountId,
          'target_email': email,
          'scope': scope,
        })
        .select('agreement_id,source_sh_id,source_account_id,target_account_id,status,scope,created_at,target_email')
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>> createInheritanceAuthorization({
    required String targetShId,
    required String targetAccountId,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final sourceAccountId = _required(profileAccountId.value, 'account');
    final sourceShId = _required(profileShId.value, 'SH');

    final row = await backendClient.rpc(
      'runtime_create_inheritance_authorization',
      params: {
        'p_source_sh_id': sourceShId,
        'p_target_sh_id': _required(targetShId, 'target SH'),
        'p_source_account_id': sourceAccountId,
        'p_target_account_id': _required(targetAccountId, 'target account'),
        'p_scope': scope,
      },
    );
    return _singleMap(row);
  }

  Future<Map<String, dynamic>> createSuccessionRule({
    required String successorAccountId,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final sourceShId = _required(profileShId.value, 'SH');
    final successor = _required(successorAccountId, 'successor account');

    final row = await backendClient
        .from('succession_rules')
        .insert({
          'source_sh_id': sourceShId,
          'successor_account_id': successor,
          'scope': scope,
        })
        .select('succession_id,source_sh_id,successor_account_id,status,scope,created_at,revoked_at')
        .single();
    return Map<String, dynamic>.from(row);
  }

  String _required(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw StateError('Active $label identity is unavailable.');
    return normalized;
  }

  Map<String, dynamic> _singleMap(dynamic row) {
    if (row is Map) return Map<String, dynamic>.from(row);
    throw StateError('Runtime returned an unexpected response.');
  }
}
