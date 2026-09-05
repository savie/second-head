import '../../core/backend/backend_client.dart';
import '../auth/auth_screens.dart';

/// Backend adapter for the Conversation runtime contract.
///
/// The backend is the source of truth for account/SH identity and
/// conversation persistence. Local StorageService remains untouched as the
/// existing device persistence boundary.
class ConversationService {
  const ConversationService();

  String get _shId {
    final identity = AuthSession.identityContext.identity;
    if (identity == null) {
      throw StateError('No authenticated SH identity is available.');
    }
    return identity.shId;
  }

  Future<List<ConversationRecord>> load({int limit = 50}) async {
    final result = await backendClient.rpc(
      'runtime_load_conversation',
      params: {'p_limit': limit.clamp(1, 100)},
    );

    if (result is! List) return const [];
    return result
        .whereType<Map>()
        .map((row) => ConversationRecord.fromMap(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  Future<List<ConversationRecord>> loadContext({int limit = 12}) async {
    final result = await backendClient.rpc(
      'runtime_load_conversation_context',
      params: {
        'p_sh_id': _shId,
        'p_limit': limit.clamp(1, 12),
      },
    );

    if (result is! List) return const [];
    return result
        .whereType<Map>()
        .map((row) => ConversationRecord.fromMap(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  Future<ConversationRecord> record({
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final result = await backendClient.rpc(
      'runtime_record_conversation',
      params: {
        'p_sh_id': _shId,
        'p_role': role,
        'p_content': content,
        'p_metadata': metadata ?? const <String, dynamic>{},
      },
    );

    if (result is! Map) {
      throw StateError('Conversation runtime returned an invalid record.');
    }
    return ConversationRecord.fromMap(Map<String, dynamic>.from(result));
  }
}

class ConversationRecord {
  const ConversationRecord({
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.metadata,
  });

  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  bool get isAssistant => role == 'assistant';

  factory ConversationRecord.fromMap(Map<String, dynamic> row) {
    final conversationId = row['conversation_id']?.toString();
    final role = row['role']?.toString();
    final content = row['content']?.toString();
    final createdAtRaw = row['created_at']?.toString();

    if (conversationId == null ||
        role == null ||
        content == null ||
        createdAtRaw == null) {
      throw StateError('Conversation runtime returned an incomplete record.');
    }

    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) {
      throw StateError('Conversation runtime returned an invalid timestamp.');
    }

    final metadata = row['metadata'];
    return ConversationRecord(
      conversationId: conversationId,
      role: role,
      content: content,
      createdAt: createdAt,
      metadata: metadata is Map
          ? Map<String, dynamic>.from(metadata)
          : const <String, dynamic>{},
    );
  }
}
