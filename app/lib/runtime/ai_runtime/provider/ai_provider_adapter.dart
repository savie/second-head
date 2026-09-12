import '../../../core/result.dart';

/// Vendor-neutral execution boundary for AI providers.
///
/// AI Runtime depends on this abstraction and must not depend on a specific
/// provider, model vendor, endpoint, or credential mechanism.
abstract interface class AIProviderAdapter {
  Future<AppResult<AIProviderResponse>> execute(AIProviderRequest request);
}

final class AIProviderRequest {
  const AIProviderRequest({
    required this.input,
    required this.conversationId,
    required this.userMessageId,
  });

  final String input;
  final String conversationId;
  final String userMessageId;
}

final class AIProviderResponse {
  const AIProviderResponse({
    required this.output,
    this.requestId,
    this.provider,
  });

  final String output;
  final String? requestId;
  final String? provider;
}
