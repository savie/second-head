import '../../core/backend/backend_client.dart';

/// FE integration boundary for Journey and semantic lifecycle mutations.
///
/// This class is intentionally a thin adapter over existing Supabase runtime
/// RPCs. It does not implement business authority locally; the backend remains
/// the canonical mutation authority.
class JourneyRuntimeService {
  const JourneyRuntimeService();

  Future<String> createMemory({
    required String shId,
    required String content,
    String memoryType = 'LONG_TERM',
    String source = 'journey-ui',
    double confidence = 1,
    String scope = 'PRIVATE',
    String visibility = 'OWNER_ONLY',
    String lifecycle = 'CANDIDATE',
  }) async {
    final result = await backendClient.rpc('runtime_record_memory_with_journey', params: {
      'p_sh_id': shId, 'p_content': content, 'p_memory_type': memoryType,
      'p_source': source, 'p_confidence': confidence, 'p_scope': scope,
      'p_visibility': visibility, 'p_lifecycle': lifecycle,
    });
    return _uuid(result, 'Memory creation');
  }

  Future<String> replaceMemory({
    required String shId,
    required String newContent,
    required String oldPattern,
    String source = 'journey-ui',
    String scope = 'PRIVATE',
    String visibility = 'OWNER_ONLY',
  }) async {
    final result = await backendClient.rpc('runtime_replace_memory', params: {
      'p_sh_id': shId, 'p_new_content': newContent, 'p_old_pattern': oldPattern,
      'p_source': source, 'p_scope': scope, 'p_visibility': visibility,
    });
    return _uuid(result, 'Memory replacement');
  }

  Future<String> createKnowledgeCandidate({
    required String shId,
    required String content,
    String source = 'journey-ui',
    String origin = 'EXPLICIT_TEACHING',
    Map<String, dynamic> provenance = const {},
    String scope = 'PRIVATE',
    String visibility = 'OWNER_ONLY',
    double confidence = 1,
  }) async {
    final result = await backendClient.rpc('runtime_record_knowledge_with_journey', params: {
      'p_sh_id': shId, 'p_content': content, 'p_source': source, 'p_origin': origin,
      'p_provenance': provenance, 'p_scope': scope, 'p_visibility': visibility,
      'p_confidence': confidence,
    });
    return _uuid(result, 'Knowledge creation');
  }

  Future<String> createExperience({
    required String shId,
    required String content,
    String experienceType = 'EXPLICIT_USER_REQUEST',
    String scope = 'PRIVATE',
    String visibility = 'OWNER_ONLY',
    String transferPolicy = 'NON_TRANSFERABLE',
    String sourceRef = 'journey-ui',
    Map<String, dynamic> provenance = const {'capture_mode': 'JOURNEY_UI'},
    DateTime? occurredAt,
  }) async {
    final result = await backendClient.rpc('runtime_record_experience_with_journey', params: {
      'p_sh_id': shId,
      'p_experience_type': experienceType,
      'p_content': content,
      'p_scope': scope,
      'p_visibility': visibility,
      'p_transfer_policy': transferPolicy,
      'p_source_ref': sourceRef,
      'p_provenance': provenance,
      'p_occurred_at': (occurredAt ?? DateTime.now()).toUtc().toIso8601String(),
    });
    return _uuid(result, 'Experience creation');
  }

