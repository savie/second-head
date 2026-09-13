import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/backend/backend_client.dart';
import '../../core/storage/storage_service.dart';
import 'conversation_attachment_service.dart';

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

  Future<String> createProject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Project name is required.');
    final result = await backendClient.rpc('runtime_create_project', params: {'p_name': trimmed});
    if (result == null) throw StateError('Project runtime returned no project id.');
    return result.toString();
  }

  Future<void> renameProject({required String projectId, required String name}) async {
    await backendClient.rpc('runtime_rename_project', params: {'p_project_id': projectId, 'p_name': name});
  }

  Future<void> deleteProject({required String projectId}) async {
    final deletedActiveConversation = activeConversationId.value;
    await backendClient.rpc('runtime_delete_project', params: {'p_project_id': projectId});

    if (deletedActiveConversation != null && deletedActiveConversation.isNotEmpty) {
      final conversations = await listConversations();
      final stillExists = conversations.any((item) => item.conversationId == deletedActiveConversation);
      if (!stillExists) activeConversationId.value = null;
    }
  }

  Future<void> moveConversation({required String conversationId, required String projectId}) async {
    await backendClient.rpc('runtime_assign_conversation_project', params: {
      'p_conversation_id': conversationId,
      'p_project_id': projectId,
    });
  }

  Future<void> removeConversationFromProject({required String conversationId}) async {
    await backendClient.rpc('runtime_assign_conversation_project', params: {
      'p_conversation_id': conversationId,
      'p_project_id': null,
    });
  }

  Future<String> createConversation({String? projectId, String? title}) async {
    final result = await backendClient.rpc('runtime_create_conversation', params: {'p_project_id': projectId, 'p_title': title ?? 'New Conversation'});
    if (result == null) throw StateError('Conversation runtime returned no conversation id.');
    final id = result.toString();
    activeConversationId.value = id;
    await StorageService.saveConversationState(title: title ?? 'New Conversation', messages: const []);
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
    final records = result.whereType<Map>().map((row) => ConversationRecord.fromMap(Map<String, dynamic>.from(row))).toList();
    for (var i = 0; i < records.length; i++) {
      final attachments = await const ConversationAttachmentService().loadForMessage(records[i].messageId);
      records[i] = records[i].copyWith(attachments: attachments);
    }
    return records;
  }

  Future<List<ConversationRecord>> loadContext({int limit = 12}) async {
    final conversationId = await _ensureActiveConversation();
    final result = await backendClient.rpc('runtime_load_conversation_context_for_thread', params: {'p_conversation_id': conversationId, 'p_limit': limit.clamp(1, 12)});
    if (result is! List) return const [];
    final records = result.whereType<Map>().map((row) => ConversationRecord.fromMap(Map<String, dynamic>.from(row))).toList();
    for (var i = 0; i < records.length; i++) {
      final attachments = await const ConversationAttachmentService().loadForMessage(records[i].messageId);
      records[i] = records[i].copyWith(attachments: attachments);
    }
    return records;
  }

  Future<ConversationRecord> record({
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
    String? messageId,
    DateTime? createdAt,
  }) async {
    final conversationId = await _ensureActiveConversation();
    final stableMessageId = messageId ?? _newMessageId();
    final stableCreatedAt = (createdAt ?? DateTime.now()).toUtc();
    final result = await backendClient.rpc('runtime_record_conversation_message_v2', params: {
      'p_conversation_id': conversationId,
      'p_message_id': stableMessageId,
      'p_created_at': stableCreatedAt.toIso8601String(),
      'p_role': role,
      'p_content': content,
      'p_metadata': metadata ?? const <String, dynamic>{},
    });
    if (result is! Map) throw StateError('Conversation runtime returned an invalid record.');
    return ConversationRecord.fromMap(Map<String, dynamic>.from(result));
  }

  Future<ConversationRecord> recordWithAttachments({
    required String role,
    required String content,
    required List<PendingConversationAttachment> attachments,
    Map<String, dynamic>? metadata,
  }) async {
    final recordResult = await record(role: role, content: content, metadata: metadata);
    final persisted = <ConversationAttachment>[];
    for (final pending in attachments) {
      final created = await const ConversationAttachmentService().create(
        filename: pending.filename,
        mimeType: pending.mimeType,
        sizeBytes: pending.bytes.length,
        localPath: pending.localPath,
      );
      try {
        persisted.add(await const ConversationAttachmentService().uploadAndFinalize(
          attachment: created,
          bytes: pending.bytes,
          messageId: recordResult.messageId,
        ));
      } catch (_) {
        // The message already exists and the attachment has a stable identity.
        // Preserve that identity locally so Retry can finalize the same row
        // instead of creating a new attachment/message pair.
        persisted.add(created.copyWith(
          messageId: recordResult.messageId,
          status: 'FAILED',
          localPath: pending.localPath,
        ));
      }
    }
    return recordResult.copyWith(attachments: persisted);
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

  static String _newMessageId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}

class PendingConversationAttachment {
  const PendingConversationAttachment({required this.filename, required this.mimeType, required this.bytes, this.localPath});
  final String filename;
  final String mimeType;
  final Uint8List bytes;
  final String? localPath;
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
    if (id == null || name == null || created == null || updated == null) throw StateError('Conversation runtime returned an incomplete project.');
    return ProjectSummary(projectId: id, name: name, createdAt: created, updatedAt: updated);
  }
}

class ConversationRecord {
  const ConversationRecord({required this.messageId, required this.threadId, required this.role, required this.content, required this.createdAt, required this.metadata, this.attachments = const []});
  final String messageId;
  final String threadId;
  final String role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final List<ConversationAttachment> attachments;
  bool get isAssistant => role == 'assistant';
  String? get conversationTitle {
    final value = metadata['conversation_title'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  ConversationRecord copyWith({List<ConversationAttachment>? attachments}) => ConversationRecord(
        messageId: messageId,
        threadId: threadId,
        role: role,
        content: content,
        createdAt: createdAt,
        metadata: metadata,
        attachments: attachments ?? this.attachments,
      );

  factory ConversationRecord.fromMap(Map<String, dynamic> row) {
    final messageId = row['message_id']?.toString();
    final threadId = row['thread_id']?.toString() ?? row['conversation_id']?.toString();
    final role = row['role']?.toString();
    final content = row['content']?.toString();
    final createdAtRaw = row['created_at']?.toString();
    if (messageId == null || threadId == null || role == null || content == null || createdAtRaw == null) throw StateError('Conversation runtime returned an incomplete record.');
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) throw StateError('Conversation runtime returned an invalid timestamp.');
    final metadata = row['metadata'];
    return ConversationRecord(messageId: messageId, threadId: threadId, role: role, content: content, createdAt: createdAt, metadata: metadata is Map ? Map<String, dynamic>.from(metadata) : const <String, dynamic>{});
  }
}
