import '../runtime_contract.dart';
import '../../core/result.dart';
import 'provider/ai_provider_adapter.dart';
import 'provider/ai_runtime_transport_adapter.dart';

/// Generic AI Runtime implementation of the RuntimeClient boundary.
///
/// Provider selection, credentials, context retrieval, persistence, and
/// semantic lifecycle remain behind the AI Runtime execution boundary.
final class AIRuntimeClient implements RuntimeClient {
  const AIRuntimeClient({AIProviderAdapter adapter = const AIRuntimeTransportAdapter()})
      : _adapter = adapter;

  final AIProviderAdapter _adapter;

  @override
  Future<AppResult<RuntimeResponse>> send(RuntimeRequest request) async {
    final result = await _adapter.execute(
      AIProviderRequest(
        input: request.input,
        conversationId: request.conversationId,
        userMessageId: request.userMessageId,
        mode: switch (request.mode) {
          RuntimeExecutionMode.normal => 'normal',
          RuntimeExecutionMode.generateOnly => 'generate_only',
        },
      ),
    );

    return switch (result) {
      AppSuccess<AIProviderResponse>(value: final response) =>
        AppSuccess<RuntimeResponse>(
          RuntimeResponse(
            output: response.output,
            requestId: response.requestId,
            provider: response.provider,
          ),
        ),
      AppFailure<AIProviderResponse>(error: final error) =>
        AppFailure<RuntimeResponse>(error),
    };
  }
}
