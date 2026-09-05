import 'conversation_service.dart';

export 'conversation_service.dart' show ConversationRecord;

/// Application-side bridge for the Conversation persistence slice.
///
/// Keeps backend records separate from the existing local ConversationMessage
/// representation. The UI can adopt this bridge without making StorageService
/// responsible for backend persistence.
class ConversationRuntimeBridge {
  const ConversationRuntimeBridge({ConversationService service = const ConversationService()})
      : _service = service;

  final ConversationService _service;

  Future<List<ConversationRecord>> load({int limit = 50}) {
    return _service.load(limit: limit);
  }

  Future<List<ConversationRecord>> loadContext({int limit = 12}) {
    return _service.loadContext(limit: limit);
  }

  Future<ConversationRecord> recordUser(String content) {
    return _service.record(role: 'user', content: content);
  }

  Future<ConversationRecord> recordAssistant(String content) {
    return _service.record(role: 'assistant', content: content);
  }

  Future<void> rename({
    required String conversationId,
    required String title,
  }) {
    return _service.rename(conversationId: conversationId, title: title);
  }

  Future<void> updateMessage({
    required String conversationId,
    required DateTime createdAt,
    required String role,
    required String oldContent,
    required String newContent,
  }) {
    return _service.updateMessage(
      conversationId: conversationId,
      createdAt: createdAt,
      role: role,
      oldContent: oldContent,
      newContent: newContent,
    );
  }

  Future<void> deleteMessage({
    required String conversationId,
    required DateTime createdAt,
    required String role,
    required String content,
  }) {
    return _service.deleteMessage(
      conversationId: conversationId,
      createdAt: createdAt,
      role: role,
      content: content,
    );
  }

  Future<void> deleteConversation({required String conversationId}) {
    return _service.deleteConversation(conversationId: conversationId);
  }
}
