import '../../core/backend/backend_client.dart';
import '../../core/state/sh_profile_state.dart';

/// Canonical request bridge for lifecycle authorization records.
///
/// The user-facing contract is email-based. Account/SH UUID resolution stays
/// inside the trusted runtime boundary and is never required from the UI.
class LifecycleRuntimeRequestService {
  const LifecycleRuntimeRequestService();

  Future<Map<String, dynamic>> createCloneAgreement({
    required String targetEmail,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final sourceAccountId = _required(profileAccountId.value, 'account');
    final sourceShId = _required(profileShId.value, 'SH');
    final email = _requiredEmail(targetEmail);

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
    required String targetEmail,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final email = _requiredEmail(targetEmail);
    final row = await backendClient.rpc(
      'runtime_create_inheritance_authorization_by_email',
      params: {
        'p_target_email': email,
        'p_scope': scope,
      },
    );
    return _singleMap(row);
  }

  Future<Map<String, dynamic>> createSuccessionRule({
    required String targetEmail,
    Map<String, dynamic> scope = const <String, dynamic>{},
  }) async {
    final email = _requiredEmail(targetEmail);
    final row = await backendClient.rpc(
      'runtime_create_succession_rule_by_email',
      params: {
        'p_target_email': email,
        'p_scope': scope,
      },
    );
    return _singleMap(row);
  }

  String _requiredEmail(String value) {
    final email = value.trim();
    if (email.isEmpty || !email.contains('@')) {
      throw const FormatException('Enter a valid target email.');
    }
    return email;
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
