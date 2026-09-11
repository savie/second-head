import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/backend_client.dart';
import '../../../core/result.dart';
import 'ai_provider_adapter.dart';

/// Vendor-neutral transport adapter to the deployed AI Runtime execution unit.
///
/// Provider credentials and provider selection remain server-side in the
/// Supabase Edge Function. This client only crosses the runtime boundary.
final class SupabaseAIRuntimeAdapter implements AIProviderAdapter {
  const SupabaseAIRuntimeAdapter({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _backend => _client ?? backendClient;

  @override
  Future<AppResult<AIProviderResponse>> execute(
    AIProviderRequest request,
  ) async {
    try {
      final response = await _backend.functions.invoke(
        'runtime-p4a-001',
        body: <String, dynamic>{
          'user_message': request.input,
        },
      );
      final data = response.data;
      if (data is! Map) {
        return AppFailure<AIProviderResponse>(
          const UnexpectedAppError(
            'AI Runtime returned an invalid response envelope',
          ),
        );
      }

      final output = data['response'];
      if (output is! String || output.trim().isEmpty) {
        return AppFailure<AIProviderResponse>(
          const UnexpectedAppError(
            'AI Runtime returned no response text',
          ),
        );
      }

      return AppSuccess<AIProviderResponse>(
        AIProviderResponse(output: output),
      );
    } on FunctionException catch (error) {
      return AppFailure<AIProviderResponse>(
        UnexpectedAppError(
          'AI Runtime invocation failed: ${error.details ?? error.status}',
        ),
      );
    } catch (error) {
      return AppFailure<AIProviderResponse>(
        UnexpectedAppError('AI Runtime invocation failed: $error'),
      );
    }
  }
}
