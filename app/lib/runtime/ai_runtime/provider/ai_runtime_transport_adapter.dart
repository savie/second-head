import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/backend_client.dart';
import '../../../core/result.dart';
import 'ai_provider_adapter.dart';

/// Transport implementation for the AI Runtime execution boundary.
///
/// Infrastructure details remain behind this implementation. The AI Runtime
/// contract does not expose a specific backend, provider, model, endpoint, or
/// credential mechanism.
final class AIRuntimeTransportAdapter implements AIProviderAdapter {
  const AIRuntimeTransportAdapter({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _backend => _client ?? backendClient;

  @override
  Future<AppResult<AIProviderResponse>> execute(
    AIProviderRequest request,
  ) async {
    try {
      final response = await _backend.functions.invoke(
        'ai-runtime',
        body: <String, dynamic>{
          'user_message': request.input,
          'conversation_id': request.conversationId,
          'user_message_id': request.userMessageId,
          'mode': switch (request.mode) {
            RuntimeExecutionMode.normal => 'normal',
            RuntimeExecutionMode.generateOnly => 'generate_only',
          },
        },
      );
      final data = response.data;
      if (data is! Map) {
        return AppFailure<AIProviderResponse>(
          const BackendRuntimeAppError(
            'AI Runtime returned an invalid response envelope',
          ),
        );
      }

      final output = data['response'];
      if (output is! String || output.trim().isEmpty) {
        return AppFailure<AIProviderResponse>(
          const BackendRuntimeAppError('AI Runtime returned no response text'),
        );
      }

      return AppSuccess<AIProviderResponse>(
        AIProviderResponse(
          output: output,
          requestId: data['meta'] is Map
              ? (data['meta'] as Map)['request_id'] as String?
              : data['request_id'] as String?,
          provider: data['meta'] is Map
              ? (data['meta'] as Map)['provider'] as String?
              : data['provider'] as String?,
        ),
      );
    } on FunctionException catch (error) {
      final status = error.status;
      final details = error.details?.toString();
      final message = details == null || details.isEmpty
          ? 'AI Runtime invocation failed: $status'
          : 'AI Runtime invocation failed: $details';

      return AppFailure<AIProviderResponse>(
        switch (status) {
          401 => UnauthenticatedAppError(message),
          403 => AuthorizationDeniedAppError(message),
          400 || 422 => InvalidMessageAppError(message),
          _ => BackendRuntimeAppError(message),
        },
      );
    } catch (error) {
      return AppFailure<AIProviderResponse>(
        NetworkUnavailableAppError('AI Runtime invocation failed: $error'),
      );
    }
  }
}
