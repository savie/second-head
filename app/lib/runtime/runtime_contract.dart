import '../core/result.dart';

abstract interface class RuntimeClient {
  Future<AppResult<RuntimeResponse>> send(RuntimeRequest request);
}

final class RuntimeRequest {
  const RuntimeRequest({
    required this.input,
    required this.conversationId,
    required this.userMessageId,
  });

  final String input;
  final String conversationId;
  final String userMessageId;
}

final class RuntimeResponse {
  const RuntimeResponse({
    required this.output,
    this.requestId,
    this.provider,
  });

  final String output;
  final String? requestId;
  final String? provider;
}
