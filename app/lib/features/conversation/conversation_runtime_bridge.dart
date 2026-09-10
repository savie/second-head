import 'dart:typed_data';

import 'conversation_attachment_service.dart';
import 'conversation_service.dart';

export 'conversation_attachment_service.dart' show ConversationAttachment;
export 'conversation_service.dart' show ConversationRecord, ConversationSummary, PendingConversationAttachment, ProjectSummary;

class ConversationRuntimeBridge {
  const ConversationRuntimeBridge({ConversationService service = const ConversationService()}) : _service = service;

  final ConversationService _service;

  String? get activeConversationId => ConversationService.activeConversationId.value;

  Future<List<ConversationRecord>> load({int limit = 100}) => _service.load(limit: limit);
  Future<List<ConversationRecord>> loadContext({int limit = 12}) => _service.loadContext(limit: limit);
  Future<List<ConversationSummary>> listConversations() => _service.listConversations();
  Future<List<ProjectSummary>> listProjects() => _service.listProjects();
  Future<String> createProject(String name) => _service.createProject(name);
  Future<void> renameProject({required String projectId, required String name}) => _service.renameProject(projectId: projectId, name: name);
  Future<void> deleteProject({required String projectId}) => _service.deleteProject(projectId: projectId);
  Future<String> createConversation({String? projectId, String? title}) => _service.createConversation(projectId: projectId, title: title);
  Future<void> selectConversation(String conversationId) => _service.selectConversation(conversationId);
  Future<void> moveConversation({required String conversationId, required String projectId}) => _service.moveConversation(conversationId: conversationId, projectId: projectId);
  Future<void> removeConversationFromProject({required String conversationId}) => _service.removeConversationFromProject(conversationId: conversationId);
  Future<ConversationRecord> recordUser(String content) => _service.record(role: 'user', content: content);
  Future<ConversationRecord> recordAssistant(String content) => _service.record(role: 'assistant', content: content);
  Future<ConversationRecord> recordWithAttachments({required String role, required String content, required List<PendingConversationAttachment> attachments, Map<String, dynamic>? metadata}) => _service.recordWithAttachments(role: role, content: content, attachments: attachments, metadata: metadata);
  Future<ConversationAttachment> createAttachment({required String filename, required String mimeType, required int sizeBytes, String? localPath}) => const ConversationAttachmentService().create(filename: filename, mimeType: mimeType, sizeBytes: sizeBytes, localPath: localPath);
  Future<ConversationAttachment> uploadAndFinalizeAttachment({required ConversationAttachment attachment, required Uint8List bytes, required String messageId}) => const ConversationAttachmentService().uploadAndFinalize(attachment: attachment, bytes: bytes, messageId: messageId);
  Future<List<ConversationAttachment>> loadAttachments(String messageId) => const ConversationAttachmentService().loadForMessage(messageId);
  Future<Uint8List> downloadAttachment(ConversationAttachment attachment) => const ConversationAttachmentService().download(attachment);
  Future<void> detachAttachment(String attachmentId) => const ConversationAttachmentService().detach(attachmentId);
  Future<void> rename({required String conversationId, required String title}) => _service.rename(conversationId: conversationId, title: title);
  Future<void> updateMessage({required String messageId, required DateTime createdAt, required String role, required String oldContent, required String newContent}) => _service.updateMessage(messageId: messageId, oldContent: oldContent, newContent: newContent);
  Future<void> deleteMessage({required String messageId, required DateTime createdAt, required String role, required String content}) => _service.deleteMessage(messageId: messageId);
  Future<void> deleteConversation({required String conversationId}) => _service.deleteConversation(conversationId: conversationId);
}
