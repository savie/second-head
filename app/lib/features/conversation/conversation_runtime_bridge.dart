import 'conversation_service.dart';

export 'conversation_service.dart' show ConversationRecord, ConversationSummary, ProjectSummary;

class ConversationRuntimeBridge {
  const ConversationRuntimeBridge({ConversationService service = const ConversationService()}) : _service = service;

  final ConversationService _service;

  String? get activeConversationId => ConversationService.activeConversationId.value;

  Future<List<ConversationRecord>> load({int limit = 100}) => _service.load(limit: limit);
  Future<List<ConversationRecord>> loadContext({int limit = 12}) => _service.loadContext(limit: limit);
  Future<List<ConversationSummary>> listConversations() => _service.listConversations();
  Future<List<ProjectSummary>> listProjects() => _service.listProjects();
  Future<String> createProject(String name) => _service.createProject(name);
  Future<String> createConversation({String? projectId, String? title}) => _service.createConversation(projectId: projectId, title: title);
  Future<void> selectConversation(String conversationId) => _service.selectConversation(conversationId);
  Future<ConversationRecord> recordUser(String content) => _service.record(role: 'user', content: content);
  Future<ConversationRecord> recordAssistant(String content) => _service.record(role: 'assistant', content: content);
  Future<void> rename({required String conversationId, required String title}) => _service.rename(conversationId: conversationId, title: title);
  Future<void> updateMessage({required String messageId, required String oldContent, required String newContent}) => _service.updateMessage(messageId: messageId, oldContent: oldContent, newContent: newContent);
  Future<void> deleteMessage({required String messageId}) => _service.deleteMessage(messageId: messageId);
  Future<void> deleteConversation({required String conversationId}) => _service.deleteConversation(conversationId: conversationId);
}
