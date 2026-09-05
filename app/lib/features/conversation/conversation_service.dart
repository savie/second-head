import 'package:flutter/foundation.dart';

import '../../core/backend/backend_client.dart';
import '../auth/auth_screens.dart';

class ConversationService {
  const ConversationService();

  static final ValueNotifier<String?> activeConversationId = ValueNotifier<String?>(null);

  Future<List<ConversationSummary>> listConversations() async {
    final result = await backendClient.rpc('runtime_list_conversations');
    if (result is! List) return const [];
    return result.whereType<Map>().map((row) => ConversationSummary.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<List<ProjectSummary>> listProjects() async {
    final result = await backendClient.rpc('runtime_list_projects');
    if (result is! List) return const [];
    return result.whereType<Map>().map((row) => ProjectSummary.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<String> createConversation({String? projectId, String? title}) async {
    final result = await backendClient.rpc('runtime_create_conversation', params: {'p_project_id': projectId, 'p_title': title ?? 'New Conversation'});
    if (result == null) throw StateError('Conversation runtime returned no conversation id.');
    final id = result.toString();
    activeConversationId.value = id;
    return id;
  }

  Future<void> selectConversation(String conversationId) async {
    if (conversationId.trim().isEmpty) throw ArgumentError('conversationId is required.');
    activeConversationId.value = conversationId;
  }

  Future<String> _ensureActiveConversation() async {
    final active = activeConversationId.value;
    if (active != null && active.isNotEmpty) return active;
    final conversations = await listConversations();
    if (conversations.isNotEmpty) {
      activeConversationId.value = conversations.first.conversationId;
      return conversations.first.conversationId;
    }
    return createConversation();
  }

  Future<List<ConversationRecord>> load({int limit = 100}) async {
    final conversationId = await _ensureActiveConversation();
    final result = await backendClient.rpc('runtime_load_conversation_messages', params: {'p_conversation_id': conversationId, 'p_limit': limit.clamp(1, 200)});
    if (result is! List) return const [];
    return result.whereType<Map>().map((row) => ConversationRecord.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<List<ConversationRecord>> loadContext({int limit = 12}) async {
    final conversationId = await _ensureActiveConversation();
    final result = await backendClient.rpc('runtime_load_conversation_context_for_thread', params: {'p_conversation_id': conversationId, 'p_limit': limit.clamp(1, 12)});
    if (result is! List) return const [];
    return result.whereType<Map>().map((row) => ConversationRecord.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<ConversationRecord> record({required String role, required String content, Map<String, dynamic>? metadata}) async {
    final conversationId = await _ensureActiveConversation();
    final result = await backendClient.rpc('runtime_record_conversation_message', params: {'p_conversation_id': conversationId, 'p_role': role, 'p_content': content, 'p_metadata': metadata ?? const <String, dynamic>{}});
    if (result is! Map) throw StateError('Conversation runtime returned an invalid record.');
    return ConversationRecord.fromMap(Map<String, dynamic>.from(result));
  }

  Future<void> rename({required String conversationId, required String title}) async {
    await backendClient.rpc('runtime_rename_conversation_thread', params: {'p_conversation_id': conversationId, 'p_title': title});
  }

  Future<void> updateMessage({required String messageId, required String oldContent, required String newContent}) async {
    await backendClient.rpc('runtime_update_conversation_message_v2', params: {'p_message_id': messageId, 'p_old_content': oldContent, 'p_new_content': newContent});
  }

  Future<void> deleteMessage({required String messageId}) async {
    await backendClient.rpc('runtime_delete_conversation_message_v2', params: {'p_message_id': messageId});
  }

  Future<void> deleteConversation({required String conversationId}) async {
    await backendClient.rpc('runtime_delete_conversation_thread', params: {'p_conversation_id': conversationId});
    if (activeConversationId.value == conversationId) activeConversationId.value = null;
  }
}

class ConversationSummary {
  const ConversationSummary({required this.conversationId, required this.accountId, required this.shId, required this.projectId, required this.title, required this.createdAt, required this.updatedAt, required this.preview});
  final String conversationId;
  final String accountId;
  final String shId;
  final String? projectId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String preview;

  factory ConversationSummary.fromMap(Map<String, dynamic> row) {
    final id = row['conversation_id']?.toString();
    final accountId = row['account_id']?.toString();
    final shId = row['sh_id']?.toString();
    final title = row['title']?.toString();
    final created = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final updated = DateTime.tryParse(row['updated_at']?.toString() ?? '');
    if (id == null || accountId == null || shId == null || title == null || created == null || updated == null) throw StateError('Conversation runtime returned an incomplete summary.');
    return ConversationSummary(conversationId: id, accountId: accountId, shId: shId, projectId: row['project_id']?.toString(), title: title, createdAt: created, updatedAt: updated, preview: row['preview']?.toString() ?? '');
  }
}

class ProjectSummary {
  const ProjectSummary({required this.projectId, required this.name, required this.createdAt, required this.updatedAt});
  final String projectId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProjectSummary.fromMap(Map<String, dynamic> row) {
    final id = row['project_id']?.toString();
    final name = row['name']?.toString();
    final created = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final updated = DateTime.tryParse(row['updated_at']?.toString() ?? '');
    if (id == null || name == null || created == null || updated == null) throw StateError('Project runtime returned an incomplete summary.');
    return ProjectSummary(projectId: id, name: name, createdAt: created, updatedAt: updated);
  }
}

class ConversationRecord {
  const ConversationRecord({required this.conversationId, required this.messageId, required this.threadId, required this.role, required this.content, required this.createdAt, required this.metadata});
  /// Message id is kept in conversationId for compatibility with the existing message UI.
  final String conversationId;
  final String messageId;
  final String threadId;
  final String role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  bool get isAssistant => role == 'assistant';

  String? get conversationTitle {
    final value = metadata['conversation_title'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  factory ConversationRecord.fromMap(Map<String, dynamic> row) {
    final messageId = row['message_id']?.toString() ?? row['conversation_id']?.toString();
    final threadId = row['thread_id']?.toString() ?? row['conversation_id']?.toString();
    final role = row['role']?.toString();
    final content = row['content']?.toString();
    final createdAtRaw = row['created_at']?.toString();
    if (messageId == null || threadId == null || role == null || content == null || createdAtRaw == null) throw StateError('Conversation runtime returned an incomplete record.');
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) throw StateError('Conversation runtime returned an invalid timestamp.');
    final metadata = row['metadata'];
    return ConversationRecord(conversationId: messageId, messageId: messageId, threadId: threadId, role: role, content: content, createdAt: createdAt, metadata: metadata is Map ? Map<String, dynamic>.from(metadata) : const <String, dynamic>{});
  }
}
