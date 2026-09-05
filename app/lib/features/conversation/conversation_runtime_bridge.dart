import 'conversation_service.dart';

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

  Future<ConversationRecord> recordUser(String content) {
    return _service.record(role: 'user', content: content);
  }

  Future<ConversationRecord> recordAssistant(String content) {
    return _service.record(role: 'assistant', content: content);
  }
}
