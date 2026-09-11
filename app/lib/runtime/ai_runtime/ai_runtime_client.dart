import '../runtime_contract.dart';
import '../../core/result.dart';
import 'provider/ai_provider_adapter.dart';
import 'provider/supabase_ai_runtime_adapter.dart';

/// Generic AI Runtime implementation of the RuntimeClient boundary.
///
/// Provider selection, credentials, context retrieval, persistence, and
/// semantic lifecycle remain behind the deployed runtime execution unit.
final class AIRuntimeClient implements RuntimeClient {
  const AIRuntimeClient({AIProviderAdapter adapter = const SupabaseAIRuntimeAdapter()})
      : _adapter = adapter;

  final AIProviderAdapter _adapter;

  @override
  Future<AppResult<RuntimeResponse>> send(RuntimeRequest request) async {
    final result = await _adapter.execute(
      AIProviderRequest(input: request.input),
    );

    return switch (result) {
      AppSuccess<AIProviderResponse>(value: final response) =>
        AppSuccess<RuntimeResponse>(RuntimeResponse(output: response.output)),
      AppFailure<AIProviderResponse>(error: final error) =>
        AppFailure<RuntimeResponse>(error),
    };
  }
}
