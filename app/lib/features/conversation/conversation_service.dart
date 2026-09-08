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