  Future<Map<String, dynamic>> acceptKnowledge({required String knowledgeId, String expectedLifecycle = 'CANDIDATE', required String operationKey, required String decisionRef, required String validationRef, Map<String, dynamic> provenance = const {}}) => _jsonRpc('runtime_accept_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_decision_ref': decisionRef, 'p_validation_ref': validationRef, 'p_provenance': provenance});
  Future<Map<String, dynamic>> indexKnowledge({required String knowledgeId, String expectedLifecycle = 'ACCEPTED', required String operationKey, required String indexRef, Map<String, dynamic> provenance = const {}}) => _jsonRpc('runtime_index_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_index_ref': indexRef, 'p_provenance': provenance});
  Future<Map<String, dynamic>> activateKnowledge({required String knowledgeId, String expectedLifecycle = 'INDEXED', required String operationKey, required String decisionRef, required String confirmationRef, Map<String, dynamic> provenance = const {}}) => _jsonRpc('runtime_activate_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_decision_ref': decisionRef, 'p_confirmation_ref': confirmationRef, 'p_provenance': provenance});
  Future<Map<String, dynamic>> updateKnowledge({required String knowledgeId, required String expectedLifecycle, required String operationKey, required String updateRef, required String successorContent, Map<String, dynamic> provenance = const {}, Map<String, dynamic> successorProvenance = const {}}) => _jsonRpc('runtime_update_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_update_ref': updateRef, 'p_provenance': provenance, 'p_successor_content': successorContent, 'p_successor_provenance': successorProvenance});
  Future<Map<String, dynamic>> deprecateKnowledge({required String knowledgeId, String expectedLifecycle = 'ACTIVE', required String operationKey, required String decisionRef, required String confirmationRef, Map<String, dynamic> provenance = const {}}) => _jsonRpc('runtime_deprecate_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_decision_ref': decisionRef, 'p_confirmation_ref': confirmationRef, 'p_provenance': provenance});
  Future<Map<String, dynamic>> archiveKnowledge({required String knowledgeId, String expectedLifecycle = 'DEPRECATED', required String operationKey, required String decisionRef, required String confirmationRef, Map<String, dynamic> provenance = const {}}) => _jsonRpc('runtime_archive_knowledge', {'p_knowledge_id': knowledgeId, 'p_expected_lifecycle': expectedLifecycle, 'p_operation_key': operationKey, 'p_decision_ref': decisionRef, 'p_confirmation_ref': confirmationRef, 'p_provenance': provenance});

  Future<void> deleteRecordWithJourney({required String domain, required String recordId}) async => backendClient.rpc('runtime_delete_record_with_journey', params: {'p_domain': domain, 'p_record_id': recordId});
  Future<void> classifyJourneyEvent({required String eventId, required String visibility, required String transferPolicy, Map<String, dynamic> provenance = const {}}) async => backendClient.rpc('runtime_classify_journey_event', params: {'p_event_id': eventId, 'p_visibility': visibility, 'p_transfer_policy': transferPolicy, 'p_provenance': provenance});
  Future<String> createRecoverySnapshot({required String shId}) async => _uuid(await backendClient.rpc('runtime_create_recovery_snapshot', params: {'p_sh_id': shId}), 'Recovery snapshot creation');
  Future<String> restoreRecoverySnapshot({required String snapshotId}) async => _uuid(await backendClient.rpc('runtime_restore_recovery_snapshot', params: {'p_snapshot_id': snapshotId}), 'Recovery restore');
  Future<String> materializeRegisteredClone() async => _uuid(await backendClient.rpc('runtime_materialize_registered_clone'), 'Clone materialization');
  Future<String> createClone({required String agreementId, required String cloneName}) async => _uuid(await backendClient.rpc('runtime_create_clone', params: {'p_agreement_id': agreementId, 'p_clone_name': cloneName}), 'Clone creation');
  Future<String> recordInheritance({required String authorizationId, Map<String, dynamic> payload = const {}, Map<String, dynamic> provenance = const {}}) async => _uuid(await backendClient.rpc('runtime_record_inheritance', params: {'p_authorization_id': authorizationId, 'p_payload': payload, 'p_provenance': provenance}), 'Inheritance recording');
  Future<String> executeSuccession({required String successionId}) async => _uuid(await backendClient.rpc('runtime_execute_succession', params: {'p_succession_id': successionId}), 'Succession execution');

  Future<String> preserveSelectedTransferAsLegacy({
    required String sourceShId,
    required Map<String, dynamic> scope,
  }) async => _uuid(
        await backendClient.rpc(
          'runtime_preserve_selected_transfer_as_legacy',
          params: {'p_source_sh_id': sourceShId, 'p_scope': scope},
        ),
        'Selected legacy preservation',
      );

  Future<String> recordLegacy({required String sourceShId, required String legacyType, Map<String, dynamic> payload = const {}, Map<String, dynamic> provenance = const {}, DateTime? retentionUntil}) async => _uuid(await backendClient.rpc('runtime_record_legacy', params: {'p_source_sh_id': sourceShId, 'p_legacy_type': legacyType, 'p_payload': payload, 'p_provenance': provenance, 'p_retention_until': retentionUntil?.toUtc().toIso8601String()}), 'Legacy recording');
  Future<String> endOfLife({required String shId, String? reason}) async => _uuid(await backendClient.rpc('runtime_end_of_life_sh', params: {'p_sh_id': shId, 'p_reason': reason}), 'End-of-life operation');
  Future<String> createInheritanceAuthorization({required String sourceShId, required String targetShId, required String sourceAccountId, required String targetAccountId, Map<String, dynamic> scope = const {}}) async { final result = await backendClient.rpc('runtime_create_inheritance_authorization', params: {'p_source_sh_id': sourceShId, 'p_target_sh_id': targetShId, 'p_source_account_id': sourceAccountId, 'p_target_account_id': targetAccountId, 'p_scope': scope}); if (result is List && result.isNotEmpty && result.first is Map) return _uuid((result.first as Map)['authorization_id'], 'Inheritance authorization creation'); if (result is Map) return _uuid(result['authorization_id'], 'Inheritance authorization creation'); return _uuid(result, 'Inheritance authorization creation'); }
  Future<String> createKnowledgeLifecycleConfirmation({required String knowledgeId, required String transition, required String operationKey, required String decisionRef, Map<String, dynamic> provenance = const {}}) async => _uuid(await backendClient.rpc('runtime_create_knowledge_lifecycle_confirmation', params: {'p_knowledge_id': knowledgeId, 'p_transition': transition, 'p_operation_key': operationKey, 'p_decision_ref': decisionRef, 'p_provenance': provenance}), 'Knowledge lifecycle confirmation creation');
  Future<String> confirmKnowledgeLifecycle({required String confirmationId}) async => _uuid(await backendClient.rpc('runtime_confirm_knowledge_lifecycle', params: {'p_confirmation_id': confirmationId}), 'Knowledge lifecycle confirmation');

  Future<Map<String, dynamic>> _jsonRpc(String function, Map<String, dynamic> params) async {
    final result = await backendClient.rpc(function, params: params);
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    throw StateError('$function returned a non-object result.');
  }

  String _uuid(dynamic result, String operation) {
    final value = result?.toString().trim() ?? '';
    if (value.isEmpty) throw StateError('$operation returned no identifier.');
    return value;
  }
}
